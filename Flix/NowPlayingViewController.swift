//
//  NowPlayingViewController.swift
//  Flix
//
//  Created by Denny Ho on 9/10/18.
//  Copyright © 2018 Denny Ho. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    // Right before the ViewController "appears"...
    override func viewWillAppear(_ animated: Bool) {
        // hide feed ImageView
        tableView.isHidden = true
        // turn on the activity indicator
        activityIndicator.startAnimating()
    }
    // The moment the ViewController "appears"...
    override func viewDidAppear(_ animated: Bool) {
        
        // Delay for 2 seconds, then run the code between the braces.
        let secondsToDelay = 0.95
        run(after: secondsToDelay) {
            self.tableView.isHidden = false
            // Stop the activity indicator
            self.activityIndicator.stopAnimating()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 173
        self.tableView.reloadData();
        refreshControl = UIRefreshControl()
        fetchMovies()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for:  .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

    }
    
    @objc func didPullToRefresh(_ refreshControl:UIRefreshControl){
        fetchMovies()
    }
    

    func fetchMovies(){
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url) { (data, response, error) in
            //This will run network request returns
            if let error = error {
                let alertView = UIAlertView(title: "Networking Error", message: "The internet connection appears to be offline", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                alertView.show()
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String:Any]]
                self.movies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
        
            }
        }
        task.resume()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
