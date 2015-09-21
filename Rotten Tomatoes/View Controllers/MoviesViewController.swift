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

  typealias MovieSortDescriptor = MovieRepository.SortDescriptor

  // MARK: Enums

  enum Segue: String {
    case MoviesDetail
    case DropDownAlert
    case ListViewToGridView
  }

  // MARK: - Properties

  let apiUrls = [
    RottenTomatoesClient.ApiUrl.BoxOffice, RottenTomatoesClient.ApiUrl.DVD
  ]

  let sortDescriptorsMappedToSortControl = [
    MovieSortDescriptor.ReleaseDate, MovieSortDescriptor.Title, MovieSortDescriptor.Rating
  ]

  var movieRepository: MovieRepository!
  var searchController: UISearchController!
  var refreshControl: UIRefreshControl!

  // MARK: - Outlets

  @IBOutlet weak var sortControlContainer: UIView!
  @IBOutlet weak var sortButton: UIBarButtonItem!
  @IBOutlet weak var sortControlView: UIView!
  @IBOutlet weak var sortControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tabBar: UITabBar!
  @IBOutlet weak var layoutSwitcherControl: UISegmentedControl!

  // MARK: - Actions

  @IBAction func switchLayout(sender: AnyObject) {
    print("switchLayout")
    performSegueWithIdentifier(Segue.ListViewToGridView.rawValue, sender: self)
  }

  @IBAction func toggleSortControl() {
    print("toggleSortControl")

    sortButton.enabled = false
    let header = tableView.tableHeaderView!
    if sortControlContainer.alpha == 0 {
      header.bringSubviewToFront(sortControlContainer)
      UIView.easeIn({
        self.sortControlContainer.alpha = 1
      },
        completion: { _ in
          self.sortButton.enabled = true
        }
      )
    } else {
      UIView.easeOut({
        self.sortControlContainer.alpha = 0
      },
        completion: { _ in
          self.sortButton.enabled = true
          header.sendSubviewToBack(self.sortControlContainer)
      })
    }
  }

  // MARK: - View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    prepareSortControl()
    prepareRefreshControl()
    prepareSearchController()
    prepareTabBar()
    prepareLoadingProgress()
    presentLoadingProgress()

    movieRepository = MovieRepository()

    tableView.dataSource = self
    tableView.delegate   = self

    print("Network reachable? \(NetworkReachability.isConnectedToNetwork())")
    if NetworkReachability.isConnectedToNetwork() {
      movieRepository.loadMovies(urlForSelectedTabBar()) {
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

  func prepareSortControl() {
    sortControlContainer.alpha = 0
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
    let urlToLoad = urlForSelectedTabBar()
    print("Switching to \(urlToLoad)")

    let isFirstTimeLoadingTab = !movieRepository.hasLoadedUrl(urlToLoad)

    if isFirstTimeLoadingTab {
      presentLoadingProgress()
    }

    let selectedBarItemIsOnLeft = tabBar.items!.indexOf(item)! == 0

    let animationDirection = selectedBarItemIsOnLeft ?
      UIViewAnimationOptions.TransitionFlipFromLeft  :
      UIViewAnimationOptions.TransitionFlipFromRight

    movieRepository.loadMovies(urlToLoad) {
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

  func prepareTabBar() {
    tabBar.selectedItem = tabBar.items![0]
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movieRepository.moviesFor(urlForSelectedTabBar()).count
  }

  // TODO This could cause an index out of bounds error if something wonky
  // happens
  func movieAtIndexPath(indexPath: NSIndexPath) -> Movie {
    return movieRepository.moviesFor(urlForSelectedTabBar())[indexPath.row]
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
    print("Going from list view to grid view")

    let gridViewController = segue.destinationViewController as! MoviesGridViewController
    gridViewController.movies = movieRepository.moviesFor(urlForSelectedTabBar())

    updateGridViewToCurrentScrollPosition(gridViewController)
  }

  func updateGridViewToCurrentScrollPosition(gridViewController: MoviesGridViewController) {
    if let visibleRows = tableView.indexPathsForVisibleRows {
      if visibleRows.first?.row != 0 {
        let indexPathForMiddleVisibleRow = visibleRows[visibleRows.count/2]
        gridViewController.collectionView?.scrollToItemAtIndexPath(
          indexPathForMiddleVisibleRow,
          atScrollPosition: UICollectionViewScrollPosition.CenteredVertically,
          animated: false
        )
      }
    }
  }

  func cleanUpViewBeforeSegue() {
    searchController.active = false
  }

  // MARK: - Sorting

  @IBAction func updateSorting() {
    let selectedSortDescriptor = sortDescriptorsMappedToSortControl[sortControl.selectedSegmentIndex]
    print("Sort descriptor changed to \(selectedSortDescriptor)")

    movieRepository.sortDescriptor = selectedSortDescriptor
    reloadTable()
  }


  // MARK: - UISearchController

  // TODO:
  // - When pushing into detail view make search bar disappear but preserve search results
  
  private func prepareSearchController() {
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.sizeToFit()

    tableView.tableHeaderView?.addSubview(searchController.searchBar)

    tableView.contentOffset = CGPointMake(0, -CGRectGetHeight(searchController.searchBar.frame))
  }

  // MARK: - UIRefreshControl

  private func prepareRefreshControl() {
    refreshControl = UIRefreshControl()

    refreshControl.addTarget(self,
      action: "onRefresh",
      forControlEvents: UIControlEvents.ValueChanged
    )

    tableView.insertSubview(refreshControl, atIndex: 0)
  }

  func onRefresh() {
    let urlToLoad = urlForSelectedTabBar()
    movieRepository.simulatingNewResults(urlToLoad) {
      if NetworkReachability.isConnectedToNetwork() {
        self.movieRepository.loadMovies(urlToLoad) {
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
