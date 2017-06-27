//
//  PosterHeaderCollectionReusableView.swift
//  Fetch
//
//  Created by Stephen Radford on 04/11/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit

class PosterHeaderCollectionReusableView: UICollectionReusableView {
    
    fileprivate var focusGuide = UIFocusGuide()
    
    @IBOutlet weak var syncBtn: UIButton!
    
    @IBAction func refresh(_ sender: AnyObject) {
        print("trigger from button")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "TriggerRefresh"), object: nil))
    }
    
    override func awakeFromNib() {
        syncBtn.setTitle("Syncing...", for: UIControlState.disabled)
        if Videos.sharedInstance.syncing {
            syncBtn.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PosterHeaderCollectionReusableView.refreshHasBegan), name: NSNotification.Name(rawValue: "RefreshBegan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PosterHeaderCollectionReusableView.finishedRefresh), name: NSNotification.Name(rawValue: "RefreshComplete"), object: Videos.sharedInstance)
    }
    
    override func prepareForReuse() {
        addLayoutGuide(focusGuide)
        focusGuide.preferredFocusedView = syncBtn
        
        // Anchor the top left of the focus guide.
        focusGuide.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        focusGuide.topAnchor.constraint(equalTo: topAnchor).isActive = true
        focusGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        focusGuide.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    
    func finishedRefresh() {
        syncBtn.isEnabled = true
    }
    
    func refreshHasBegan() {
        syncBtn.isEnabled = false
    }
    
}
