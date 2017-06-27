import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {
    
    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .sectioned
    }
    
    var topShelfItems: [TVContentItem] {
        
        let wrapperID = TVContentIdentifier(identifier: "movies", container: nil)!
        let wrapperItem = TVContentItem(contentIdentifier: wrapperID)!
        var ContentItems = [TVContentItem]()
        
        if let movies = UserDefaults(suiteName: "group.FetchPutIo")?.object(forKey: "movies") as? [[String:Any]] {
            
            let these = (movies.count > 5) ? Array(movies[0..<5]) : movies
            
            for movie in these {
                
                guard let files = movie["files"] as? [Any], let file = files[0] as? [String: Any], let fileId = file["id"] as? Int else {
                    fatalError("Couldn't find file id. \(#function) [Line: \(#line)]")
                }
                
                let identifier = TVContentIdentifier(identifier: "movie", container: wrapperID)!
                let contentItem = TVContentItem(contentIdentifier: identifier)!
                
                if let url = movie["posterURL"] as? String, url != "" {
                    contentItem.imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(url)")
                }
                
                contentItem.imageShape = .poster
                contentItem.title = movie["title"] as? String
                contentItem.displayURL = URL(string: "FetchTV://movie/\(movie["id"] as! String)")!;
                contentItem.playURL = URL(string: "FetchTV://play/\(fileId)")!;
                
                ContentItems.append(contentItem)

            }
        }
        
        
        // Section Details
        wrapperItem.title = "Movies"
        wrapperItem.topShelfItems = ContentItems
        
        
        let tvWrapperID = TVContentIdentifier(identifier: "tvshows", container: nil)!
        let tvWrapper = TVContentItem(contentIdentifier: tvWrapperID)!
        var tvItems = [TVContentItem]()
        
        if let shows = UserDefaults(suiteName: "group.FetchPutIo")?.object(forKey: "shows") as? [[String:AnyObject]] {
            
            let these = (shows.count > 5) ? Array(shows[0..<5]) : shows
            
            for show in these {
                
                let identifier = TVContentIdentifier(identifier: "show", container: wrapperID)!
                let contentItem = TVContentItem(contentIdentifier: identifier)!
                
                if let url = show["posterURL"] as? String, url != "" {
                    contentItem.imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(url)")
                }
                
                contentItem.imageShape = .poster
                contentItem.title = show["title"] as? String
                contentItem.displayURL = URL(string: "FetchTV://tv/\(show["id"] as! String)")!;
                contentItem.playURL = URL(string: "FetchTV://tv/\(show["id"] as! String)")!;
                
                tvItems.append(contentItem)
            }
        }
        
        
        // Section Details
        tvWrapper.title = "TV Shows"
        tvWrapper.topShelfItems = tvItems
        
        return [tvWrapper, wrapperItem]

    }
}
