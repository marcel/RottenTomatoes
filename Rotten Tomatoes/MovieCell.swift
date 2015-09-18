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

  func populatedFromMovie(movie: Movie, onCompletion: (() -> ())? = nil) -> MovieCell {
    titleLabel.text    = movie.title
    synopsisLabel.text = movie.synopsis
    print("populatedFromMovie: '\(movie.title)'")
    
    if let posterImage = movie.posterImage {
      print("Image already set: '\(movie.title)'")
      posterView.image = posterImage
      onCompletion?()
    } else {
      print("Loading image for '\(movie.title)'...")
      loadPosterImage(movie, onCompletion: onCompletion)
    }

    return self
  }

  func loadPosterImage(movie: Movie, onCompletion: (() -> ())?) {
    let lowResRequest  = RequestFactory.mkRequest(movie.posterImageThumbnailUrl)
    let highResRequest = RequestFactory.mkRequest(movie.posterImageUrl)
    
    self.posterView.setImageWithURLRequest(lowResRequest,
      placeholderImage: nil,
      success: { (request, response, image) in
        print("Success (lo-res): '\(movie.title)'")
        self.posterView.setImageWithURLRequest(highResRequest,
          placeholderImage: image,
          success: { (request, response, image) in
            movie.posterImage = image
            print("Success (hi-res): '\(movie.title)'")
            onCompletion?()
          },
          failure: { (request, response, _) in
            movie.posterImage = nil
            print("Failure (hi-res): '\(movie.title)'")
        })
      },
      failure: { (request, response, _) in
        print("Failure (lo-res): '\(movie.title)'")
      }
    )
  }
}
