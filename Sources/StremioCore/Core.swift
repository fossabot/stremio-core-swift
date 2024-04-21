//
//  Core.swift
//  Stremio
//
//  Created by Alvin on 17.01.24.
//

import Foundation
import SwiftProtobuf
import Wrapper

public class Core {
    //MARK: - callback
    
    private static var fieldListener : [Stremio_Core_Runtime_Field : (Any) -> Void] = [:]
    private static var eventListener : [Int : (Any) -> Void] = [:]
    
    ///Make sure to remove listener before function gets deallocated to avoid undefined behaviour
    public static func addEventListener(type: Stremio_Core_Runtime_Field, _ function: @escaping (Any) -> Void) {
        Core.fieldListener[type] = function
    }
    
    ///Make sure to remove listener before function gets deallocated to avoid undefined behaviour
    public static func addEventListener(type: Int, _ function: @escaping (Any) -> Void) {
        Core.eventListener[type] = function
    }
    
    public static func removeEventListener(type: Stremio_Core_Runtime_Field) {
        Core.fieldListener.removeValue(forKey: type)
        print(fieldListener)
    }
    
    public static func removeEventListener(type: Int) {
        Core.eventListener.removeValue(forKey: type)
    }
    
    @objc private static func onRuntimeEvent(_ eventProtobuf: ByteArray){
        do {
            let swiftData = convertToData(eventProtobuf, shouldFree: false)!;
            let event = try Stremio_Core_Runtime_RuntimeEvent(serializedData: swiftData)
            var function : ((Any) -> Void)?
            var argument : Any?
            if case .coreEvent(_:) = event.event{
                function = Core.eventListener.first(where: {event.coreEvent.getMessageTag == $0.key})?.value
                argument = event.coreEvent
            }
            else {
                for field in event.newState.fields{
                    print(event)
                    function = Core.fieldListener[field]
                    argument = field
                }
            }
            if let function = function, let argument = argument{
                DispatchQueue.main.sync {
                    function(argument)
                }
            }
        }
        catch{
            print("Swift Error onRuntimeEvent: \(error)")
        }
    }
    
    //MARK: - rust calls
    public static func initialize() -> Stremio_Core_Runtime_EnvError? {
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
    
    public static func getState<T: Message>(_ field: Stremio_Core_Runtime_Field) -> T? {
        do {
            if let swiftData = convertToData(getStateNative(Int32(field.rawValue))){
                return try T(serializedData: swiftData)
            }
        } catch {
            print("Swift Error decoding state: \(error)")
        }
        return nil
    }
    
    public static func dispatch(action: Stremio_Core_Runtime_Action,field: Stremio_Core_Runtime_Field? = nil) {
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
    
    public static func getVersion() -> String? {
        if let swiftData = convertToData(getVersionNative(), shouldFree: false){
            return String(data: swiftData, encoding: .utf8)
        }
        return nil
    }
    
    public static func decodeStreamData(streamData: String) -> Stremio_Core_Types_Stream? {
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
    private static func convertToData(_ byteArray: ByteArray, shouldFree : Bool = true) -> Data? {
        if byteArray.data == nil || byteArray.length == 0{
            return nil
        }
        let bufferPointer = UnsafeBufferPointer(start: byteArray.data, count: Int(byteArray.length))
        let swiftData = Data(buffer: bufferPointer)
        if shouldFree{freeByteArrayNative(byteArray)}
        
        return swiftData
    }
}
//TODO: Find a way to get tag properly
extension SwiftProtobuf.Message {
    var getMessageTag: Int {
        let def = try! SwiftProtobuf.Google_Protobuf_MessageOptions(serializedData: self.serializedData())
        var messageText = def.textFormatString().components(separatedBy: "\n").first
        messageText = messageText?.replacingOccurrences(of: " {", with: "")
        return Int(messageText!) ?? 0
    }
}

