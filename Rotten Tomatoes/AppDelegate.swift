//
//  AppDelegate.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import AFNetworking
import AFNetworkActivityLogger
import KVNProgress

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?
  ) -> Bool {
    AFNetworkActivityLogger.sharedLogger().startLogging()
    configureRequestCache()

    return true
  }

  private func configureRequestCache() {
    let megabyte = 1024 * 1024

    let cache = NSURLCache(
      memoryCapacity: megabyte * 20,
      diskCapacity: megabyte * 20,
      diskPath: "request-cache"
    )
    NSURLCache.setSharedURLCache(cache)
  }
}

