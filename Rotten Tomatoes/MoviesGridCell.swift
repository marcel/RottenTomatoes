//
//  MoviesGridCell.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MoviesGridCell: UICollectionViewCell {
  static let identifier = "MoviesGridCell"
  
  @IBOutlet weak var posterImage: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

  func populatedFromMovie(movie: Movie) -> MoviesGridCell {
    print("MoviesGridCell.posterImage: \(posterImage)")
    if let image = movie.posterImage {
      posterImage.image = image
    } else {
      posterImage.setImageWithURL(movie.posterImageUrl)
    }
    titleLabel.text = movie.title

    return self
  }
}
