//
//  SeasonsTableViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 16/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVFoundation
import MediaPlayer

class SeasonsTableViewController: UITableViewController, SeasonsTableViewCellDelegate {

    var seasons: [String:[TVEpisode]] = [:]
    
    var episode: TVEpisode?
    
    var seasonTitles: [String] {
        get {
            return [String](seasons.keys)
        }
    }
    
    var orderedSeasons: [String] {
        get {
            return seasonTitles.sorted(by: { $0 > $1 })
        }
    }
    
    /**
     Reload the seasons
     
     - parameter seasons: Season and TV Episodes
     */
    func reloadSeasons(_ seasons: [String:[TVEpisode]]!) {
        self.seasons = seasons
        if seasons.count == 1 {
            tableView?.isScrollEnabled = false
            tableView?.mask = nil
        }
        
        tableView?.reloadData()
    }
    
    
    
    // MARK: - UITableViewDatasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return seasons.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return orderedSeasons[section].uppercased()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodesCollectionCell") as! SeasonsTableViewCell
        
        let key = orderedSeasons[indexPath.section]
        let season = seasons[key]!
        cell.episodes = season.sorted(by: { $0.episodeNo! < $1.episodeNo! })
        cell.delegate = self
        cell.collectionView.reloadData()
        
        return cell
        
    }
    
    func performSegueWithEpisode(_ episode: TVEpisode) {
        self.episode = episode
        episode.file?.getTime {
            self.performSegue(withIdentifier: "showPlayer", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let videoController: MediaPlayerViewController = segue.destination as! MediaPlayerViewController
        videoController.file = episode!.file
        let urlString = "\(Putio.api)files/\(episode!.file!.id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
        let url = URL(string: urlString)
        
        let video = AVPlayerItem(url: url!)
        
        if let image = episode!.still {
            let artwork = AVMutableMetadataItem()
            artwork.key = AVMetadataCommonKeyArtwork as NSCopying & NSObjectProtocol
            artwork.keySpace = AVMetadataKeySpaceCommon
            artwork.value = UIImagePNGRepresentation(image)! as NSCopying & NSObjectProtocol
            artwork.locale = Locale.current
            video.externalMetadata.append(artwork)
        }
        
        if let epTitle = episode!.title {
            let title = AVMutableMetadataItem()
            title.key = AVMetadataCommonKeyTitle as NSCopying & NSObjectProtocol
            title.keySpace = AVMetadataKeySpaceCommon
            title.value = epTitle as NSCopying & NSObjectProtocol
            title.locale = Locale.current
            video.externalMetadata.append(title)
        }
        
        if let overview = episode!.overview {
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
