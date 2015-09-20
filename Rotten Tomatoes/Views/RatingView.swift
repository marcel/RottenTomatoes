//
//  RatingsView.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/20/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class RatingView: UIView {
  @IBOutlet weak var score: UILabel!
  @IBOutlet weak var ratingImage: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func populateFromRating(rating: Movie.Rating) {
    if let score = rating.score {
      self.score.text = "\(score)%"
    }

    if let rating = rating.rating {
      let imageName = "\(rating.rawValue)-16.png"
      ratingImage.image = UIImage(named: imageName)
    } else {
      ratingImage.hidden = true
    }
  }
}