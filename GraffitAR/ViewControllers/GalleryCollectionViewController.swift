//
//  GalleryCollectionViewController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "GalleryItemCell"

class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var graffitis: [Graffiti] = []
    
    var drawingRef: UInt!
    
    var usersRef: UInt!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerNib(GalleryItemCell.self)
        self.usersRef = DataController.shared.loadAllUsers()
        self.drawingRef = DataController.shared.fetchGalleryDrawings(callback:{ [weak self] array in
            if let array = array {
                self?.graffitis = array
                self?.collectionView?.reloadData()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "presentLoginView", sender: self)
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as GalleryItemCell
        cell.graffiti = graffitis[indexPath.item]
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return graffitis.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedIndex = indexPath.item
        self.performSegue(withIdentifier: "showDrawingDetail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numPerRow = self.traitCollection.horizontalSizeClass == .compact ? 2 : 3
        let itemWidth = floor(self.collectionView!.bounds.width/CGFloat(numPerRow)) - CGFloat(8 * numPerRow)
        return CGSize(width: itemWidth, height: itemWidth * 9 / 16)
    }
    
    deinit {
        guard let drawingRef = self.drawingRef, let userRef = self.usersRef else { return }
        DataController.shared.stop(handle: drawingRef)
        DataController.shared.stop(handle: userRef)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MyDrawingDetailViewController {
            controller.graffiti = self.graffitis[selectedIndex]
        }
    }
    
}
