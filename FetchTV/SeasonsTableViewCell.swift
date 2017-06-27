//
//  SeasonsTableViewCell.swift
//  Fetch
//
//  Created by Stephen Radford on 16/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit

class SeasonsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var episodes: [TVEpisode] = []
    
    var file: File?
    
    var delegate: SeasonsTableViewCellDelegate?
    
    override var canBecomeFocused : Bool {
        return false
    }
    
    var focusPath = IndexPath(row: 0, section: 0)
    
    // MARK: UICollectionViewDataSource
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return focusPath
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "episodeCell", for: indexPath) as! EpisodeCollectionViewCell
        
        let ep = episodes[indexPath.row]
        
        cell.label.text = "\(ep.episodeNo!). \(ep.title!)"
        
        if let image = ep.still {
            cell.image.image = (ep.file!.accessed) ? compositeImage(image) : image
        } else {
            cell.image.image = (ep.file!.accessed) ? compositeImage(UIImage(named: "episode")!) : UIImage(named: "episode")
            ep.loadStill { image in
                UIView.transition(with: cell.image, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.image.image = (ep.file!.accessed) ? self.self.compositeImage(image) : image
                }, completion: nil)
            }
        }
        
        return cell
    }
    
    
    func compositeImage(_ image1: UIImage) -> UIImage {
        
        let size = CGSize(width: 308, height: 172);
        let scale: CGFloat = 0.0
        
        // Scale the image
        image1.draw(at: CGPoint(x: 0, y: 0))
        UIGraphicsBeginImageContextWithOptions(size, false , scale)
        image1.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Draw the tick
        UIGraphicsBeginImageContextWithOptions(size, false , scale)
        scaledImage!.draw(at: CGPoint(x: 0, y: 0))
        let tick = UIImage(named: "done")
        tick?.draw(at: CGPoint(x: 0, y: 0))
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return result!
        
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episode = episodes.sorted(by: { $0.episodeNo! < $1.episodeNo! })[indexPath.row]
        episode.file?.accessed = true
        
        // TODO: See if we can fix the nasty animation change
        self.focusPath = indexPath
        self.collectionView.reloadItems(at: [indexPath])
        self.collectionView.updateFocusIfNeeded()
        
        delegate?.performSegueWithEpisode(episode)
    }
    

}
