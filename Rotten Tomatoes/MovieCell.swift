//
//  MovieCell.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
  static let identifier = "MovieCell"

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisLabel: UILabel!
  @IBOutlet weak var posterView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    print("Preparing for reuse: \(titleLabel.text), \(posterView.image)")
  }

  func populatedFromMovie(movie: Movie) -> MovieCell {
    print("populatedFromMovie: '\(movie.title)'")

    titleLabel.text    = movie.title
    synopsisLabel.text = movie.synopsis
    print("About to load image: '\(movie.title)'")
    movie.loadPosterImageIntoView(posterView)
    print("Image loading started: '\(movie.title)'")
    return self
  }
}
