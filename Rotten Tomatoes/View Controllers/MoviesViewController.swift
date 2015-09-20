//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import KVNProgress

class MoviesViewController: UIViewController,
  UITableViewDataSource, UITableViewDelegate,
  UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,
  UITabBarDelegate {

  enum Segue: String {
    case MoviesDetail
    case DropDownAlert
    case ListViewToGridView
  }

  // MARK: - Properties

  let apiUrls = [
    RottenTomatoesClient.ApiUrl.BoxOffice, RottenTomatoesClient.ApiUrl.DVD
  ]

  var movieRepository: MovieRepository!
  var searchController: UISearchController!
  var refreshControl: UIRefreshControl!

  // MARK: - Outlets

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tabBar: UITabBar!
  @IBOutlet weak var layoutSwitcherControl: UISegmentedControl!

  // MARK: - Actions

  @IBAction func switchLayout(sender: AnyObject) {
    print("switchLayout")
    performSegueWithIdentifier(Segue.ListViewToGridView.rawValue, sender: self)
  }

  // MARK: - View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    prepareRefreshControl()
    prepareSearchController()
    prepareTabBar()
    prepareLoadingProgress()
    presentLoadingProgress()

    movieRepository = MovieRepository()
    movieRepository.urlToLoad = urlForSelectedTabBar()

    tableView.dataSource = self
    tableView.delegate   = self

    print("Network reachable? \(NetworkReachability.isConnectedToNetwork())")
    if NetworkReachability.isConnectedToNetwork() {
      movieRepository.loadMovies() {
        self.dismissLoadingProgress()
        self.reloadTable()
      }
    } else {
      KVNProgress.showErrorWithStatus("No Network")
    }
  }

  func reloadTable() {
    print("RELOAD TABLE")
    self.tableView.performSelectorOnMainThread("reloadData",
      withObject: nil,
      waitUntilDone: false
    )
  }

  func prepareLoadingProgress() {
    let config = KVNProgressConfiguration.defaultConfiguration()
    config.fullScreen = true
    config.minimumErrorDisplayTime = 3
    config.minimumDisplayTime = 1

    KVNProgress.setConfiguration(config)
  }

  func presentLoadingProgress() {
    KVNProgress.performSelectorOnMainThread("showWithStatus:",
      withObject: "Loading...",
      waitUntilDone: false
    )
  }

  func dismissLoadingProgress() {
    KVNProgress.performSelectorOnMainThread("dismiss",
      withObject: nil,
      waitUntilDone: false
    )
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** MEMORY WARNING ***")
  }

  // MARK: - UITabBar

  func urlForSelectedTabBar() -> RottenTomatoesClient.ApiUrl {
    return apiUrls[tabBar.items!.indexOf(tabBar.selectedItem!)!]
  }

  func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    let urlBeforeTabSelection = movieRepository.urlToLoad
    
    movieRepository.urlToLoad = urlForSelectedTabBar()
    if urlBeforeTabSelection != movieRepository.urlToLoad {
      print("Switching to \(movieRepository.urlToLoad)")

      let isFirstTimeLoadingTab = !movieRepository.hasLoadedUrl()

      if isFirstTimeLoadingTab {
        presentLoadingProgress()
      }

      let selectedBarItemIsOnLeft = tabBar.items!.indexOf(item)! == 0

      let animationDirection = selectedBarItemIsOnLeft ?
        UIViewAnimationOptions.TransitionFlipFromLeft  :
        UIViewAnimationOptions.TransitionFlipFromRight

      movieRepository.loadMovies() {
        if isFirstTimeLoadingTab {
          self.dismissLoadingProgress()
          self.reloadTable()
        } else {
          UIView.transitionWithView(
            self.tableView,
            duration: 0.5,
            options: [animationDirection, .AllowAnimatedContent],
            animations: { self.reloadTable() },
            completion: nil
          )
        }
      }
    }
  }

  func prepareTabBar() {
    tabBar.selectedItem = tabBar.items![0]
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movieRepository.movies.count
  }

  // TODO This could cause an index out of bounds error if something wonky
  // happens
  func movieAtIndexPath(indexPath: NSIndexPath) -> Movie {
    return movieRepository.movies[indexPath.row]
  }


  func cellAtIndexPath(indexPath: NSIndexPath) -> MovieCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      MovieCell.identifier,
      forIndexPath: indexPath
    ) as! MovieCell

    return cell
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell  = cellAtIndexPath(indexPath)
    let movie = movieAtIndexPath(indexPath)
    return cell.populatedFromMovie(movie)
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }

  // MARK: - UISearchResultsUpdating

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let enteredText    = searchController.searchBar.text!
    let whitespace     = NSCharacterSet.whitespaceCharacterSet()
    let strippedString = enteredText.stringByTrimmingCharactersInSet(whitespace)
    print("Search query: '\(enteredText)'")

    if strippedString.isEmpty {
      movieRepository.searchQuery = nil
    } else {
      movieRepository.searchQuery = strippedString.componentsSeparatedByString(" ") as [String]
    }

    reloadTable()
  }

  // MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier! {

    case Segue.MoviesDetail.rawValue:
      prepareMoviesDetailSegue(segue, cell: sender as! UITableViewCell)
    case Segue.DropDownAlert.rawValue:
      prepareDropDownAlertSegue(segue)
    case Segue.ListViewToGridView.rawValue:
      prepareLayoutSwitchSegue(segue)
      print("Going from list view to grid view")
    default:
      ()
    }
  }

  func prepareMoviesDetailSegue(segue: UIStoryboardSegue, cell: UITableViewCell) {
    let indexPath = tableView.indexPathForCell(cell)!
    let movie     = movieAtIndexPath(indexPath)

    let movieDetailsViewController   = segue.destinationViewController as! MoviesDetailViewController
    movieDetailsViewController.movie = movie

    cleanUpViewBeforeSegue()
  }

  func prepareDropDownAlertSegue(segue: UIStoryboardSegue) {
    let dropDownAlertController = segue.destinationViewController as! DropDownAlertViewController
    let dropDownAlertView = dropDownAlertController.view as! DropDownAlertView

    dropDownAlertView.messageLabel.text = "Network is Unreachable"
  }

  func prepareLayoutSwitchSegue(segue: UIStoryboardSegue) {
    let gridViewController = segue.destinationViewController as! MoviesGridViewController
    gridViewController.movieRepository = movieRepository
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
    movieRepository.simulatingNewResults() {
      if NetworkReachability.isConnectedToNetwork() {
        self.movieRepository.loadMovies() {
          self.reloadTable()
          self.refreshControl.endRefreshing()
        }
      } else {
        self.refreshControl.endRefreshing()
        self.performSegueWithIdentifier(
          Segue.DropDownAlert.rawValue,
          sender: self
        )
      }
    }
  }
}
