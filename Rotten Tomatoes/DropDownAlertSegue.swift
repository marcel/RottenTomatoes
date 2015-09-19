//
//  DropDownAlertSegue.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class DropDownAlertSegue: UIStoryboardSegue {
  override func perform() {
    let movieControllerView = sourceViewController.view
    let dropDownView = destinationViewController.view as! DropDownAlertView
    let bannerView   = dropDownView.bannerView
    let originalAlpha = dropDownView.alpha

    dropDownView.alpha = 0.0
    dropDownView.frame = CGRectOffset(dropDownView.frame, 0, -bannerView.frame.height)

    movieControllerView.addSubview(dropDownView)
    movieControllerView.sendSubviewToBack(dropDownView)

    UIView.easeIn({
        movieControllerView.bringSubviewToFront(dropDownView)
        dropDownView.frame = CGRectOffset(dropDownView.frame, 0, bannerView.frame.height)
        dropDownView.alpha = originalAlpha
      },
      duration: 3.0,
      completion: { _ in
        print("Drop down view animation complete")
        UIView.easeOut({
            dropDownView.frame = CGRectOffset(dropDownView.frame, 0, -bannerView.frame.height)
            dropDownView.alpha = 0.0
          },
          duration: 3.0,
          completion: { _ in
            movieControllerView.sendSubviewToBack(dropDownView)
          }
        )
      }
    )
  }
}