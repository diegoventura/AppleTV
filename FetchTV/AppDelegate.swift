//
//  AppDelegate.swift
//  FetchTV
//
//  Created by Stephen Radford on 11/09/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        showFirstRunIfRequired()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        showFirstRunIfRequired()
    }

    // MARK: - First Run
    
    func showFirstRunIfRequired() {
        
        if UserDefaults.standard.bool(forKey: "logout") {
            Putio.keychain["access_token"] = nil
            Videos.sharedInstance.wipe()
            LoginListener.sharedInstance.getTVToken()
            UserDefaults.standard.set(false, forKey: "logout")
        }
        
        if Putio.accessToken == nil {
            let sb = UIStoryboard(name: "Login", bundle: nil)
            window?.rootViewController = sb.instantiateInitialViewController()
        } else if UserDefaults.standard.bool(forKey: "disableMediaSections") {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = sb.instantiateViewController(withIdentifier: "allFilesView")
        } else if ((window?.rootViewController as? FetchTabBarController) == nil) {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = sb.instantiateInitialViewController()
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TriggerRefresh"), object: nil))
        }
    }
    
    // MARK: - Open With a URL
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        if url.host! == "play" {
            
            playVideoFromURL(url)
            
        } else if url.host! == "movie" {
            
            if let movies = UserDefaults(suiteName: "group.FetchPutIo")?.object(forKey: "movies") as? [[String:AnyObject]] {
                
                let m = movies.filter({ $0["id"] as! String == url.pathComponents[1] })[0]
                let movie = Movie.fromCache(cache: m)
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "movieInfo") as! MovieInfoViewController
                vc.movie = movie
                
                window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
            
        } else if url.host! == "tv" {
            
            if let shows = UserDefaults(suiteName: "group.FetchPutIo")?.object(forKey: "shows") as? [[String:AnyObject]] {
            
                let s = shows.filter({ $0["id"] as! String == url.pathComponents[1] })[0]
                let show = TVShow.fromCache(cache: s)
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfo") as! MediaInfoViewController
                vc.tvShow = show
                
                window?.rootViewController?.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
        return true
    }

    func playVideoFromURL(_ url: URL) {
        let id = url.pathComponents[1]
        
        File.getFileById(id: id) { file in
            
            let videoController: MediaPlayerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mediaPlayer") as! MediaPlayerViewController
            videoController.file = file
            let urlString = "\(Putio.api)files/\(id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
            let video = AVPlayerItem(url: URL(string: urlString)!)
            
            var title: String?
            var overview: String?
            
            if let movies = UserDefaults(suiteName: "group.FetchPutIo")?.object(forKey: "movies") as? [[String:String]] {
                let vid = movies.filter({ $0["fileID"] == id })[0]
                title = vid["title"]
                overview = vid["overview"]
            }
         
            if let t = title {
                let title = AVMutableMetadataItem()
                title.key = AVMetadataCommonKeyTitle as NSCopying & NSObjectProtocol
                title.keySpace = AVMetadataKeySpaceCommon
                title.value = t as NSCopying & NSObjectProtocol
                title.locale = NSLocale.current
                video.externalMetadata.append(title)
            }
            
            if let overview = overview {
                let description = AVMutableMetadataItem()
                description.key = AVMetadataCommonKeyDescription as NSCopying & NSObjectProtocol
                description.keySpace = AVMetadataKeySpaceCommon
                description.value = overview as NSCopying & NSObjectProtocol
                description.locale = NSLocale.current
                video.externalMetadata.append(description)
            }
            
            videoController.player = AVPlayer(playerItem: video)
            
            self.window?.rootViewController?.present(videoController, animated: true, completion: nil)
            
        }

    }
    
}

