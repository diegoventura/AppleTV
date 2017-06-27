//
//  LoginListener.swift
//  Fetch
//
//  Created by Stephen Radford on 09/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PutioKit

class LoginListener: NSObject {
    
    static let sharedInstance = LoginListener()
    
    fileprivate let center = NotificationCenter.default
    
    var token: String?
    
    var url: String?
    
    var timer: Timer?
    
    var delegate: LoginListenerDelegate?
    
    override init() {
        super.init()
        if Putio.accessToken == nil {
            getTVToken()
        }
    }
    
    func getTVToken() {
        
        // TODO: some error checking
        
        Alamofire.request("https://ftch.in/request-tv-token", method: .post, parameters: ["secret": Putio.secret])
            .responseJSON { response in
                let json = JSON(response.result.value!)
                self.token = json["token"].string!
                self.url = json["url"].string!
                
                self.delegate?.tokenGenerated()
                
                self.listen()
            }
        
    }
    
    
    func listen() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(LoginListener.pingServer), userInfo: nil, repeats: true)
    }
    
    func pingServer() {
        Alamofire.request("https://ftch.in/exchange-tokens/\(token!)", method: .get, parameters: ["secret": Putio.secret])
            .responseJSON { response in
                
                if let result = response.result.value {
                    let json = JSON(result)
                    
                    if let accessToken = json["access_token"].string {
                        Putio.keychain.updateIfNeeded(key: "access_token", value: accessToken)
                        self.destroyToken()
                        
                        self.timer?.invalidate()
                        self.timer = nil
                        
                        self.delegate?.loggedInOkay()
                    }
                }
        }
    }
    
    func destroyToken() {
        let _ = Alamofire.request("https://ftch.in/exchange-tokens/\(token!)", method: .delete, parameters: ["secret": Putio.secret])
    }
    
    
}
