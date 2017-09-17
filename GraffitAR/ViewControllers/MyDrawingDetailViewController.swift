//
//  MyDrawingDetailViewController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import Firebase

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
    
    // depending on the user state, it can also be a clone button
    @IBOutlet weak var editGraffitiButton: UIButton!
    
    var isFavourited: Bool = false
    
    var userHandle: UInt!
    
    var graffitiHandle: UInt!
    
    var graffiti: Graffiti! {
        didSet {
            guard artistNameLabel != nil else { return }
            self.reloadData()
        }
    }
    
    deinit {
        if let handle = userHandle {
            DataController.shared.stop(handle: handle)
        }
        
        if let handle = graffitiHandle {
            DataController.shared.stop(handle: handle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
        
        if let graffiti = self.graffiti {
            self.graffitiHandle = DataController.shared.fetchGraffiti(withId: graffiti.id, callback: { [weak self] graffiti in
                guard let graffiti = graffiti else { return }
                self?.graffiti = graffiti
            })
        }
    }
    
    func reloadData() {
        graffitiNameLabel.text = graffiti.name
        createdDateLabel.text = "Created on \(DateFormatter.localizedString(from: graffiti.created, dateStyle: .short, timeStyle: .short))"
        detailLabel.text = graffiti.detail
        downloadCountLabel.text = "\(graffiti.downloads) Downloads"
        
        DataController.shared.fetchGraffitiImage(for: graffiti) { [weak self] image in
            self?.previewImageView.image = image
        }
        
        if let user = DataController.shared.users[graffiti.creator] {
            self.artistNameLabel.text = "by \(user.name)"
            for key in user.favourites {
                if key == graffiti.id {
                    self.isFavourited = true
                }
            }
        } else {
            self.userHandle = DataController.shared.fetchUser(graffiti.creator) { [weak self] user in
                self?.artistNameLabel.text = user?.name
                if let user = user, let graffiti = self?.graffiti {
                    for key in user.favourites where key == graffiti.id {
                        self?.isFavourited = true
                    }
                }
            }
        }
        
        self.favouriteButton.image = self.isFavourited ?  #imageLiteral(resourceName: "Star") : #imageLiteral(resourceName: "Star-Bordered")
        
        if graffiti.creator == Auth.auth().currentUser!.uid {
            self.editGraffitiButton.setTitle("Edit Graffiti", for: .normal)
            if graffiti.isPublished {
                self.publishButton.setTitle("Artwork is published", for: .normal)
                self.publishButton.backgroundColor = UIColor.gray
                self.publishButton.isEnabled = false
            } else {
                self.publishButton.setTitle("Publish Artwork", for: .normal)
                self.publishButton.isEnabled = true
            }
        } else {
            publishButton.isHidden = true
            self.editGraffitiButton.setTitle("Download and Edit", for: .normal)
        }
    }
    
    @IBAction func didSelectStarButton(_ sender: UIBarButtonItem) {
        self.isFavourited = !self.isFavourited
        sender.image = self.isFavourited ?  #imageLiteral(resourceName: "Star") : #imageLiteral(resourceName: "Star-Bordered")
        DataController.shared.favouriteGraffiti(graffiti, isFavourited: self.isFavourited)
    }
    
    @IBAction func didSelectPublishButton(_ sender: UIButton) {
        let startTime = Date().timeIntervalSince1970
        let alertController = UIAlertController(title: "Publishing Graffiti...", message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.height, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = .up
        self.present(alertController, animated: true) {
            DataController.shared.publishGraffiti(self.graffiti) {
                let endTime = Date().timeIntervalSince1970
                let interval = endTime - startTime
                DispatchQueue.main.asyncAfter(deadline: .now() + (2 - interval)) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func didSelectEditButton(_ sender: UIButton) {
        if graffiti.creator == Auth.auth().currentUser!.uid {
            // current user, should just open vectors to browse.
            self.performSegue(withIdentifier: "editGraffitiSegue", sender: self)
        } else {
            // clone + edit
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ARCanvasViewController {
            controller.graffiti = self.graffiti
        }
    }
    
}
