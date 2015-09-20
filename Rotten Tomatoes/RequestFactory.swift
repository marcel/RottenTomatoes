//
//  RequestFactory.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/17/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class RequestFactory {
  static let cachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
  static let timeoutInterval: NSTimeInterval = 60

  static func mkRequest(url: NSURL) -> NSURLRequest {
    return NSURLRequest(
      URL: url,
      cachePolicy: cachePolicy,
      timeoutInterval: timeoutInterval
    )
  }

  static func mkRequest(string: String) -> NSURLRequest {
    let url = NSURL(string: string)!

    return mkRequest(url)
  }
}