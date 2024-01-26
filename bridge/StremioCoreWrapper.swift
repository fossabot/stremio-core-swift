//
//  StremioCoreWrapper.swift
//  Stremio
//
//  Created by Alvin on 17.01.24.
//

import Foundation
import SwiftProtobuf

class StremioCore {
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
           
            let byteStrings = actionProtobuf.map { String($0) }
            let resultString = "[" + byteStrings.joined(separator: ", ") + "]"

            print("Action Bytes: \(resultString)")
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
        var byteArray = ByteArray(data: nil, length: 0)
        
        data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            if let baseAddress = pointer.baseAddress {
                byteArray.data = baseAddress.assumingMemoryBound(to: UInt8.self)
                byteArray.length = UInt(pointer.count)
            }
        }
        return byteArray
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