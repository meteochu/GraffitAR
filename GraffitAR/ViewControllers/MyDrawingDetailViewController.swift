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

    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var createdDateLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var downloadCountLabel: UILabel!
    
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
        artistNameLabel.text = graffiti.creator
        createdDateLabel.text = "Created on \(DateFormatter.localizedString(from: graffiti.created, dateStyle: .short, timeStyle: .short))"
        detailLabel.text = graffiti.detail
        downloadCountLabel.text = "\(graffiti.downloads) Downloads"
        
        DataController.shared.fetchGraffitiImage(for: graffiti) { [weak self] image in
            self?.previewImageView.image = image
        }
        
        if let user = DataController.shared.users[graffiti.creator] {
            self.artistNameLabel.text = user.name
        } else {
            self.handle = DataController.shared.fetchUser(graffiti.creator) { [weak self] user in
                self?.artistNameLabel.text = user?.name
            }
        }
    }

}
