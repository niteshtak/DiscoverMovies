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
    var genereIds: [Int] = []
    var genres: [[String: Any]]?
    var overview: String
    var popularity: Float
    var voteAverage: Float
    var synopsis: String
    var runtime: Int?
    var spokenLanguages: [[String: Any]]?
    
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
        runtime = response.object(forKey: Constants.MovieKeys.runtime) as? Int
        genres = response.object(forKey: Constants.ServerKey.genres) as? [[String: Any]]
        spokenLanguages = response.object(forKey: Constants.MovieKeys.spokenLanguages) as? [[String: Any]]
    
        if let genereids = response.object(forKey: Constants.MovieKeys.genreIds) as? [Int] {
            genereIds = genereids
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
