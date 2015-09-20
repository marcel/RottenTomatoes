//
//  Synchronizer.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/19/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class Synchronizer {
  class func synchronize<R>(object: AnyObject, criticalSection: () -> R) {
    do {
      objc_sync_enter(object)
      
      defer {
        objc_sync_exit(object)
      }

      try criticalSection()
    }
  }
}