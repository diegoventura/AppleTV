//
//  EpisodeCollectionViewCell.swift
//  Fetch
//
//  Created by Stephen Radford on 16/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        label.layer.zPosition = 10
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.6
        label.isHidden = false
        label.alpha = 0
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            self.label.alpha = (self.isFocused) ? 1 : 0
        }, completion: nil)
    }
    
}
