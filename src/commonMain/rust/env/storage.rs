use serde::{Deserialize, Serialize};
use std::ffi::{CStr, CString};
use futures::future;

use objc::runtime::{Object, Class};
use objc::{msg_send, sel, sel_impl,class};
use stremio_core::runtime::{EnvError, EnvFutureExt, TryEnvFuture};

pub struct Storage {
}
//TODO: This implimentation probably have race condition. Proper implimentation needed
impl Storage {
    pub fn new() -> Result<Self, &'static str> {
        Ok(Self {})
    }

    pub fn get<T: for<'de> Deserialize<'de> + Send + 'static>(
        &self,
        key: &str,
    ) -> TryEnvFuture<Option<T>> {
        let key = key.to_owned();
        Box::pin(future::lazy(move |_| {
            unsafe {
                let defaults_class = Class::get("NSUserDefaults").expect("Could not find NSUserDefaults class");
                let storage: *mut Object = msg_send![defaults_class, standardUserDefaults];
                
                let key_cstring = CString::new(key).expect("Failed to create CString for key");
                let key_obj: *mut Object = msg_send![class!(NSString), stringWithUTF8String: key_cstring.as_ptr()];
                let retrieved_value: *mut Object = msg_send![storage, objectForKey: key_obj];
                // Convert the retrieved value to a Rust type
                if !retrieved_value.is_null() {
                    // Deserialize the value if it's not null
                    // (Note: Deserialize should be implemented for T)
                    let value_str: *const i8 = msg_send![retrieved_value, UTF8String];
                    let value: String = String::from_utf8_lossy(CStr::from_ptr(value_str).to_bytes()).into();
                    let deserialized_value: T = serde_json::from_str(&value).map_err(EnvError::from)?; // Adjust error handling as needed
                    Ok(Some(deserialized_value))
                } else {
                    Ok(None)
                }
            }
        }))
        .boxed_env()
    }
    pub fn set<T: Serialize>(&self, key: &str, value: Option<&T>) -> TryEnvFuture<()> {
        if let Some(value) = value {
            unsafe {    
                let defaults_class = Class::get("NSUserDefaults").expect("Could not find NSUserDefaults class");
                let storage: *mut Object = msg_send![defaults_class, standardUserDefaults];
    
                // Convert the value to a JSON string
                let value_str = match serde_json::to_string(value) {
                    Ok(value) => value,
                    Err(error) => return future::err(EnvError::Serde(error.to_string())).boxed_env(),
                };                
                let key_cstring = CString::new(key).expect("Failed to create CString for key");
                let value_cstring = CString::new(value_str).expect("Failed to create CString for value");
    
                // Set the value in UserDefaults
                let key_obj: *mut Object = msg_send![class!(NSString), stringWithUTF8String: key_cstring.as_ptr()];
                let value_obj: *mut Object = msg_send![class!(NSString), stringWithUTF8String: value_cstring.as_ptr()];
                // Explicitly specify the types for msg_send!
                let _: *mut Object = msg_send![storage, setObject: value_obj forKey: key_obj];
            }
        }
        future::lazy(move |_| {
            Ok(()) // Return the serialized value
        })
        .boxed_env()
    }
}


