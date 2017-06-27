//
//  LoginViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 14/09/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import Alamofire
import SwiftyJSON

class LoginViewController: LoginParentViewController {

    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var qrView: UIImageView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var urlBtn: UIButton!
 
    
    // MARK: - Login
    
    override func tokenGenerated() {
        qrView.image = UIImage(ciImage: generateQrFromString(LoginListener.sharedInstance.token!))
        activityView.stopAnimating()
        urlBtn.isEnabled = true
    }

    func generateQrFromString(_ string: String) -> CIImage {
        let data = string.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
    
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
    
        let image = filter.outputImage!
        let scaleX = qrView.frame.size.width / image.extent.size.width
        let scaleY = qrView.frame.size.height / image.extent.size.height
    
        return image.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    
    }


}
