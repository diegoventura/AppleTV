//
//  AllFilesViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 19/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVFoundation
import Alamofire

class AllFilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var directory: File?
    
    var selectedFile: File?
    
    var files: [File] = []
    
    var tableView: UITableView!
    
    var infoView: GenericFileInfoViewController!
    
    var noMediaView: NoMediaView?
    
    var loadingView: LoadingView?
    
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noMediaView = Bundle.main.loadNibNamed("NoMediaView", owner: self, options: nil)![0] as? NoMediaView
        noMediaView?.label.text = "No Files Available"
        noMediaView?.frame = view.bounds
        noMediaView?.isHidden = true
        view.addSubview(noMediaView!)
        
        loadingView = Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)![0] as? LoadingView
        loadingView!.frame = view.bounds
        loadingView!.activityIndicator.startAnimating()
        loadingView!.isHidden = true
        view.addSubview(loadingView!)
        
        let delay = DispatchTime.now() + Double(Int64(Double(0.5) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delay) {
            if !self.loaded {
                self.loadingView?.alpha = 0
                self.loadingView?.isHidden = false
                UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
                    self.loadingView?.alpha = 1
                }, completion: nil)
            }
        }
        
        navigationItem.title = (directory != nil) ? directory!.name : "All Files"
        let rect = CGRect(x: 90, y: 0, width: view.bounds.width-180, height: 145)
        navigationController?.navigationBar.frame = rect
        
        infoView.view.isHidden = true
        
        loadFiles()
    }
    
    func loadFiles() {
        var params = ["oauth_token" : Putio.accessToken!, "start_from": "1"]
        if directory != nil {
            params["parent_id"] = "\(directory!.id)"
        }
        
        Files.fetchMoviesFromURL(url: "\(Putio.api)files/list", params: params, sender: self) { files in
            self.files = files
            self.tableView.reloadData()
            self.loaded = true
            
            if files.count == 0 {
                self.noMediaView?.isHidden = false
            } else {
                self.infoView.view.isHidden = false
            }
            
            if !self.loadingView!.isHidden {
                UIView.animateKeyframes(withDuration: 1.0, delay: 0.5, options: [], animations: {
                    self.loadingView?.alpha = 0
                }, completion: { complete in
                    self.loadingView?.isHidden = true
                })
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell")!
        cell.textLabel?.text = files[indexPath.row].name
        cell.accessoryType = (files[indexPath.row].content_type == "application/x-directory") ? .disclosureIndicator : .none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedTable" {
            let vc = segue.destination as! AllFilesTableViewController
            tableView = vc.tableView
        }
        
        if segue.identifier == "embedGenericView" {
            let vc = segue.destination as! GenericFileInfoViewController
            infoView = vc
        }
        
        if segue.identifier == "showPlayer" {
            let videoController: MediaPlayerViewController = segue.destination as! MediaPlayerViewController
            videoController.file = selectedFile
            let urlString = "\(Putio.api)files/\(selectedFile!.id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
            let url = URL(string: urlString)
            videoController.player = AVPlayer(url: url!)
        }
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if let nextIndex = context.nextFocusedIndexPath {
            let file = files[nextIndex.row]
            infoView.titleLabel.text = file.name
            infoView.imageView.image = UIImage(named: "episode")
            infoView.subtitlesLabel.text = (file.subtitles.characters.count > 0) ? "Yes" : "No"
            infoView.fileSizeLabel.text = ""
            infoView.fileAccessedLabel.text = (file.accessed) ? "Yes" : "No"
            infoView.contentTypeLabel.text = file.content_type
            
            let formatter = ByteCountFormatter()
            infoView.fileSizeLabel.text = formatter.string(fromByteCount: file.size)
            
            if let screenshot = file.screenshot, file.image == nil {
                Alamofire.request(screenshot, method: .get)
                    .responseData { response in
                        let image = UIImage(data: response.result.value!)
                        file.image = image
                        UIView.transition(with: self.infoView.imageView, duration: 0.8, options: .transitionCrossDissolve, animations: {
                            self.infoView.imageView.image = image
                        }, completion: nil)
                }
            } else if let image = file.image {
                infoView.imageView.image = image
            } else if file.content_type == "application/x-directory" {
                infoView.imageView.image = UIImage(named: "directory")
            }
            
        }
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let file = files[indexPath.row]
        
        if file.content_type == "application/x-directory" {
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "filesView") as! AllFilesViewController
            vc.directory = files[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            selectedFile = file
            performSegue(withIdentifier: "showPlayer", sender: self)
        }
    
    }

}
