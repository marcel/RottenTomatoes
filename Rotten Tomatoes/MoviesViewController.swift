//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController,
  UITableViewDataSource, UITableViewDelegate,
  UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,
  UITabBarDelegate {
  typealias Callback = () -> ()
  typealias SearchQuery = [String]

  // MARK: - Properties

  var movies: [Movie] {
    get {
      return _movies[urlToLoad].map { movies in
        searchQuery.map { queries in
          moviesMatchingSearchQuery(movies, searchQuery: queries)
        } ?? movies
      } ?? []
    }

    set {
      // TODO Succeptible to race condition if tab is changed before request is completed
      _movies[urlToLoad] = newValue
    }
  }

  private var _movies: [RottenTomatoesClient.ApiUrl: [Movie]]! = Dictionary<RottenTomatoesClient.ApiUrl, [Movie]>()

  var urlToLoad: RottenTomatoesClient.ApiUrl!
  let apiUrls = [
    RottenTomatoesClient.ApiUrl.BoxOffice, RottenTomatoesClient.ApiUrl.DVD
  ]

  var client: RottenTomatoesClient {
    get {
      if shouldSimulateRefresh {
        return RefreshSimulatingRottenTomatoesClient(_client)
      } else {
        return _client
      }
    }

    set {
      _client = newValue
    }
  }

  private var _client: RottenTomatoesClient!

  var searchController: UISearchController!
  var refreshControl: UIRefreshControl!
  var searchQuery: SearchQuery?
  var shouldSimulateRefresh = false

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tabBar: UITabBar!

  // MARK: - View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    prepareRefreshControl()
    prepareSearchController()
    prepareTabBar()
    presentLoadingProgress()

    client    = RottenTomatoesClient()
    urlToLoad = RottenTomatoesClient.ApiUrl.BoxOffice

    tableView.dataSource = self
    tableView.delegate   = self

    loadMovies() {
      KVNProgress.performSelectorOnMainThread("dismiss", withObject: nil, waitUntilDone: false)
    }
  }

  func reloadTable() {
    print("RELOAD TABLE")
    self.tableView.performSelectorOnMainThread("reloadData",
      withObject: nil,
      waitUntilDone: false
    )
  }

  func loadMovies(onCompletion: Callback? = nil) {
    client.load(urlToLoad) { movies in
      self.movies = movies ?? []
      self.reloadTable()
      onCompletion?()
    }
  }

  func presentLoadingProgress() {
    let config = KVNProgressConfiguration.defaultConfiguration()
    config.fullScreen = true
    KVNProgress.setConfiguration(config)
    KVNProgress.showWithStatus("Loading...")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** MEMORY WARNING ***")
  }

  // MARK: - UITabBar

  func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    let urlBeforeTabSelection = urlToLoad
    urlToLoad = apiUrls[tabBar.items!.indexOf(item)!]
    if urlBeforeTabSelection != urlToLoad {
      print("Switching to \(urlToLoad)")
      UIView.animateWithDuration(2.0, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.loadMovies()
        }, completion: { _ in () })

    }
  }

  func prepareTabBar() {
    tabBar.selectedItem = tabBar.items![0]
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }

  // TODO This could cause an index out of bounds error if something wonky
  // happens
  func movieAtIndexPath(indexPath: NSIndexPath) -> Movie {
    return movies[indexPath.row]
  }

  func cellAtIndexPath(indexPath: NSIndexPath) -> MovieCell {
    print("called cellAtIndexPath")
    let cell = tableView.dequeueReusableCellWithIdentifier(
      MovieCell.identifier,
      forIndexPath: indexPath
    ) as! MovieCell

    return cell.populatedFromMovie(movieAtIndexPath(indexPath))
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    print("calling from tableView:cellForRowAtIndexPath")
    let cell  = cellAtIndexPath(indexPath)
    let movie = movieAtIndexPath(indexPath)

    return cell.populatedFromMovie(movie) {
      UIView.animateWithDuration(2.0,
        delay: 0.0,
        options: UIViewAnimationOptions.CurveEaseIn,
        animations: {
          // Guard against race conditions
          if let _ = self.tableView.cellForRowAtIndexPath(indexPath) {
            self.tableView.reloadRowsAtIndexPaths(
              [indexPath],
              withRowAnimation: UITableViewRowAnimation.Fade
            )
          } else {
            print("NOPE: cell for row \(indexPath.row) gone") // TODO Figure out why this happens
          }
        },
        completion: { _ in () }
      )
      print("Hi-res image is loaded in row \(indexPath.row) for '\(movie.title)'")
    }
  }

  func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    print("TRACE: didEndDisplayingCell \(indexPath.row)")
  }

  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    print("TRACE: willDisplayCell \(indexPath.row)")
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }

  func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
    // let cell = cellAtIndexPath(indexPath)

    // TODO Do something here
  }

  // MARK: - UISearchResultsUpdating

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let enteredText    = searchController.searchBar.text!
    let whitespace     = NSCharacterSet.whitespaceCharacterSet()
    let strippedString = enteredText.stringByTrimmingCharactersInSet(whitespace)
    print("Search query: '\(enteredText)'")

    if strippedString.isEmpty {
      searchQuery = nil
    } else {
      searchQuery = strippedString.componentsSeparatedByString(" ") as [String]
    }

    reloadTable()
  }

  func moviesMatchingSearchQuery(movies: [Movie], searchQuery: SearchQuery) -> [Movie] {
    return movies.filter { movie in
      let movieText = [movie.title, movie.synopsis]

      return searchQuery.any { query in
        movieText.any { text in
          text.localizedCaseInsensitiveContainsString(query)
        }
      }
    }
  }

  // MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let cell = sender as! UITableViewCell

    let indexPath = tableView.indexPathForCell(cell)!
    let movie     = movieAtIndexPath(indexPath)

    let movieDetailsViewController   = segue.destinationViewController as! MoviesDetailViewController
    movieDetailsViewController.movie = movie

    cleanUpViewBeforeSegue()
  }

  func cleanUpViewBeforeSegue() {
    searchController.active = false
  }

  // TODO: 
  // - When pushing into detail view make search bar disappear but preserve search results
  // MARK: - UISearchController

  private func prepareSearchController() {
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.sizeToFit()

    tableView.tableHeaderView = searchController.searchBar
    tableView.contentOffset   = CGPointMake(0, CGRectGetHeight(searchController.searchBar.frame))
  }

  // MARK: - UIRefreshControl

  private func prepareRefreshControl() {
    refreshControl = UIRefreshControl()

    refreshControl.addTarget(self,
      action: "onRefresh",
      forControlEvents: UIControlEvents.ValueChanged
    )

    tableView.insertSubview(refreshControl, atIndex: 0)
    // N.B. Must be invoked after the refreshControl has been inserted
    insertConsistantBackgroundColorView()
  }

  // N.B. This is a work around to deal with the default mix of grey and white
  // in the background when pulling down on the refresh control. This keeps the background
  // against which the refresh control is displayed a single uniform color.
  func insertConsistantBackgroundColorView() {
    var backgroundViewFrame = tableView.bounds
    backgroundViewFrame.origin.y = -backgroundViewFrame.size.height

    let backgroundColorView = UIView(frame: backgroundViewFrame)
    backgroundColorView.backgroundColor = tableView.backgroundColor

    tableView.insertSubview(backgroundColorView, atIndex: 0)
  }

  func onRefresh() {
    simulatingRefresh {
      self.loadMovies() {
        self.refreshControl.endRefreshing()
      }
    }
  }

  func simulatingRefresh(callback: Callback) {
    shouldSimulateRefresh = true
    callback()
    shouldSimulateRefresh = false
  }
}
