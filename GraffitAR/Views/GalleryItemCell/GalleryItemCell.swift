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
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var favouriteIcon: UIImageView!
    
    private var handle: UInt?
    
    var graffiti: Graffiti! {
        didSet {
            DataController.shared.fetchGraffitiImage(for: graffiti) { [weak self] image in
                self?.imageView.image = image
            }
            
            if let user = DataController.shared.users[graffiti.creator] {
                favouriteIcon.isHidden = !user.favourites.contains(graffiti.id)
            }
            
            if !graffiti.name.isEmpty {
                self.titleLabel.text = graffiti.name
            } else {
                if let user = DataController.shared.users[graffiti.creator] {
                    self.titleLabel.text = user.name
                } else {
                    self.handle = DataController.shared.fetchUser(graffiti.creator) { [weak self] user in
                        self?.titleLabel.text = user?.name
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12
        layer.masksToBounds = false
        favouriteIcon.image = #imageLiteral(resourceName: "Star").withRenderingMode(.alwaysTemplate)
        favouriteIcon.tintColor = UIColor.orange
        favouriteIcon.isHidden = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.titleLabel.text = ""
        if let handle = handle {
            DataController.shared.stop(handle: handle)
        }
    }

}
