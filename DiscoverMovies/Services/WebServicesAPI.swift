//
//  WebServicesAPI.swift
//  DiscoverMovies
//
//  Created by NiteshTak on 14/2/17.
//  Copyright © 2017 NiteshTak. All rights reserved.
//

import Foundation
import AFNetworking


class WebServiceAPI {
    
    static let sharedInstance = WebServiceAPI()
    
    private lazy var sessionManager:AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        return manager
    }()
    
    func getMoviesByReleaseDate(page:Int = 1, completion:@escaping ([Movie], Int, Error?) -> Void) {
        let endpoint = Constants.byReleaseDate
        
        var params = defaultParams
        params[Constants.ServerKey.page] = page
        params["primary_release_date.lte"] = "2016-12-31"
        
        sessionManager.get(endpoint, parameters: params, progress: nil, success: { (task:URLSessionDataTask, responseObject:Any?) in
            guard responseObject != nil else {
                completion([], 0, MoviesError.EmptyResponse)
                return
            }
            let (movies, pages) = self.populateMovies(fromResponse: responseObject!)
            if pages == -1 {
                completion([], 0, MoviesError.InvalidResponse)
                return
            }
            
            completion(movies, pages, nil)
            
        }, failure: { (task:URLSessionDataTask?, error:Error) in
            completion([], -1, error)
            print(error)
        })
    }
    
    func getMovieDetails(_ movieId: String, completion:@escaping (Movie?, Bool, Error?) -> Void) {
        sessionManager.get(Constants.movieDetailPath + movieId, parameters: defaultParams, progress: nil, success: {  (task:URLSessionDataTask, responseObject:Any?) in
            guard responseObject != nil else {
                completion(nil, false, MoviesError.EmptyResponse)
                return
            }
            
            let response = responseObject! as! [String : Any]
            let movie = Movie.init(response: response as AnyObject)
            
            completion(movie, true, nil)
            
        }, failure: {(task:URLSessionDataTask?, error:Error) in
            print(error)
             completion(nil, false, error)
        })
    }
    
    func populateMovies(fromResponse response:Any) -> (movies:[Movie], totalPages:Int) {
        let responseObject = response as! [String : Any]
        guard let results = responseObject[Constants.ServerKey.results] as? [AnyObject] else {
            return ([], -1)
        }
        let pages = responseObject[Constants.ServerKey.totalPages] as! Int
        var movies = [Movie]()
        for result in results {
            movies += [Movie(response: result)]
        }
        return (movies, pages)
    }

    private var defaultParams:[String : Any] {
        return ["api_key" : Constants.APIKey]
    }

}
