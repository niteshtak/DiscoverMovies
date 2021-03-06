//
//  MovieDetailViewController.swift
//  DiscoverMovies
//
//  Created by NiteshTak on 12/2/17.
//  Copyright © 2017 NiteshTak. All rights reserved.
//

import UIKit
import SafariServices


class MovieDetailViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var movie: Movie?
    private var genreMap = [Int : String]()
    
    private var movieLanguage = ""
    
    
    var imageLoadDataTask:URLSessionDataTask?
    
    func configureView() {
        if movie != nil {
            title = movie?.title
            imageView.image = UIImage(named:"placeholder_movie_detail")
            if let url = movie!.backdropURL {
                imageLoadDataTask = imageView.downloadedFrom(url: url)
            }
            else {
                self.tableView.tableHeaderView = nil
            }
        }
    }
    
    var order:[MovieDetailSection] = [.Title, .Duration, .Overview, .Genres, .Synopsis, .Language]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Book", style: .plain, target: self, action: #selector(bookTapped))
        
        configureView()
        
        WebServiceAPI.sharedInstance.getMovieDetails("\(movie!.id)") { (movie, isCompleted, error) in
            if let movie = movie {
                
                let oldMovieData = self.movie
                if let genresIds = oldMovieData?.genereIds, genresIds.count > 0  {
                     self.movie = movie
                     self.movie?.genereIds = oldMovieData!.genereIds
                }
               
                if let generes = self.movie?.genres {
                    var genres = [Int : String]()
                    let results =  generes
                    for result in results {
                        if let name = result[Constants.ServerKey.name] as? String {
                            let id = result[Constants.ServerKey.id] as! Int
                            genres[id] = name
                        }
                    }
                    
                    if genres.count > 0  {
                        self.genreMap = genres
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageLoadDataTask?.cancel()
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
    func bookTapped() {
        
        let svc = SFSafariViewController(url: URL(string:"https://www.cathaycineplexes.com.sg")!)
        self.present(svc, animated: true, completion: nil)
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "movieBookVC") as! MovieBookViewController
//        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    // MARK: Genres
    private func genreIdsToText(_ genres:[Int]) -> String {
        if genreMap.count == 0 {
            return ""
        }
        var genreText = [String]()
        for id in genres {
            if let genre = genreMap[id] {
                genreText += [genre]
            }
        }
        return genreText.joined(separator: ", ")
    }
    
    // MARK: Language
    private func getLanguage(_ languageSpoken: [[String: Any]]?) -> String {
        
        if languageSpoken != nil && languageSpoken?.count == 0 {
            return self.movieLanguage
        }
        
        var languageText = [String]()
        if (languageSpoken?.count)! > 0 {
            for language in languageSpoken! {
                languageText += [language[Constants.ServerKey.name] as! String]
            }
        }
        return languageText.joined(separator: ", ")
    }
    
    // MARK: Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.order.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieDetailCell
        
        cell.label.text = textForCell(indexPath:indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.order[section].rawValue
    }
    
    func textForCell(indexPath i:IndexPath) -> String {
        let section = self.order[i.section]
        
        switch section {
        case .Overview:
            return movie?.overview ?? "not available"
        case .Title:
            return movie?.title ?? "not available"
        case .Duration:
            if let runtime = movie?.runtime, runtime > 0 {
                return "\(runtime) minutes"
            }
            return "Not Available"
        case .Genres:
            return genreIdsToText((movie?.genereIds)!)
        case .Synopsis:
            if let synopsis = movie?.synopsis, synopsis != "" {
                return synopsis
            }
            return "Not Available"
        case .Language:
            if let languageSpoken = self.movie?.spokenLanguages {
               return getLanguage(languageSpoken)
            }
            return "Not Available"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
