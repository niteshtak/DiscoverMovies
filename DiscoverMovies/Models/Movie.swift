//
//  Movie.swift
//  DiscoverMovies
//
//  Created by NiteshTak on 14/2/17.
//  Copyright © 2017 NiteshTak. All rights reserved.
//

import Foundation

class Movie : CustomDebugStringConvertible {
    
    var title: String
    var posterPath: String
    var backdropPath: String
    var id: Int
    var genres: [Int] = []
    var overview: String
    var popularity: Float
    var voteAverage: Float
    var synopsis: String

    var debugDescription: String {
        return title
    }

    init(response:AnyObject) {
        id = response.object(forKey: Constants.MovieKeys.id) as! Int
        title = response.object(forKey: Constants.MovieKeys.title) as? String ?? ""
        overview = response.object(forKey: Constants.MovieKeys.overview) as? String ?? ""
        posterPath = response.object(forKey: Constants.MovieKeys.posterPath) as? String ?? ""
        backdropPath = response.object(forKey: Constants.MovieKeys.backdropPath) as? String ?? ""
        popularity = response.object(forKey: Constants.MovieKeys.popularity) as! Float
        voteAverage = response.object(forKey: Constants.MovieKeys.voteAverage) as! Float
        synopsis = response.object(forKey: Constants.MovieKeys.synopsis) as? String ?? ""
    
        if let generes = response.object(forKey: Constants.MovieKeys.genreIds) as? [Int] {
            genres = generes
        }
    }
    
    var thumbnailURL: URL? {
        return URL(string:  Constants.imageUrlPrefix + "w92" + posterPath)
    }
    
    var backdropURL: URL? {
        let path = !backdropPath.isEmpty ? backdropPath : posterPath
        guard !path.isEmpty else {
            return nil
        }
        return URL(string:  Constants.imageUrlPrefix + "w780" + path)
    }
}
