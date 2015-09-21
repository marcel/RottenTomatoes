//
//  Movie.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class Movie {
  typealias Payload = NSDictionary

  struct Rating {
    enum Rating: String {
      case Rotten = "Rotten"
      case Fresh  = "Fresh"
      case CertifiedFresh = "Certified Fresh"
      case Upright = "Upright"
      case Spilled = "Spilled"
    }

    let rating: Rating?
    let score: Int?
  }

  private let payload: Payload

  let title: String
  let synopsis: String

  let posterImageUrl: NSURL
  var posterImage: UIImage?
  let posterImageThumbnailUrl: NSURL
  var posterImageThumbnail: UIImage?

  let mpaaRating: String
  let audienceRating: Rating
  let criticsRating: Rating

  let releaseDate: NSDate
  private let lowResRequest: NSURLRequest
  private let highResRequest: NSURLRequest

  private class func convertPostertImageUrlToHighResVersion(url: String) -> String {
    if let range = url.rangeOfString(".*cloudfront8?.net/", options: .RegularExpressionSearch) {
      return url.stringByReplacingCharactersInRange(
        range,
        withString: "https://content6.flixster.com/"
      )
    } else {
      return url
    }
  }

  convenience init(payload: Payload) {
    let title    = payload["title"] as! String
    let synopsis = payload["synopsis"] as! String

    let lowResUrl  = payload.valueForKeyPath("posters.thumbnail") as! String
    let highResUrl = Movie.convertPostertImageUrlToHighResVersion(lowResUrl)

    let mpaaRating = payload["mpaa_rating"] as! String

    self.init(
      payload: payload,
      title: title,
      synopsis: synopsis,
      posterImageUrl: (NSURL(string: highResUrl)!),
      posterImageThumbnailUrl: (NSURL(string: lowResUrl)!),
      mpaaRating: mpaaRating,
      audienceRating: Movie.ratingFromPayload(payload, by: "audience"),
      criticsRating: Movie.ratingFromPayload(payload, by: "critics"),
      releaseDate: Movie.releaseDateFromPayload(payload)!
    )
  }

  private class func releaseDateFromPayload(payload: Payload) -> NSDate? {
    let dateString = payload.valueForKeyPath("release_dates.theater") as! String

    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    return dateFormatter.dateFromString(dateString)
  }

  private class func ratingFromPayload(payload: Payload, by: String) -> Rating {
    let ratingName = payload.valueForKeyPath("ratings.\(by)_rating") as? String
    return Rating(
      rating: ratingName.flatMap { Rating.Rating(rawValue: $0) },
      score: payload.valueForKeyPath("ratings.\(by)_score") as? Int
    )
  }

  init(
    payload: Payload,
    title: String,
    synopsis: String,
    posterImageUrl: NSURL,
    posterImageThumbnailUrl: NSURL,
    mpaaRating: String,
    audienceRating: Rating,
    criticsRating: Rating,
    releaseDate: NSDate
  ) {
    self.payload           = payload
    self.title             = title
    self.synopsis          = synopsis
    self.posterImageUrl    = posterImageUrl
    self.posterImageThumbnailUrl = posterImageThumbnailUrl
    self.mpaaRating        = mpaaRating
    self.audienceRating    = audienceRating
    self.criticsRating     = criticsRating
    self.releaseDate       = releaseDate

    self.lowResRequest  = RequestFactory.mkRequest(posterImageThumbnailUrl)
    self.highResRequest = RequestFactory.mkRequest(posterImageUrl)
  }

  func loadPosterImageIntoView(imageView: UIImageView) {
    print("loadPosterImageIntoView: '\(title)'")
    if let posterImage = posterImage {
      print("Image already set: '\(title)'")
      imageView.image = posterImage
    } else {
      print("Loading image for '\(title)' from network")
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
        print("'' Success (lo-res): '\(self.title)'")
        self.posterImageThumbnail = lowResPlaceHolderImage
        self.loadHighResPosterImage(imageView, placeHolder: lowResPlaceHolderImage)
      },
      failure: { (request, response, _) in
        print("** Failure (lo-res): '\(self.title)'")
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
        print("''' Success (hi-res): '\(self.title)'")
      },
      failure: { (request, response, _) in
        print("*** Failure (hi-res): '\(self.title)'")
    })
  }

  private func crossDisolveImageViewSwap(imageView: UIImageView, animation: () -> ()) {
    dispatch_async(dispatch_get_main_queue()) {
      UIView.transitionWithView(imageView,
        duration: 3,
        options: [.TransitionCrossDissolve, .AllowUserInteraction],
        animations: animation,
        completion: nil
      )
    }
  }
}