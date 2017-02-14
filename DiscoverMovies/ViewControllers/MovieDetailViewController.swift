//
//  MovieDetailViewController.swift
//  DiscoverMovies
//
//  Created by NiteshTak on 12/2/17.
//  Copyright © 2017 NiteshTak. All rights reserved.
//

import UIKit


class MovieDetailViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var movie: Movie?
    private var genreMap = [Int : String]()
    
    
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
    
    var order:[MovieDetailSection] = [.Title, .Overview, .Genres, .Synopsis]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        WebServiceAPI.sharedInstance.getMovieDetails("\(movie!.id)") { (movie, isCompleted, error) in
            if let movie = movie {
                self.movie = movie
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
        case .Genres:
            return genreIdsToText((movie?.genres)!)
        case .Synopsis:
            return movie?.synopsis ?? "not available"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
