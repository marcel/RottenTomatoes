//
//  Movie.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class Movie {
  struct Rating {
    enum Rating: String {
      case Rotten = "Rotten"
      case Fresh  = "Fresh"
      case CertifiedFresh = "Certified Fresh"
      case Upright = "Upright"
      case Spilled = "Spilled"
    }

    let rating: Rating
    let score: Int
  }

  private var posterImageLoadingSemaphore = dispatch_semaphore_create(1)
  private let data: NSDictionary

  let title: String
  let synopsis: String

  let posterImageUrl: NSURL
  var posterImage: UIImage?
  let posterImageThumbnailUrl: NSURL
  var posterImageThumbnail: UIImage?

  let mpaaRating: String
//  let audienceRating: Rating
//  let criticRating: Rating

  private let lowResRequest: NSURLRequest
  private let highResRequest: NSURLRequest

  static func convertPostertImageUrlToHighResVersion(url: String) -> String {
    if let range = url.rangeOfString(".*cloudfront8?.net/", options: .RegularExpressionSearch) {
      return url.stringByReplacingCharactersInRange(
        range,
        withString: "https://content6.flixster.com/"
      )
    } else {
      return url
    }
  }

  convenience init(data: NSDictionary) {
    let title    = data["title"] as! String
    let synopsis = data["synopsis"] as! String

    let lowResUrl  = data.valueForKeyPath("posters.thumbnail") as! String
    let highResUrl = Movie.convertPostertImageUrlToHighResVersion(lowResUrl)

    let mpaaRating = data["mpaa_rating"] as! String
//    let audienceRating = Rating(rating: Rating.Rating.fromRaw(data["]

    self.init(
      data: data,
      title: title,
      synopsis: synopsis,
      posterImageUrl: (NSURL(string: highResUrl)!),
      posterImageThumbnailUrl: (NSURL(string: lowResUrl)!),
      mpaaRating: mpaaRating
    )
  }

  init(
    data: NSDictionary,
    title: String,
    synopsis: String,
    posterImageUrl: NSURL,
    posterImageThumbnailUrl: NSURL,
    mpaaRating: String
  ) {
    self.data           = data
    self.title          = title
    self.synopsis       = synopsis
    self.posterImageUrl = posterImageUrl
    self.posterImageThumbnailUrl = posterImageThumbnailUrl
    self.mpaaRating = mpaaRating

    self.lowResRequest  = RequestFactory.mkRequest(posterImageThumbnailUrl)
    self.highResRequest = RequestFactory.mkRequest(posterImageUrl)
  }
  }

  func loadPosterImageIntoView(imageView: UIImageView) {
    print("loadPosterImageIntoView: '\(title)'")
    if let posterImage = posterImage {
      print("Image already set: '\(title)'")
      imageView.image = posterImage

    } else {
      print("Loading image for '\(title)' from network")
      if let thumbnail = posterImageThumbnail {
        imageView.image = thumbnail
      }
      loadPosterImageIntoViewFromNetwork(imageView)
    }
  }

  private func loadPosterImageIntoViewFromNetwork(imageView: UIImageView) {
    if let placeholder = posterImageThumbnail {
      loadHighResPosterImage(imageView, placeHolder: placeholder)
    } else {
      loadLowResPosterImage(imageView)
    }
  }

  private func loadLowResPosterImage(imageView: UIImageView) {
    imageView.setImageWithURLRequest(lowResRequest,
      placeholderImage: nil,
      success: { (request, response, lowResPlaceHolderImage) in
        print("'' Success (lo-res): '\(self.title)' [\(self.id)]")
        self.posterImageThumbnail = lowResPlaceHolderImage
        self.loadHighResPosterImage(imageView, placeHolder: lowResPlaceHolderImage)
      },
      failure: { (request, response, _) in
        print("** Failure (lo-res): '\(self.title)' [\(self.id)]")
        dispatch_semaphore_signal(self.posterImageLoadingSemaphore)
      }
    )
  }

  private func loadHighResPosterImage(imageView: UIImageView, placeHolder: UIImage) {
    imageView.setImageWithURLRequest(highResRequest,
      placeholderImage: placeHolder,
      success: { (request, response, highResImage) in
        self.posterImage = highResImage

        self.crossDisolveImageViewSwap(imageView) {
          imageView.image = highResImage
        }
        print("''' Success (hi-res): '\(self.title)' [\(self.id)]")
      },
      failure: { (request, response, _) in
        print("*** Failure (hi-res): '\(self.title)' [\(self.id)]")
    })
  }

  private func crossDisolveImageViewSwap(imageView: UIImageView, animation: () -> ()) {
    dispatch_async(dispatch_get_main_queue()) {
      UIView.transitionWithView(imageView,
        duration: 3,
        options: UIViewAnimationOptions.TransitionCrossDissolve,
        animations: animation,
        completion: nil
      )
    }
  }
}