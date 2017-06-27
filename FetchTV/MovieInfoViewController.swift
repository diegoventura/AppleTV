//
//  MovieInfoViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 14/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit

class MovieInfoViewController: UIViewController {

    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var overview: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewHeight: NSLayoutConstraint!
    
    var file: File?
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie?.title
        overview.text = movie?.overview
        overviewHeight.constant = overview.contentSize.height
        
        if movie?.files.count == 1 {
            file = movie?.files[0]
        }
        
        file = movie?.files[0]
    
        loadBackdrop()
    }
    
    func loadBackdrop() {
        
        poster.layer.shadowColor = UIColor.black.cgColor
        poster.layer.shadowOffset = CGSize(width: 0, height: 2)
        poster.layer.shadowRadius = 5
        poster.layer.shadowOpacity = 0.2
        
        if let poster = movie?.poster {
            
            self.poster.image = poster
            
            if let backdrop = movie?.backdrop {
                let image = backdrop
                self.backdrop.image = image
            } else {
                let image = self.blurImage(poster)
                self.backdrop.image = image
                self.movie?.backdrop = image
            }
            
            if poster.isDark() {
                self.titleLabel.textColor = .white
                self.overview.textColor = .white
            }
            
        } else if movie?.posterURL != nil {
            
            movie?.loadPoster { image in
                
                UIView.transition(with: self.poster, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.poster.image = image
                }, completion: nil)

                UIView.transition(with: self.backdrop, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.backdrop.image = self.blurImage(image)
                }, completion: nil)
                
                if image.isDark() {
                    self.titleLabel.textColor = .white
                    self.overview.textColor = .white
                }
                
            }
            
        }
        
    }
    
    func blurImage(_ image: UIImage) -> UIImage {
        
        let context = CIContext()
        
        let imageToBlur = CIImage(image: image)
        
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter!.setDefaults()
        clampFilter!.setValue(imageToBlur, forKey: kCIInputImageKey)
        
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(40, forKey: "inputRadius")
        blurfilter!.setValue(imageToBlur, forKey: kCIInputImageKey)
        
        let resultImage = blurfilter!.value(forKey: kCIOutputImageKey) as! CIImage
        
        let rect = imageToBlur!.extent.insetBy(dx: 40, dy: 0)
        return UIImage(cgImage: context.createCGImage(resultImage, from: rect)!)
        
    }

    
    @IBAction func play(_ sender: AnyObject) {
        movie?.files[0].getTime {
            self.performSegue(withIdentifier: "showPlayer", sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let videoController: MediaPlayerViewController = segue.destination as! MediaPlayerViewController
        videoController.file = file
        let urlString = "\(Putio.api)files/\(file!.id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
        let url = URL(string: urlString)
        let video = AVPlayerItem(url: url!)
        
        if let image = movie!.poster {
            let artwork = AVMutableMetadataItem()
            artwork.key = AVMetadataCommonKeyArtwork as NSCopying & NSObjectProtocol
            artwork.keySpace = AVMetadataKeySpaceCommon
            artwork.value = UIImagePNGRepresentation(image)! as NSCopying & NSObjectProtocol
            artwork.locale = Locale.current
            video.externalMetadata.append(artwork)
        }
        
        if let epTitle = movie!.title {
            let title = AVMutableMetadataItem()
            title.key = AVMetadataCommonKeyTitle as NSCopying & NSObjectProtocol
            title.keySpace = AVMetadataKeySpaceCommon
            title.value = epTitle as NSCopying & NSObjectProtocol
            title.locale = Locale.current
            video.externalMetadata.append(title)
        }
        
        if let overview = movie!.overview {
            let description = AVMutableMetadataItem()
            description.key = AVMetadataCommonKeyDescription as NSCopying & NSObjectProtocol
            description.keySpace = AVMetadataKeySpaceCommon
            description.value = overview as NSCopying & NSObjectProtocol
            description.locale = Locale.current
            video.externalMetadata.append(description)
        }
        
        videoController.player = AVPlayer(playerItem: video)
    }
    
}
