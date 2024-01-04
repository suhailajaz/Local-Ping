//
//  PictureCollectionViewCell.swift
//  Project25-Selfie Share
//
//  Created by suhail on 29/08/23.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    static let identifier = "newCvCell"
    static let nib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
    @IBOutlet var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 12
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
    }

}
