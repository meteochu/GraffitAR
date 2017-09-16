//
//  GalleryItemCell.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import FirebaseStorage

class GalleryItemCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var blur : UIVisualEffectView!
    @IBOutlet var artist : UILabel!
    
    var graffiti: Graffiti! {
        didSet {
            let storage = Storage.storage()
            storage.reference(withPath: "graffiti").child(graffiti.imageRef).getData(maxSize: Int64.max) { [weak self] (data, error) in
                if let data = data {
                    self?.imageView.image = UIImage(data: data)
                } else {
                    print(error ?? "No Error found.")
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

}
