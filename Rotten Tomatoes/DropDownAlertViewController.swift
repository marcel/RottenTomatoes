//
//  DropDownAlertViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class DropDownAlertViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func handleTap() {
    print("Drop down received tap to be dismissed")
    dismissViewControllerAnimated(true, completion: nil)
  }
}
