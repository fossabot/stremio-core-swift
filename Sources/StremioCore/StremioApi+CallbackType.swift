//
//  File.swift
//  
//
//  Created by Alvin on 17.06.24.
//

import Foundation

extension StremioApi {
    public class CallbackType {
        public static var error : Int = {
            var type = Stremio_Core_Runtime_Event()
            type.error.error = ""
            type.error.source = Stremio_Core_Runtime_Event()
            return type.getMessageTag
        }()
        
        public static var addonUninstalled : Int = {
            var type = Stremio_Core_Runtime_Event()
            type.addonUninstalled.transportURL = ""
            type.addonUninstalled.id = ""
            return type.getMessageTag
        }()
        
        public static var addonInstalled : Int = {
            var type = Stremio_Core_Runtime_Event()
            type.addonInstalled.transportURL = ""
            type.addonInstalled.id = ""
            return type.getMessageTag
        }()
        
        public static var addonUpgraded : Int = {
            var type = Stremio_Core_Runtime_Event()
            type.addonUpgraded.transportURL = ""
            type.addonUpgraded.id = ""
            return type.getMessageTag
        }()
        
        public static var settingsUpdated : Int = {
            var type = Stremio_Core_Runtime_Event()
            type.settingsUpdated.settings.interfaceLanguage = ""
            type.settingsUpdated.settings.streamingServerURL = ""
            type.settingsUpdated.settings.bingeWatching = false
            type.settingsUpdated.settings.playInBackground = false
            type.settingsUpdated.settings.hardwareDecoding = false
            type.settingsUpdated.settings.audioPassthrough = false
            type.settingsUpdated.settings.audioLanguage = ""
            type.settingsUpdated.settings.subtitlesLanguage = ""
            type.settingsUpdated.settings.subtitlesSize = 0
            type.settingsUpdated.settings.subtitlesFont = ""
            type.settingsUpdated.settings.subtitlesBold = false
            type.settingsUpdated.settings.subtitlesOffset = 0
            type.settingsUpdated.settings.subtitlesTextColor = ""
            type.settingsUpdated.settings.subtitlesBackgroundColor = ""
            type.settingsUpdated.settings.subtitlesOutlineColor = ""
            type.settingsUpdated.settings.subtitlesOpacity = 0
            type.settingsUpdated.settings.escExitFullscreen = false
            type.settingsUpdated.settings.seekTimeDuration = 0
            type.settingsUpdated.settings.seekShortTimeDuration = 0
            type.settingsUpdated.settings.pauseOnMinimize = false
            type.settingsUpdated.settings.secondaryAudioLanguage = ""
            type.settingsUpdated.settings.secondarySubtitlesLanguage = ""
            type.settingsUpdated.settings.playerType = ""
            type.settingsUpdated.settings.frameRateMatchingStrategy = .disabled
            type.settingsUpdated.settings.nextVideoNotificationDuration = 0
            type.settingsUpdated.settings.surroundSound = false
            return type.getMessageTag
        }()
        
    }
}
