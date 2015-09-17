//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
// TODO
// - synopsis on detail view needs to be scrollable
// - synopsis on detail view needs to be aligned to the top rather than middle
class MoviesViewController: UIViewController,
  UITableViewDataSource, UITableViewDelegate,
  UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
  private let movieCellIdentifier = "MovieCell"
  var movies: [Movie]?

  var client: RottenTomatoesClient!
  var searchController: UISearchController!

  @IBOutlet weak var tableView: UITableView!


  override func viewDidLoad() {
    super.viewDidLoad()
    prepareSearchController()

    client = RottenTomatoesClient()

    tableView.dataSource = self
    tableView.delegate   = self

    client.boxOffice() { movies -> Void in
      self.movies = movies
      self.tableView.reloadData()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(movieCellIdentifier, forIndexPath: indexPath) as! MovieCell

    let movie = movies![indexPath.row] // TODO forced unwrap

    cell.titleLabel.text    = movie.title
    cell.synopsisLabel.text = movie.synopsis
    cell.posterView.setImageWithURL(movie.posterImageUrl)

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }

  func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.dequeueReusableCellWithIdentifier(movieCellIdentifier, forIndexPath: indexPath) as! MovieCell
    UIView.animateWithDuration(2.0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
      cell.alpha = 0.2
    },
    completion: nil)
  }

  // MARK: - UISearchResultsUpdating

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    print("updateSearchResultsForSearchController")
  }

  // MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let cell = sender as! UITableViewCell

    let indexPath = tableView.indexPathForCell(cell)!
    let movie = movies![indexPath.row]

    let movieDetailsViewController = segue.destinationViewController as! MoviesDetailViewController
    movieDetailsViewController.movie = movie
  }

  // MARK: - Search Controller

  private func prepareSearchController() {
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.sizeToFit()

    tableView.tableHeaderView = searchController.searchBar
    tableView.contentOffset = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame))
  }
}
