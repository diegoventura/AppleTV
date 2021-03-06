//
//  MediaPlayerViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 24/05/2015.
//  Copyright (c) 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import AVKit
import PutioKit

class MediaPlayerViewController: AVPlayerViewController {
    
    // MARK: - Variables
    
    var file: File?
    var notifier = NotificationCenter.default
    var observer: AnyObject?
    var checked = false
    
    
    // MARK: - Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the start from is more than 0 then show the continue playing alert
        if file!.start_from > 0 {
            player?.pause()
        } else {
            player?.play()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Store the current position when the app is exited
        notifier.addObserver(self, selector: #selector(MediaPlayerViewController.saveTime), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notifier.addObserver(self, selector: #selector(MediaPlayerViewController.finished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem!)
        
        // Check the time at intervals
        observer = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(15, 1), queue: nil) { (time) -> Void in
            self.saveTime()
        } as AnyObject
        
        // Show the alert box when the thing has started but only if we haven't already checked.
        if file!.start_from > 0 && !checked {
            checked = true
            showContinuePlayingAlert()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTime()
        
        player?.removeTimeObserver(observer!)
        notifier.removeObserver(self)
        observer = nil
    }
    
    
    // MARK: - Time
    
    
    func showContinuePlayingAlert() {
        
        player!.pause()
        
        let avc: UIAlertController = UIAlertController(title: "Continue Playing", message: "Would you like to continue where you left off?", preferredStyle: .alert)
        
        avc.addAction(UIAlertAction(title: "Continue Playing", style: .default, handler: { _ in
            let loadedTime = CMTimeMakeWithSeconds(self.file!.start_from, 600)
            self.player!.seek(to: loadedTime)
            self.player!.play()
        }))
        
        avc.addAction(UIAlertAction(title: "Start From The Beginning", style: .cancel, handler: { _ in
            self.player!.play()
        }))
        
        present(avc, animated: true, completion: nil)
    }
    
    
    func saveTime() {
        let time = player?.currentTime()
        let seconds = CMTimeGetSeconds(time!)
        if seconds > 0 {
            file?.start_from = seconds
            file?.saveTime()
        }
    }
    
    func finished() {
        dismiss(animated: true, completion: nil)
    }
    
    
}
