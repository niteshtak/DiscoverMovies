//
//  MovieListViewController.swift
//  DiscoverMovies
//
//  Created by NiteshTak on 12/2/17.
//  Copyright © 2017 NiteshTak. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class MovieListViewController: UITableViewController{
 
    private var movies = [Movie]()
   
    var communicationError = false
    var loadInProgress = false
    
    private var page = 0
    
    // total_pages from API response
    private var maxPage = 13806
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovies(currentPage: page)
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Discover Movies"
        setupReachabilityWatcher()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = " " // so back button doesn't waste space on navigation bar
        super.viewWillDisappear(animated)
        AFNetworkReachabilityManager.shared().stopMonitoring()
    }
    
    func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    @objc private func refreshMovies() {
        page = 0
        loadMovies(currentPage: page)
    }
    
    // MARK: - WebServiceAPI
    
    private func loadMovies(currentPage:Int) {
        if self.loadInProgress || currentPage >= maxPage {
            return
        }
        
        if currentPage <= 1 {
            MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        }
        else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
            let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator.activityIndicatorViewStyle = .gray
            indicator.center = view.center
            indicator.startAnimating()
            view.addSubview(indicator)
            
            tableView.tableFooterView = view
        }
        
        self.loadInProgress = true
        WebServiceAPI.sharedInstance.getMoviesByReleaseDate(page: currentPage + 1) { (movies:[Movie], pages:Int, error: Error?) in
            self.handleMoviesResponse(movies: movies, pages: pages, error: error)
        }
    }
    
    private func handleMoviesResponse(movies:[Movie], pages:Int, error:Error?) {
        loadInProgress = false
        
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
        
        MBProgressHUD.hide(for: self.navigationController!.view, animated: true)
        tableView.tableFooterView = nil
        
        if error != nil {
            return
        }
        
        page += 1
        maxPage = min(pages, self.maxPage)
        
        // insert new rows
        let count = self.movies.count
        let additional = movies.count
        
        var paths = [IndexPath]()
        for i in count..<(count + additional) {
            paths += [IndexPath(row: i, section: 0)]
        }
        
        self.movies += movies
        
        self.tableView.insertRows(at: paths, with: .fade)
        
        if self.movies.count == 0 {
            showNoResultsView()
        }
        else {
            tableView.tableFooterView = nil
        }
    }
    
    private func showNoResultsView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        let label = UILabel(frame: view.frame.insetBy(dx: 10, dy: 10))
        label.text = "No Results Found"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.minimumScaleFactor = 0.4
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.center = view.center
        view.addSubview(label)
        tableView.tableFooterView = view
    }
    
    private func setupReachabilityWatcher() {
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status:AFNetworkReachabilityStatus) in
            if status != AFNetworkReachabilityStatus.notReachable {
                if self.movies.count == 0 {
                    self.page = 0
                    self.loadMovies(currentPage: self.page)
                    return
                }
                
                // Reload visible rows in case internet connection was lost while displaying them
                if self.communicationError {
                    if let paths = self.tableView.indexPathsForVisibleRows {
                        self.communicationError = false
                        self.tableView.reloadRows(at: paths, with: .none)
                    }
                }
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let movie = movies[indexPath.row]
                let controller = segue.destination as! MovieDetailViewController
                controller.movie = movie
            }
        }
    }
    
    // MARK: - Table View Data Source and Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MovieListCell
        
        let movie = movies[indexPath.row]
        cell.textLabel!.text = movie.title
        cell.detailTextLabel!.text = "Popularity: " + String(describing: movie.popularity)
        
        cell.imageURL = movie.thumbnailURL
        
        if indexPath.row >= movies.count - 1 {
            loadMovies(currentPage:page)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! MovieListCell).cancelImageLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // If memory warning remove excess movies
        if movies.count > 20 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            movies.removeSubrange(Range(uncheckedBounds: (lower: 20, upper: movies.count - 1)))
            tableView.reloadData()
        }
    }
}
