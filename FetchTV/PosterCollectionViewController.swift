//
//  PosterCollectionViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 10/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import Alamofire

class PosterCollectionViewController: UICollectionViewController {

    var selectedShow: TVShow?
    
    var noMediaView: UIView?
    
    var focusPath = IndexPath(item: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noMediaView = Bundle.main.loadNibNamed("NoMediaView", owner: self, options: nil)![0] as? UIView
        noMediaView?.frame = view.bounds
        noMediaView?.isHidden = true
        view.addSubview(noMediaView!)
        
        showNoMediaMessageIfRequired()
        
        collectionView?.remembersLastFocusedIndexPath = true
        NotificationCenter.default.addObserver(self, selector: #selector(PosterCollectionViewController.tmdbLoaded(_:)), name: NSNotification.Name(rawValue: "TMDBFinished"), object: Videos.sharedInstance)
        NotificationCenter.default.addObserver(self, selector: #selector(PosterCollectionViewController.refreshHasBegan), name: NSNotification.Name(rawValue: "RefreshBegan"), object: nil)
    }
    
    override func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return focusPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNoMediaMessageIfRequired()
        if !collectionView!.isFocused {
            focusPath = IndexPath(item: 0, section: 0)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if let next = context.nextFocusedIndexPath {
            focusPath = next
        }
        
    }

    
    // MARK: - Sync
    
    func tmdbLoaded(_ sender: AnyObject?) {
        showNoMediaMessageIfRequired()
        collectionView?.reloadData()
    }
    
    func refreshHasBegan() {
        if UIScreen.main.focusedView as? UICollectionViewCell == nil {
            focusPath = IndexPath(item: 0, section: 0)
            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        }
    }
    
    func showNoMediaMessageIfRequired() {
        if Videos.sharedInstance.sortedTV.count == 0 {
            noMediaView?.isHidden = false
        } else {
            noMediaView?.isHidden = true
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Videos.sharedInstance.sortedTV.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath) as! PosterCollectionViewCell
        
        let show = Videos.sharedInstance.sortedTV[indexPath.row]
        cell.label.text = show.title
        
        if let image = show.poster {
            cell.poster.image = image
        } else {
            cell.poster.image = UIImage(named: "poster")
            show.loadPoster { image in
                UIView.transition(with: cell.poster, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.poster.image = image
                }, completion: nil)
            }
        }
    
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "tvShowsHeader", for: indexPath)
    }
    
    
    // MARK: - Navigation
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        focusPath = indexPath
        selectedShow = Videos.sharedInstance.sortedTV[indexPath.row]
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MediaInfoViewController
        vc.tvShow = selectedShow
    }
    
}
