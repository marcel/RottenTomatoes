//
//  MoviesDetailViewController.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/16/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class MoviesDetailViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisLabel: UILabel!

  var movie: Movie!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = movie.title
    synopsisLabel.text = movie.synopsis
    imageView.setImageWithURL(movie.posterImageUrl)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
