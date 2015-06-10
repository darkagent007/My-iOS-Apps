//
//  DetailsViewController.swift
//  Table
//
//  Created by Paul Intharathut on 6/10/15.
//  Copyright (c) 2015 Paul Intharathut. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var album: Album?
    
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = self.album?.title
        albumCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.album!.largeImageURL)!)!)
        priceLabel.text = self.album?.price
    }
}
