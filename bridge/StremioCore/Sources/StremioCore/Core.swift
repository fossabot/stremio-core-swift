//
//  Core.swift
//  Stremio
//
//  Created by Alvin on 29.01.24.
//

import Foundation
import SwiftProtobuf

public class Core {
    
    public static func SetLoadRange(field: Stremio_Core_Runtime_Field?, start: UInt32, end: UInt32) {
        var action = Stremio_Core_Runtime_Action()
        if field == .board || field == .discover{
            action.load.catalogsWithExtra = Stremio_Core_Models_CatalogsWithExtra.Selected()
            CoreWrapper.dispatch(action: action, field: field)
        }
        
        action = Stremio_Core_Runtime_Action()
        action.catalogsWithExtra.loadRange.start = start
        action.catalogsWithExtra.loadRange.end = end
        CoreWrapper.dispatch(action: action, field: field)
    }
    
    //MARK: - set filters
    public static func SetCatalogFilter(field: Stremio_Core_Runtime_Field?, filter: Stremio_Core_Models_CatalogWithFilters.SelectableType){
        var action = Stremio_Core_Runtime_Action()
        action.load.catalogWithFilters.request = filter.request
        CoreWrapper.dispatch(action: action, field: field)
    }
    
    public static func SetAddonsFilter(field: Stremio_Core_Runtime_Field?, filter: Stremio_Core_Models_AddonsWithFilters.SelectableType){
        var action = Stremio_Core_Runtime_Action()
        action.load.addonsWithFilters.request = filter.request
        CoreWrapper.dispatch(action: action, field: field)
    }
    
    
    //MARK: - load states
    public static func LoadBoard() -> Stremio_Core_Models_CatalogsWithExtra? {
        if let myMessage: Stremio_Core_Models_CatalogsWithExtra = CoreWrapper.getState(.board) {
           return myMessage
        }
        return nil
    }
    
    public static func LoadContinueWatchingPreview() -> Stremio_Core_Models_ContinueWatchingPreview? {
        if let myMessage: Stremio_Core_Models_ContinueWatchingPreview = CoreWrapper.getState(.continueWatchingPreview) {
           return myMessage
        }
        return nil
    }
    
    public static func LoadDiscover() -> Stremio_Core_Models_CatalogWithFilters? {
        if let myMessage: Stremio_Core_Models_CatalogWithFilters = CoreWrapper.getState(.discover) {
           return myMessage
        }
        return nil
    }
    
    public static func LoadAddons() -> Stremio_Core_Models_AddonsWithFilters? {
        if let myMessage: Stremio_Core_Models_AddonsWithFilters = CoreWrapper.getState(.addons) {
           return myMessage
        }
        return nil
    }
    
    public static func LoadAddonDetails() -> Stremio_Core_Models_AddonDetails? {
        if let myMessage: Stremio_Core_Models_AddonDetails = CoreWrapper.getState(.addonDetails) {
           return myMessage
        }
        return nil
    }

    public static func LoadCtx() -> Stremio_Core_Models_Ctx? {
        if let myMessage: Stremio_Core_Models_Ctx = CoreWrapper.getState(.ctx) {
           return myMessage
        }
        return nil
    }
    
    public static func LoadPlayer() -> Stremio_Core_Models_Player? {
        if let myMessage: Stremio_Core_Models_Player = CoreWrapper.getState(.player) {
           return myMessage
        }
        return nil
    }
    
    //MARK: - For search
    
    public static func Search(_ searchString: String) {
        var action = Stremio_Core_Runtime_Action()
        SetLoadRange(field: .search, start: 0, end: 6)

        var searchRequest = Stremio_Core_Types_ExtraValue()
        searchRequest.name = "search"; searchRequest.value = searchString

        action = Stremio_Core_Runtime_Action()
        action.load.catalogsWithExtra.extra = [searchRequest]
        CoreWrapper.dispatch(action: action, field: .search)
        
        SetLoadRange(field: .search, start: 0, end: 1)
    }
    
    public static func getSearchResults() -> Stremio_Core_Models_CatalogsWithExtra? {
        if let myMessage: Stremio_Core_Models_CatalogsWithExtra = CoreWrapper.getState(.search) {
           return myMessage
        }
        return nil
    }
    
    // MARK: - Function to load MetaIteam detailed
    public static func MetaItemLoad(metaItem: MetaItem) {
        var action = Stremio_Core_Runtime_Action()
        action.load.metaDetails.metaPath.resource = "meta"
        action.load.metaDetails.metaPath.type = metaItem.type
        action.load.metaDetails.metaPath.id =  metaItem.type == "series" ? String(metaItem.id.prefix(while: { $0 != ":" })) : metaItem.id
        action.load.metaDetails.streamPath.resource = "stream"
        action.load.metaDetails.streamPath.type = metaItem.type
        action.load.metaDetails.streamPath.id = metaItem.id
        action.load.metaDetails.guessStreamPath = true
        CoreWrapper.dispatch(action: action, field: .metaDetails)
    }
    
    public static func MetaItemGet(interval: TimeInterval) -> Stremio_Core_Models_MetaDetails?{
        var result : Stremio_Core_Models_MetaDetails
        repeat {
            Thread.sleep(forTimeInterval: interval)
            guard let myMessage: Stremio_Core_Models_MetaDetails = CoreWrapper.getState(.metaDetails) else {return nil}
                result = myMessage
            if case .loading = result.metaItem.content {
                continue
            }
            break
        }
        while (true)
        return result
    }
    
    public static func Load() {
        var action = Stremio_Core_Runtime_Action()
        action.ctx.pullAddonsFromApi = SwiftProtobuf.Google_Protobuf_Empty()
        CoreWrapper.dispatch(action: action, field: .ctx)

        action = Stremio_Core_Runtime_Action()
        action.ctx.pullUserFromApi = SwiftProtobuf.Google_Protobuf_Empty()
        CoreWrapper.dispatch(action: action, field: .ctx)
        
        action = Stremio_Core_Runtime_Action()
        action.ctx.syncLibraryWithApi = SwiftProtobuf.Google_Protobuf_Empty()
        CoreWrapper.dispatch(action: action, field: .ctx)
        
        action = Stremio_Core_Runtime_Action()
        action.ctx.pullNotifications = SwiftProtobuf.Google_Protobuf_Empty()
        CoreWrapper.dispatch(action: action, field: .ctx)
        
        action = Stremio_Core_Runtime_Action()
        action.ctx.getEvents = SwiftProtobuf.Google_Protobuf_Empty()
        CoreWrapper.dispatch(action: action, field: .ctx)
    }
    
    public static func Unload(field: Stremio_Core_Runtime_Field?) {
        var action = Stremio_Core_Runtime_Action()
        action.unload = Stremio_Core_Runtime_Action.ActionUnload()
        CoreWrapper.dispatch(action: action, field: field)
    }
    //MARK: -- VideoPlayer
    public static func PlayerItemLoad(urlPath: [String]) {
        if urlPath.isEmpty {return}
        guard let stream = CoreWrapper.decodeStreamData(streamData: urlPath[1]) else {return}
        
        var action = Stremio_Core_Runtime_Action()
        action.load.player.stream = stream
        //If url contains info about meta then load it also
        if urlPath.count >= 6{
            let addonURL = urlPath[2]
            let metaURL = urlPath[3]
            let contentType = urlPath[4]
            let contentID = urlPath[5]
            let streamID = urlPath.count >= 7 ?  urlPath[6] : contentID
            
            action.load.player.streamRequest.base = addonURL
            action.load.player.streamRequest.path.resource = "stream"
            action.load.player.streamRequest.path.id = streamID
            action.load.player.streamRequest.path.type = contentType
            
            action.load.player.metaRequest.base = metaURL
            action.load.player.metaRequest.path.resource = "meta"
            action.load.player.metaRequest.path.id = contentID
            action.load.player.metaRequest.path.type = contentType
            
            action.load.player.subtitlesPath.resource = "subtitles"
            action.load.player.subtitlesPath.id = streamID
            action.load.player.subtitlesPath.type = contentType
        }
        CoreWrapper.dispatch(action: action, field: .player)
    }
    
    public static func PlayerTimeChanged(duration: Double, time: Double){
        var action = Stremio_Core_Runtime_Action()
        #if targetEnvironment(macCatalyst)
        action.player.timeChanged.device = "AppleMacOS"
        #elseif os(iOS)
        action.player.timeChanged.device = "AppleiOS"
        #elseif os(tvOS)
        action.player.timeChanged.device = "AppletvOS"
        #endif
        action.player.timeChanged.duration = UInt64(duration) * 1000
        action.player.timeChanged.time =  UInt64(time) * 1000
        CoreWrapper.dispatch(action: action, field: .player)
    }
    
    public static func PlayerSetStatus(isPaused: Bool){
        var action = Stremio_Core_Runtime_Action()
        action.player.pausedChanged = isPaused
        CoreWrapper.dispatch(action: action, field: .player)
    }
    
    public static func PlayerVideoParmChanged(){
        var action = Stremio_Core_Runtime_Action()
        action.player.videoParamsChanged.clearFilename()
        action.player.videoParamsChanged.clearHash()
        action.player.videoParamsChanged.clearSize()
        CoreWrapper.dispatch(action: action, field: .player)
    }
    
    
    //MARK: -- Addons
    public static func AddonItemLoad(transportURL: String) {
        var action = Stremio_Core_Runtime_Action()
        action.load.addonDetails.transportURL = transportURL
        CoreWrapper.dispatch(action: action, field: .addonDetails)
    }
    
    public static func UninstallAddon(addonItem: Stremio_Core_Types_Descriptor) {
        var action = Stremio_Core_Runtime_Action()
        action.ctx.uninstallAddon = addonItem
        CoreWrapper.dispatch(action: action)
    }
    
    public static func InstallAddon(addonItem: Stremio_Core_Types_Descriptor) {
        var action = Stremio_Core_Runtime_Action()
        action.ctx.installAddon = addonItem
        CoreWrapper.dispatch(action: action)
    }
    
    //MARK: - For account related functions

    public static func LoginWithToken(token: String) {
        //TODO: Implimnet logining with token
    }
    
    public static func Login(email: String, password: String) {
        var action = Stremio_Core_Runtime_Action()
        action.ctx.authenticate.login.email = email
        action.ctx.authenticate.login.password = password
        action.ctx.authenticate.login.facebook = false
        CoreWrapper.dispatch(action: action, field: .ctx)
    }
    
    public static func Logout() {
        var action = Stremio_Core_Runtime_Action()
        action.ctx.logout = SwiftProtobuf.Google_Protobuf_Empty()
        CoreWrapper.dispatch(action: action, field: .ctx)
    }
}

public protocol MetaItem {
    var id: String { get }
    var type: String { get }
    var name: String { get }
}

extension Stremio_Core_Types_MetaItem: MetaItem {}

extension Stremio_Core_Types_MetaItemPreview: MetaItem {}
