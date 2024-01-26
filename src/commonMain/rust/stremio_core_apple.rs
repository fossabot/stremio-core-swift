#[cfg(debug_assertions)]
use std::panic;
use std::ptr::null;
use std::sync::RwLock;
use futures::{future, StreamExt};
use std::os::raw::c_char;
use std::ffi::{CStr, CString};


use prost::Message;
use lazy_static::lazy_static;
use stremio_core::constants::{
    DISMISSED_EVENTS_STORAGE_KEY, LIBRARY_RECENT_STORAGE_KEY, LIBRARY_STORAGE_KEY,
    NOTIFICATIONS_STORAGE_KEY, PROFILE_STORAGE_KEY, SEARCH_HISTORY_STORAGE_KEY,
    STREAMS_STORAGE_KEY,
};
use stremio_core::models::common::Loadable;
use stremio_core::runtime::{Env, EnvError, Runtime, RuntimeEvent};
use stremio_core::types::events::DismissedEventsBucket;
use stremio_core::types::library::LibraryBucket;
use stremio_core::types::notifications::NotificationsBucket;
use stremio_core::types::profile::Profile;
use stremio_core::types::resource::Stream;
use stremio_core::types::search_history::SearchHistoryBucket;
use stremio_core::types::streams::StreamsBucket;

use crate::bridge::{FromProtobuf, ToProtobuf};
use crate::env::{AppleEnv, AppleEvent};
use crate::model::AppleModel;
use crate::protobuf::stremio::core::runtime;
use crate::protobuf::stremio::core::runtime::Field;

lazy_static! {
    static ref RUNTIME: RwLock<Option<Loadable<Runtime<AppleEnv, AppleModel>, EnvError>>> =
        Default::default();
}

#[repr(C)]
pub struct ByteArray {
    data: *const u8,
    length: usize,
}

#[no_mangle]
pub extern "C" fn initialize_rust() {
    // Initialization code for Apple devices
    #[cfg(debug_assertions)]
    panic::set_hook(Box::new(|info| {
        // iOS-specific logging or error handling
        // You may want to use NSLog or other iOS-specific logging mechanisms
        println!("Error: {}", info);
    }));
}

// actual fun initialize(storage: Storage): EnvError? {
//     return initializeNative(storage)
//         ?.let { EnvError.decodeFromByteArray(it) }
// }
#[no_mangle]
pub unsafe extern "C" fn initializeNative() -> ByteArray {
    let init_result = AppleEnv::exec_sync(AppleEnv::init());

    match init_result {
        Ok(_) => {
            let storage_result = AppleEnv::exec_sync(future::try_join3(
                future::try_join5(
                    AppleEnv::get_storage::<Profile>(PROFILE_STORAGE_KEY),
                    AppleEnv::get_storage::<LibraryBucket>(LIBRARY_RECENT_STORAGE_KEY),
                    AppleEnv::get_storage::<LibraryBucket>(LIBRARY_STORAGE_KEY),
                    AppleEnv::get_storage::<StreamsBucket>(STREAMS_STORAGE_KEY),
                    AppleEnv::get_storage::<NotificationsBucket>(NOTIFICATIONS_STORAGE_KEY),
                ),
                AppleEnv::get_storage::<SearchHistoryBucket>(SEARCH_HISTORY_STORAGE_KEY),
                AppleEnv::get_storage::<DismissedEventsBucket>(DISMISSED_EVENTS_STORAGE_KEY),
            ));
            match storage_result {
                Ok((
                    (profile, recent_bucket, other_bucket, streams, notifications),
                    search_history,
                    dismissed_events,
                )) => {
                    let profile = profile.unwrap_or_default();
                    let mut library = LibraryBucket::new(profile.uid(), vec![]);
                    if let Some(recent_bucket) = recent_bucket {
                        library.merge_bucket(recent_bucket);
                    };
                    if let Some(other_bucket) = other_bucket {
                        library.merge_bucket(other_bucket);
                    };
                    let streams = streams.unwrap_or(StreamsBucket::new(profile.uid()));
                    let notifications = notifications.unwrap_or(NotificationsBucket::new::<
                        AppleEnv,
                    >(
                        profile.uid(), vec![]
                    ));
                    let search_history =
                        search_history.unwrap_or(SearchHistoryBucket::new(profile.uid()));
                    let dismissed_events =
                        dismissed_events.unwrap_or(DismissedEventsBucket::new(profile.uid()));
                    let (model, effects) = AppleModel::new(
                        profile,
                        library,
                        streams,
                        notifications,
                        search_history,
                        dismissed_events,
                    );
                    let (runtime, rx) = Runtime::<AppleEnv, _>::new(
                        model,
                        effects.into_iter().collect::<Vec<_>>(),
                        1000,
                    );
                    AppleEnv::exec_concurrent(rx.for_each(move |event| {
                        if let RuntimeEvent::CoreEvent(event) = &event {
                            let runtime = RUNTIME.read().expect("runtime read failed");
                            let runtime = runtime
                                .as_ref()
                                .expect("runtime is not ready")
                                .as_ref()
                                .expect("runtime is not ready");
                            let model = runtime.model().expect("model read failed");

                            // iOS-specific logic for emitting to analytics
                            // Replace "TODO" with actual iOS analytics logic
                            AppleEnv::emit_to_analytics(
                                &AppleEvent::CoreEvent(event.to_owned()),
                                &model,
                                "TODO",
                            );
                        };
                        future::ready(())
                    }));
                    *RUNTIME.write().expect("RUNTIME write failed") = Some(Loadable::Ready(runtime));
                    ByteArray {
                        data: std::ptr::null(),
                        length: 0,
                    }
                }
                Err(error) => {
                    *RUNTIME.write().expect("RUNTIME write failed") = Some(Loadable::Err(error.to_owned()));
                    let result_bytes = error.to_protobuf(&()).encode_to_vec();
                    let byte_array = ByteArray {
                        data: result_bytes.as_ptr(),
                        length: result_bytes.len(),
                    };
                    std::mem::forget(result_bytes);
                    byte_array
                }
            }
        }
        Err(error) => {
            *RUNTIME.write().expect("RUNTIME write failed") = Some(Loadable::Err(error.to_owned()));
            let result_bytes = error.to_protobuf(&()).encode_to_vec();
            let byte_array = ByteArray {
                data: result_bytes.as_ptr(),
                length: result_bytes.len(),
            };
            std::mem::forget(result_bytes);
            byte_array
        }
    }
}

//fun dispatch(action: Action, field: Field?)
//dispatchNative(actionProtobuf) actionProtobuf is byteArr
#[no_mangle]
pub unsafe extern "C" fn dispatchNative(action_protobuf: ByteArray) {
    // Convert the incoming action_protobuf bytes to a Vec<u8>
    let action_bytes: &[u8] = std::slice::from_raw_parts(action_protobuf.data, action_protobuf.length);
    let runtime_action = match runtime::RuntimeAction::decode(action_bytes) {
        Ok(action) => action.from_protobuf(),
        Err(err) => {
            eprintln!("Error decoding RuntimeAction protobuf: {:?}", err);
            return;
        }
    };
    println!("Action Bytes: {:?}", action_bytes);
    let runtime = RUNTIME.read().expect("RUNTIME read failed");
    let runtime = runtime
        .as_ref()
        .expect("RUNTIME not initialized")
        .as_ref()
        .expect("RUNTIME not initialized");
    runtime.dispatch(runtime_action);
}

// actual inline fun <reified T : Message> getState(field: Field): T {
//     val protobuf = getStateNative(field)
//     val companion = T::class.companionObjectInstance as Message.Companion<T>
//     return companion.decodeFromByteArray(protobuf)
// }
#[no_mangle]
pub unsafe extern "C" fn getStateNative(field: i32) -> ByteArray {
    let field =  Field::try_from(field).ok().from_protobuf().expect("AppleModelField convert failed");;
    let runtime = RUNTIME.read().expect("RUNTIME read failed");
    let runtime = runtime
        .as_ref()
        .expect("RUNTIME not initialized")
        .as_ref()
        .expect("RUNTIME not initialized");
    let model = runtime.model().expect("model read failed");
    let data = model.get_state_binary(&field);
    let byte_array = ByteArray {data: data.as_ptr(), length: data.len()};
    //Leaking data
    std::mem::forget(data);
    byte_array
}

// actual fun decodeStreamData(streamData: String): Stream? {
//     return decodeStreamDataNative(streamData)
//         ?.let { Stream.decodeFromByteArray(it) }
// }
//Returns 0 address as Null
#[no_mangle]
pub unsafe extern "C" fn decodeStreamDataNative(field: *const c_char) ->  ByteArray {
    let stream = match Stream::decode(CStr::from_ptr(field).to_string_lossy().into_owned()) {
        Ok(stream) => stream,
        Err(_) => return ByteArray {data: std::ptr::null(), length: 0},
    };
  
    let data = stream
        .to_protobuf(&(None, None, None, None))
        .encode_to_vec();
    let byte_array = ByteArray {data: data.as_ptr(), length: data.len()};
    std::mem::forget(data);
    byte_array
}

#[no_mangle]
pub unsafe extern "C" fn sendNextAnalyticsBatch() {
    AppleEnv::exec_concurrent(AppleEnv::send_next_analytics_batch());
}

#[no_mangle]
pub extern "C" fn freeByteArrayNative(byte_array: ByteArray) {
    // Convert the raw pointer and length back into a Vec<u8>
    let data = unsafe { Vec::from_raw_parts(byte_array.data as *mut u8, byte_array.length, byte_array.length) };

    // Ensure that Vec<u8> is properly deallocated
    std::mem::drop(data);
}

