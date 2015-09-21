//
//  MoviesGridViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MoviesGridViewController: UICollectionViewController {
  var movies: [Movie]!
  
  @IBOutlet weak var layoutSwitcherControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad in MoviesGridViewController")
    navigationItem.hidesBackButton = true
  }

  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = false
    tabBarController?.hidesBottomBarWhenPushed = false
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    print("Segueing from Grid View")
    let cell = sender as! UICollectionViewCell

    let indexPath = collectionView!.indexPathForCell(cell)!
    let movie     = movieAtIndexPath(indexPath)

    let movieDetailsViewController   = segue.destinationViewController as! MoviesDetailViewController
    movieDetailsViewController.movie = movie
  }

  @IBAction func switchBackToListView() {
    print("switchBackToListView")
    // TODO setting these segment indexes is a jank work around
    layoutSwitcherControl.selectedSegmentIndex = 1
    let currentIndex = (navigationController?.viewControllers.count)!
    let listController = navigationController?.viewControllers[currentIndex-2] as! MoviesViewController
    listController.layoutSwitcherControl.selectedSegmentIndex = 0

    scrollListViewToCurrentPosition(listController.tableView)
    navigationController?.popViewControllerAnimated(true)
  }

  private func scrollListViewToCurrentPosition(tableView: UITableView) {
    if let visibleItems = collectionView?.indexPathsForVisibleItems(), first = visibleItems.first {
      let scrollTo = first.row == 0 ? first : visibleItems[visibleItems.count/2]

      tableView.scrollToRowAtIndexPath(
        scrollTo,
        atScrollPosition: UITableViewScrollPosition.Middle,
        animated: false
      )
    }
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movies.count
  }

  func cellAtIndexPath(collectionView: UICollectionView, indexPath: NSIndexPath) -> MoviesGridCell {
    return collectionView.dequeueReusableCellWithReuseIdentifier(
      MoviesGridCell.identifier,
      forIndexPath: indexPath
    ) as! MoviesGridCell
  }

  override func collectionView(
    collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath
  ) -> UICollectionViewCell {
    let cell = cellAtIndexPath(collectionView, indexPath: indexPath)

    let movie = movieAtIndexPath(indexPath)
    cell.populatedFromMovie(movie)
    return cell
  }

  func movieAtIndexPath(indexPath: NSIndexPath) -> Movie {
    return movies[indexPath.row]
  }
}
