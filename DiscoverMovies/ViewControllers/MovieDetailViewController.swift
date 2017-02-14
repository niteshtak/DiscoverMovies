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
    
    var imageLoadDataTask:URLSessionDataTask?
    
    func configureView() {
        if movie != nil {
            title = movie?.title
            imageView.image = UIImage(named:"placeholder_wide")
            if let url = movie!.backdropURL {
                imageLoadDataTask = imageView.downloadedFrom(url: url)
            }
            else {
                self.tableView.tableHeaderView = nil
            }
        }
    }
    
    var order:[MovieDetailSection] = [.Title, .Overview]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageLoadDataTask?.cancel()
        super.viewWillDisappear(animated)
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
