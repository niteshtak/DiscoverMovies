//
//  MovieListCell.swift
//  DiscoverMovies
//
//  Created by NiteshTak on 12/2/17.
//  Copyright © 2017 NiteshTak. All rights reserved.
//

import UIKit

class MovieListCell : UITableViewCell {
    var imageLoadDataTask:URLSessionDataTask?
    var imageURL: URL? {
        didSet {
            guard imageView != nil else {
                return
            }
            imageView!.image = UIImage(named: "placeholder")
            
            if let url = imageURL {
                imageLoadDataTask = imageView!.downloadedFrom(url: url)
            }
        }
    }
    
    func cancelImageLoad() {
        if let task = imageLoadDataTask {
            task.cancel()
        }
    }
}
