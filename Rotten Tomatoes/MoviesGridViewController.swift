//
//  MoviesGridViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MoviesGridViewController: UICollectionViewController {
  var movieRepository: MovieRepository!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad in MoviesGridViewController")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    print("Segueing from Grid View")
    let cell = sender as! UICollectionViewCell

    let indexPath = collectionView!.indexPathForCell(cell)!
    let movie     = movieAtIndexPath(indexPath)

    let movieDetailsViewController   = segue.destinationViewController as! MoviesDetailViewController
    movieDetailsViewController.movie = movie
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }


  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movieRepository.movies.count
  }

  override func collectionView(
    collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
      MoviesGridCell.identifier,
      forIndexPath: indexPath
    ) as! MoviesGridCell

    let movie = movieAtIndexPath(indexPath)
    cell.populatedFromMovie(movie)
    collectionView.reloadItemsAtIndexPaths([indexPath])
    return cell
  }

  func movieAtIndexPath(indexPath: NSIndexPath) -> Movie {
    return movieRepository.movies[indexPath.row]
  }

  // MARK: UICollectionViewDelegate

//  // Uncomment this method to specify if the specified item should be highlighted during tracking
//  override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//    return false
//  }
//
//  // Uncomment this method to specify if the specified item should be selected
//  override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//    return false
//  }


  /*
  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
      return false
  }

  override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
      return false
  }

  override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
  
  }
  */

}