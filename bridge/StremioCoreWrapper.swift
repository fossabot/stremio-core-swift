//
//  StremioCoreWrapper.swift
//  Stremio
//
//  Created by Alvin on 17.01.24.
//

import Foundation
import SwiftProtobuf

class StremioCoreWrapper {
    static func initialize() -> Stremio_Core_Runtime_EnvError? {
        initialize_rust()
        do {
            if let swiftData = convertToData(initializeNative()){
                return try Stremio_Core_Runtime_EnvError(serializedData: swiftData)
            }
        } catch {
            print("Swift Error decoding EnvError: \(error)")
        }
        return nil
    }
    
    static func getState<T: Message>(_ field: Stremio_Core_Runtime_Field) -> T? {
        do {
            if let swiftData = convertToData(getStateNative(Int32(field.rawValue))){
                return try T(serializedData: swiftData)
            }
        } catch {
            print("Swift Error decoding state: \(error)")
        }
        return nil
    }
    
    static func dispatch(action: Stremio_Core_Runtime_Action,field: Stremio_Core_Runtime_Field? = nil) {
        var runtimeAction = Stremio_Core_Runtime_RuntimeAction()
        runtimeAction.action = action

        if let field = field{
            runtimeAction.field = field
        }
        do {
            let actionProtobuf = try runtimeAction.serializedData()
            let action_protbuf : ByteArray = convertToByteArray(actionProtobuf)
            dispatchNative(action_protbuf)
            action_protbuf.data.deallocate()
           
        } catch {
            print("Swift Error encoding RuntimeAction: \(error)")
        }
    }
    
    static func decodeStreamData(streamData: String) -> Stremio_Core_Types_Stream? {
        do {
            if let swiftData = convertToData(decodeStreamDataNative(streamData))
            {
                return try Stremio_Core_Types_Stream(serializedData: swiftData)
            }
        } catch {
            print("Swift Error decoding Stream: \(error)")
        }
        return nil
    }
    
    ///Converts Swift Data to C byte array but needs to handle deallocation otherwise memory will leak.
    private static func convertToByteArray(_ data: Data) -> ByteArray {
        let length = data.count

        let byteArray = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        data.copyBytes(to: byteArray, count: length)
        
        let byteArrayStruct = ByteArray(data: byteArray, length: UInt(length))

        return byteArrayStruct
    }

    ///Converts C byte array to Swift Data and it deallocates automaticly
    private static func convertToData(_ byteArray: ByteArray) -> Data? {
        if byteArray.data == nil || byteArray.length == 0{
            return nil
        }
        let bufferPointer = UnsafeBufferPointer(start: byteArray.data, count: Int(byteArray.length))
        let swiftData = Data(buffer: bufferPointer)
        freeByteArrayNative(byteArray)
        
        return swiftData
    }
}

