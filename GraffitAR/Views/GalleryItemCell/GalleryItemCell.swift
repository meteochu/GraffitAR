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
    
    var grafitti: Graffiti! {
        didSet {
            let storage = Storage.storage()
            print(grafitti.imageRef)
            storage.reference(withPath: "graffiti").child(grafitti.imageRef).getData(maxSize: Int64.max) { [weak self] (data, error) in
                print(data ?? "", error ?? "")
                if let data = data {
                    self?.imageView.image = UIImage(data: data)
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

}
