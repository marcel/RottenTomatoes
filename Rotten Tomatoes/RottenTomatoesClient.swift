//
//  RottenTomatoesClient.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class RottenTomatoesClient {
  typealias ResponseHandler = [Movie]? -> Void

  private let moviesJsonKey = "movies"

  enum ApiUrl: String {
    case BoxOffice = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
    case DVD       = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
  }

  func load(url: ApiUrl, responseHandler: ResponseHandler) {
    request(NSURL(string: url.rawValue)!, responseHandler: responseHandler)
  }

  func request(url: NSURL, responseHandler: ResponseHandler) {
    let request = NSURLRequest(URL: url)
    let config  = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)

    session.dataTaskWithRequest(request) { (data, response, error) in
      if let data = data {
        print("JSON DATA loaded")
        do {
          responseHandler(
            self.payloadToMovies(
              try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
            )
          )
        } catch {
          print(error)
        }
      }
    }.resume()
  }

  private func payloadToMovies(payload: NSDictionary?) -> [Movie]? {
    return payload.flatMap { json in
      (json[moviesJsonKey] as? [NSDictionary]).map { moviesJson in
        moviesJson.map { movieJson in
          Movie(payload: movieJson)
        }
      }
    }
  }
}

// Decorator around a RottenTomatoesClient that simulates new results being returned
// by the API
class RefreshSimulatingRottenTomatoesClient: RottenTomatoesClient {
  typealias CLASS = RefreshSimulatingRottenTomatoesClient

  let underlying: RottenTomatoesClient
  init(_ underlying: RottenTomatoesClient) {
    self.underlying = underlying
  }

  private class func loadExtraMovieFromFile(fileName: String) -> Movie {
    let filePath   = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!
    let data       = NSData(contentsOfFile: filePath)!
    let dictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
    return Movie(payload: dictionary)
  }

  private static let extraMovie =
    CLASS.loadExtraMovieFromFile("extra-movie")

  override func payloadToMovies(payload: NSDictionary?) -> [Movie]? {
    return underlying.payloadToMovies(payload).map { originalResults in
      [CLASS.extraMovie] + originalResults
    }
  }
}