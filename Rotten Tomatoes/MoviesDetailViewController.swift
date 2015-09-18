//
//  MoviesDetailViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MoviesDetailViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisText: UITextView!
  @IBOutlet weak var textContainerView: UIView!
  @IBOutlet weak var dragHandle: UILabel!

  var movie: Movie!

  var minTextContainerViewY: CGFloat!

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text   = movie.title
    synopsisText.text = movie.synopsis
    imageView.setImageWithURL(movie.posterImageUrl)
    minTextContainerViewY = textContainerView.frame.origin.y
  }

  func max(lhs: CGFloat, _ rhs: CGFloat) -> CGFloat {
    return lhs > rhs ? lhs : rhs
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
  @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translationInView(view)

    let maxY = minTextContainerViewY + textContainerView.frame.height - dragHandle.frame.height
    let yAfterTranslation = textContainerView.frame.origin.y + translation.y

    if yAfterTranslation <= maxY && yAfterTranslation >= minTextContainerViewY {
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
