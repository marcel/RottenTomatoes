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
    duration: NSTimeInterval,
    options: UIViewAnimationOptions,
    animations: () -> (),
    completion: (Bool -> ())?
  ) {
    UIView.animateWithDuration(duration,
      delay: 0,
      usingSpringWithDamping: 0.75,
      initialSpringVelocity: 0.75,
      options: options,
      animations: animations,
      completion: completion
    )
  }

  class func easeIn(
    animations: () -> (),
    duration: NSTimeInterval = defaultAnimationDuration,
    completion: (Bool -> ())? = nil
  ) {
    animate(duration, options: .CurveEaseIn, animations: animations, completion: completion)
  }

  class func easeOut(
    animations: () -> (),
    duration: NSTimeInterval = defaultAnimationDuration,
    completion: (Bool -> ())? = nil
  ) {
    animate(duration, options: .CurveEaseOut, animations: animations, completion: completion)
  }
}