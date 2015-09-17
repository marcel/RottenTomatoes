//
//  RottenTomatoesClient.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class RottenTomatoesClient {
  typealias ResponseHander = [Movie]? -> Void

  private let moviesJsonKey = "movies"

  enum ApiUrl: String {
    case BoxOffice = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
    case DVD       = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
  }

  func boxOffice(responseHandler: ResponseHander) {
    let url = NSURL(string: ApiUrl.BoxOffice.rawValue)!

    request(url) { movies -> Void in
      responseHandler(movies)
    }
  }

  func dvd(responseHandler: ResponseHander) {
    let url = NSURL(string: ApiUrl.DVD.rawValue)!

    request(url) { dvds -> Void in
      responseHandler(dvds)
    }
  }

  private func request(url: NSURL, responseHandler: ResponseHander) {
    let request = NSURLRequest(URL: url)
    let config  = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)

    let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
      if let data = data {
        do {
          let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
          if let json = json {
            if let moviesJson = json[self.moviesJsonKey] as? [NSDictionary] {
              responseHandler(moviesJson.map { Movie(data: $0) })
            }
          }
        } catch {
          print(error)
        }
      }
    }

    task.resume()
  }
}