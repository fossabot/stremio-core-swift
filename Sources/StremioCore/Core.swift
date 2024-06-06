//
//  Core.swift
//  Stremio
//
//  Created by Alvin on 17.01.24.
//

import Foundation
import SwiftProtobuf
import Wrapper
#if targetEnvironment(macCatalyst)
#else
import UIKit
#endif

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
    @objc internal static func onRuntimeEvent(_ eventData: NSData){
        do {
            let test = NSMutableURLRequest()
            test.httpBody = eventData as Data;
            
            let event = try Stremio_Core_Runtime_RuntimeEvent(serializedData: eventData as Data)
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
        print(getDeviceInfo())
        initialize_rust()
        do {
            if let swiftData = initializeNative(getDeviceInfo()), !swiftData.isEmpty{
                return try Stremio_Core_Runtime_EnvError(serializedData: swiftData)
            }
        } catch {
            print("Swift Error decoding EnvError: \(error)")
        }
        return nil
    }

    public static func getState<T: Message>(_ field: Stremio_Core_Runtime_Field) -> T? {
        do {
            if let swiftData = getStateNative(Int32(field.rawValue)), !swiftData.isEmpty{
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
            dispatchNative(actionProtobuf)
        } catch {
            print("Swift Error encoding RuntimeAction: \(error)")
        }
    }

    public static func getVersion() -> String {
        return getVersionNative()
    }

    public static func decodeStreamData(streamData: String) -> Stremio_Core_Types_Stream? {
        do {
            if let swiftData = decodeStreamDataNative(streamData), !swiftData.isEmpty{
                return try Stremio_Core_Types_Stream(serializedData: swiftData)
            }
        } catch {
            print("Swift Error decoding Stream: \(error)")
        }
        return nil
    }
}

func getDeviceInfo() -> String {
    #if targetEnvironment(macCatalyst)
    let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceMatching("IOPlatformExpertDevice"))
    var modelIdentifier: String
    if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
        modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters) ?? "UNKNOWN"
    }
    else {modelIdentifier = "UNKNOWN"}
    IOObjectRelease(service)
    
    let osType = "macOS"
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion.description
    #else
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let modelIdentifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }

    let osType = UIDevice.current.systemName
    let osVersion =  UIDevice.current.systemVersion
    #endif
    return "(\(modelIdentifier); \(osType) \(osVersion))"
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

#if targetEnvironment(macCatalyst)
extension OperatingSystemVersion {
    var description: String {
        var patchVersion = ""
        if self.patchVersion != 0{
            patchVersion = ".\(self.patchVersion)"
        }
        
        return "\(self.majorVersion).\(self.minorVersion)\(patchVersion)"
    }
}
#endif
