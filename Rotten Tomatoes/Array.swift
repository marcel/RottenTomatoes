//
//  Array.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/17/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Array {
  func any(predicate: Element -> Bool) -> Bool {
    for element in self {
      if predicate(element) {
        return true
      }
    }
    
    return false
  }
}