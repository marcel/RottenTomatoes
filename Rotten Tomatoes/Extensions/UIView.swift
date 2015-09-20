//
//  UIView.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension UIView {
  static var defaultAnimationDuration: NSTimeInterval {
    return 1.0
  }

  class func animate(
    animations: () -> (),
    options: UIViewAnimationOptions = [],
    duration: NSTimeInterval = defaultAnimationDuration,
    completion: (Bool -> ())? = nil
  ) {
    dispatch_async(dispatch_get_main_queue()) {
      UIView.animateWithDuration(duration,
        delay: 0,
        usingSpringWithDamping: 0.75,
        initialSpringVelocity: 0.75,
        options: options,
        animations: animations,
        completion: completion
      )
    }
  }

  class func easeIn(
    animations: () -> (),
    duration: NSTimeInterval = defaultAnimationDuration,
    completion: (Bool -> ())? = nil
  ) {
    animate(animations, options: .CurveEaseIn, duration: duration,  completion: completion)
  }

  class func easeOut(
    animations: () -> (),
    duration: NSTimeInterval = defaultAnimationDuration,
    completion: (Bool -> ())? = nil
  ) {
    animate(animations, options: .CurveEaseOut, duration: duration, completion: completion)
  }
}