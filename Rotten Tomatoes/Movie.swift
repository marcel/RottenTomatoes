//
//  Movie.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

struct Movie {
  let data: NSDictionary

  let title: String
  let synopsis: String

  let posterImageUrl: NSURL

  init(data: NSDictionary) {
    let title    = data["title"] as! String
    let synopsis = data["synopsis"] as! String

    let lowResUrl  = data.valueForKeyPath("posters.thumbnail") as! String
    let highResUrl = Movie.convertPostertPostImageUrlToHighResVersion(lowResUrl)

    self.init(data: data, title: title, synopsis: synopsis, posterImageUrl: NSURL(string: highResUrl)!)
  }

  init(data: NSDictionary, title: String, synopsis: String, posterImageUrl: NSURL) {
    self.data           = data
    self.title          = title
    self.synopsis       = synopsis
    self.posterImageUrl = posterImageUrl
  }

  private static func convertPostertPostImageUrlToHighResVersion(url: String) -> String {
    let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)!
    return url.stringByReplacingCharactersInRange(
        range,
        withString: "https://content6.flixster.com/"
      )
  }
}