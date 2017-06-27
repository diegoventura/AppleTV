//
//  FocusableText.swift
//  Fetch
//
//  Created by Stephen Radford on 15/11/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class FocusableText: UIView {

    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    override func awakeFromNib() {
        visualEffect.cornerRadius = 10
        visualEffect.alpha = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.4
    }
    
    override var canBecomeFocused : Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            visualEffect.alpha = 1
        } else {
            visualEffect.alpha = 0
        }
        
    }

}
