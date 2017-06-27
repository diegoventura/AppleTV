//
//  FullyReplaceSegue.swift
//  Fetch
//
//  Created by Stephen Radford on 30/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class FullyReplaceSegue: UIStoryboardSegue {

    override func perform() {
        
        if let presenting = source.presentingViewController {
            presenting.dismiss(animated: true) {
                UIApplication.shared.keyWindow?.rootViewController = self.destination
            }
        } else {
            UIApplication.shared.keyWindow?.rootViewController = self.destination
        }
        
        
    }
    
}
