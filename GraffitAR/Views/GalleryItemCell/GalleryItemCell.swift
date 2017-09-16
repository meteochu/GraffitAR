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
    
    @IBOutlet var artist : UILabel!
    
    private var handle: UInt?
    
    var graffiti: Graffiti! {
        didSet {
            DataController.shared.fetchGraffitiImage(for: graffiti) { [weak self] image in
                self?.imageView.image = image
            }
            
            if let user = DataController.shared.users[graffiti.creator] {
                self.artist.text = user.name
            } else {
                self.handle = DataController.shared.fetchUser(graffiti.creator, with: { [weak self] user in
                    self?.artist.text = user?.name
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12
        layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.artist.text = ""
        if let handle = handle {
            DataController.shared.stop(handle: handle)
        }
    }

}
