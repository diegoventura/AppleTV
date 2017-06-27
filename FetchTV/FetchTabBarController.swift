//
//  FetchTabBarController.swift
//  Fetch
//
//  Created by Stephen Radford on 15/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit

class FetchTabBarController: UITabBarController {

    var loadingView: ProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FetchTabBarController.tmdbLoaded(_:)), name: NSNotification.Name(rawValue: "TMDBFinished"), object: Videos.sharedInstance)
        NotificationCenter.default.addObserver(self, selector: #selector(FetchTabBarController.putioFilesFetched(_:)), name: NSNotification.Name(rawValue: "PutioFinished"), object: Videos.sharedInstance)
        NotificationCenter.default.addObserver(self, selector: #selector(FetchTabBarController.progressUpdated(_:)), name: NSNotification.Name(rawValue: "TMDBUpdated"), object: Videos.sharedInstance)
        
        loadingView = Bundle.main.loadNibNamed("ProgressView", owner: self, options: nil)![0] as? ProgressView
        loadingView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView?.progressBar.setProgress(0, animated: true)
        
        if Videos.sharedInstance.sortedMovies.count > 0 || Videos.sharedInstance.sortedTV.count > 0 || Videos.sharedInstance.files.count > 0 {
            loadingView?.isHidden = true
            tmdbLoaded(self)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TriggerRefresh"), object: nil))
        } else {
            Videos.sharedInstance.fetch()
        }
        
        view.addSubview(loadingView!)
        
    }
    
    func tmdbLoaded(_ sender: AnyObject?) {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.5, options: [], animations: {
            self.loadingView?.alpha = 0
        }, completion: { complete in
            self.loadingView?.isHidden = true
        })
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(FetchTabBarController.refresh(_:)), name: NSNotification.Name(rawValue: "TriggerRefresh"), object: nil)
    }
    
    func putioFilesFetched(_ sender: AnyObject?) {
        loadingView?.progressBar.setProgress(0.3, animated: true)
        loadingView?.Label.text = "Fetching TV & Movie Info…"
    }
    
    func progressUpdated(_ sender: AnyObject?) {
        let progress = (Videos.sharedInstance.completedPercent) * 0.7
        loadingView?.progressBar.setProgress(progress+0.3, animated: true)
    }
    
    // MARK: - Refresh
    
    func refresh(_ sender: AnyObject?) {
        print("Starting refresh...")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RefreshBegan"), object: nil))
        Videos.sharedInstance.fetch()
    }
    
    
}
