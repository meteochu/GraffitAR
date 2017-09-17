//
//  MyDrawingDetailViewController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit

class MyDrawingDetailViewController: UIViewController {
    
    // IBOutlets...
    
    @IBOutlet weak var graffitiNameLabel: UILabel!

    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var createdDateLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var downloadCountLabel: UILabel!
    
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    
    @IBOutlet weak var publishButton: UIButton!
    
    var isFavourited: Bool = false
    
    var handle: UInt!
    
    var graffiti: Graffiti! {
        didSet {
            guard artistNameLabel != nil else { return }
            self.reloadData()
        }
    }
    
    deinit {
        guard let handle = handle else { return }
        DataController.shared.stop(handle: handle)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
    }
    
    func reloadData() {
        graffitiNameLabel.text = graffiti.name
        createdDateLabel.text = "Created on \(DateFormatter.localizedString(from: graffiti.created, dateStyle: .short, timeStyle: .short))"
        artistNameLabel.text = "by \(graffiti.creator)"
        detailLabel.text = graffiti.detail
        downloadCountLabel.text = "\(graffiti.downloads) Downloads"
        
        DataController.shared.fetchGraffitiImage(for: graffiti) { [weak self] image in
            self?.previewImageView.image = image
        }
        
        if let user = DataController.shared.users[graffiti.creator] {
            self.artistNameLabel.text = user.name
            for key in user.favourites {
                if (key == graffiti.fireBaseKey) {
                    self.isFavourited = true
                }
            }
        } else {
            self.handle = DataController.shared.fetchUser(graffiti.creator) { [weak self] user in
                self?.artistNameLabel.text = user?.name
                if (user != nil && self != nil) {
                    for key in user!.favourites {
                        if (key == self!.graffiti.fireBaseKey) {
                            self!.isFavourited = true
                        }
                    }
                }
            }
        }
        
        self.favouriteButton.image = self.isFavourited ?  #imageLiteral(resourceName: "Star") : #imageLiteral(resourceName: "Star-Bordered")
        
        if (graffiti.isPublished) {
            self.publishButton.setTitle("Published", for: UIControlState.normal)
            self.publishButton.isEnabled = false
        } else {
            self.publishButton.setTitle("Publish", for: UIControlState.normal)
            self.publishButton.isEnabled = true
        }
        
    }
    
    @IBAction func didSelectStarButton(_ sender: UIBarButtonItem) {
        self.isFavourited = !self.isFavourited
        sender.image = self.isFavourited ?  #imageLiteral(resourceName: "Star") : #imageLiteral(resourceName: "Star-Bordered")
        DataController.shared.favouriteGraffiti(graffiti: graffiti, isFavourited:self.isFavourited)
    }
    
    
    @IBAction func didSelectPublishButton(_ sender: UIButton) {
        DataController.shared.publishGraffiti(graffiti: graffiti)
    }
    
    
}
