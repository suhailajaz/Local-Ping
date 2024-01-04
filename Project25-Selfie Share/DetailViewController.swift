//
//  DetailViewController.swift
//  Project25-Selfie Share
//
//  Created by suhail on 29/08/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imgFullSize: UIImageView!
    var currentImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedImage = currentImage{
            imgFullSize.image = selectedImage
        }
        
        
    }
}
