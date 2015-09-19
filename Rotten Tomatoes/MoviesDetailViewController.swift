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

  var movie: Movie!

  var minTextContainerViewY: CGFloat!
  var maxTextContainerViewY: CGFloat! {
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
    if let posterImage = movie.posterImage {
      imageView.image = posterImage
    } else {
      imageView.setImageWithURL(movie.posterImageUrl)
    }

    minTextContainerViewY = textContainerView.frame.origin.y
  }

  func max(lhs: CGFloat, _ rhs: CGFloat) -> CGFloat {
    return lhs > rhs ? lhs : rhs
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
  @IBAction func toggleText(sender: AnyObject) {
    let containerFrame        = textContainerView.frame
    let textContainerMidpoint = minTextContainerViewY + (containerFrame.height / 2)

    UIView.easeIn({
      // It's below the half way point so toggle up
      if containerFrame.origin.y > textContainerMidpoint {
        self.textContainerView.frame = CGRectOffset(
          containerFrame,
          0,
          -(containerFrame.origin.y - self.minTextContainerViewY)
        )
        self.navigationController?.navigationBar.alpha = 1
      // It's above the half way point so toggle down
      } else {
        self.textContainerView.frame = CGRectOffset(
          containerFrame,
          0,
          +(self.maxTextContainerViewY - containerFrame.origin.y)
        )
        self.navigationController?.navigationBar.alpha = 0
      }
    })
  }

  @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translationInView(view)

    let yAfterTranslation = textContainerView.frame.origin.y + translation.y

    if yAfterTranslation <= maxTextContainerViewY && yAfterTranslation >= minTextContainerViewY {
      UIView.animateWithDuration(
        0.5,
        delay: 0,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1,
        options: [],
        animations: {
          self.textContainerView.frame = CGRectOffset(self.textContainerView.frame, 0, translation.y)
          recognizer.setTranslation(CGPointZero, inView: self.view)
        }, completion: { b in () }
      )
    }
  }
}
