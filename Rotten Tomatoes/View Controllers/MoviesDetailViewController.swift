//
//  MoviesDetailViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MoviesDetailViewController: UIViewController {

  @IBOutlet weak var navigationBarTitle: UINavigationItem!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisText: UITextView!
  @IBOutlet weak var textContainerView: UIView!
  @IBOutlet weak var dragHandle: UILabel!
  @IBOutlet weak var mpaaRatingLabel: UILabel!
  @IBOutlet weak var criticsRating: RatingView!
  @IBOutlet weak var audienceRating: RatingView!

  var movie: Movie!

  private var minTextContainerViewY: CGFloat!
  private var maxTextContainerViewY: CGFloat! {
    return minTextContainerViewY +
      textContainerView.frame.height -
      dragHandle.frame.height
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBarTitle.title = movie.title

    titleLabel.text      = movie.title
    synopsisText.text    = movie.synopsis
    mpaaRatingLabel.text = movie.mpaaRating
    mpaaRatingLabel.sizeToFit()
    criticsRating.populateFromRating(movie.criticsRating)
    audienceRating.populateFromRating(movie.audienceRating)
    movie.loadPosterImageIntoView(imageView)

    minTextContainerViewY = textContainerView.frame.origin.y
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func toggleText(sender: AnyObject) {
    let containerFrame = textContainerView.frame
    let maxY = maxTextContainerViewY
    let minY = minTextContainerViewY

    let textContainerMidpoint = minY + (containerFrame.height / 2)
    let rectOffset = { yOffset in
      CGRectOffset(containerFrame, 0, yOffset)
    }

    UIView.easeIn({
      // It's below the half way point so toggle up
      if containerFrame.origin.y > textContainerMidpoint {
        self.textContainerView.frame = rectOffset(-(containerFrame.origin.y - minY))
        self.navigationController?.navigationBar.alpha = 1
      // It's above the half way point so toggle down
      } else {
        self.textContainerView.frame = rectOffset(maxY - containerFrame.origin.y)
        self.navigationController?.navigationBar.alpha = 0
      }
    })
  }

  @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translationInView(view)

    let yAfterTranslation = textContainerView.frame.origin.y + translation.y
    let moveIsWithinMinMaxBounds = yAfterTranslation <= maxTextContainerViewY && yAfterTranslation >= minTextContainerViewY

    if moveIsWithinMinMaxBounds {
      UIView.animateWithDuration(
        0.5,
        delay: 0,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1,
        options: [],
        animations: {
          self.textContainerView.frame = CGRectOffset(self.textContainerView.frame, 0, translation.y)
          recognizer.setTranslation(CGPointZero, inView: self.view)
        },
        completion: nil
      )
    }
  }
}
