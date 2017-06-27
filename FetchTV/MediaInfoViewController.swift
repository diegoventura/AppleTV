//
//  MediaInfoViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 13/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import Alamofire

class MediaInfoViewController: UIViewController, TVShowDelegate {

    /// The TVShow to display on the page
    var tvShow: TVShow?
    
    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overview: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var content: UIView!
    
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var tableViewController: SeasonsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvShow?.delegate = self
        
        titleLabel.text = tvShow?.title
        overview.text = tvShow?.overview
        
        if overview.contentSize.height > 620 {
            
            let gradient = CAGradientLayer()
            
            gradient.frame = overview.bounds
            gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, 0.94, 0.95, 1.0]
            overview.layer.mask = gradient
            
        }
        
        tvShow!.convertFilesToEpisodes()
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        if (tvShow?.seasons.count)! > 1 {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
        }
        
        loadBackdrop()
    }
    
    
    func loadBackdrop() {
        
        poster.layer.shadowColor = UIColor.black.cgColor
        poster.layer.shadowOffset = CGSize(width: 0, height: 2)
        poster.layer.shadowRadius = 5
        poster.layer.shadowOpacity = 0.2
        
        if let poster = tvShow?.poster {
            
            self.poster.image = poster
            
            if let backdrop = tvShow?.backdrop {
                let image = backdrop
                self.backdrop.image = image
            } else {
                let image = self.blurImage(poster)
                self.backdrop.image = image
                self.tvShow?.backdrop = image
            }
            
            if poster.isDark() {
                self.titleLabel.textColor = .white
                self.overview.textColor = .white
            }
            
        } else if tvShow?.posterURL != nil {
            
            tvShow?.loadPoster { image in
                
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
    
    
    func tvEpisodesLoaded() {
        tableViewController?.reloadSeasons(tvShow!.seasons)
        progressBar.isHidden = true
        
        print("LOADED")
        
        if (tvShow?.seasons.count)! > 1 {
            scrollView.isScrollEnabled = true
            layoutShelf()
        }
        
    }
    
    func percentUpdated() {
        progressBar.setProgress(tvShow!.completedPercent, animated: true)
    }
    
    func layoutShelf() {
        let rect = tableViewController!.tableView.frame
        let frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: tableViewController!.tableView.contentSize.height)
        tableViewController!.tableView.frame = frame
        
        scrollView.contentSize.height = tableViewController!.tableView.contentSize.height + 700
        heightConst.constant = tableViewController!.tableView.contentSize.height + 700
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embedSeasonsTable" {
            tableViewController = segue.destination as? SeasonsTableViewController
            tableViewController?.tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        }
        
    }

}
