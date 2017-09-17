//
//  MyDrawingsCollectionViewController.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit
import Firebase

class MyDrawingsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var myDrawings: [Graffiti] = []
    
    var selectedIndex: Int = 0
    
    var drawingRef: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerNib(GalleryItemCell.self)
        self.collectionView!.registerNib(CreateDrawingCell.self)
        
        if let uid = Auth.auth().currentUser?.uid {
            self.drawingRef = DataController.shared.fetchDrawings(for: uid, with: { [weak self] array in
                if let array = array {
                    self?.myDrawings = array
                    self?.collectionView?.reloadData()
                }
            })
        } else {
            fatalError("Current user doesn't exist.")
        }
        
    }
    
    deinit {
        guard let ref = self.drawingRef else { return }
        DataController.shared.stop(handle: ref)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myDrawings.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == myDrawings.count {
            return collectionView.dequeueReusableCell(for: indexPath) as CreateDrawingCell
        } else {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as GalleryItemCell
            cell.graffiti = myDrawings[indexPath.item]
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.item == myDrawings.count {
            self.performSegue(withIdentifier: "openARCanvas", sender: self)
        } else {
            selectedIndex = indexPath.item
            self.performSegue(withIdentifier: "showDrawingDetail", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numPerRow = self.traitCollection.horizontalSizeClass == .compact ? 2 : 3
        let itemWidth = floor(self.collectionView!.bounds.width/CGFloat(numPerRow)) - CGFloat(8 * numPerRow)
        return CGSize(width: itemWidth, height: itemWidth * 9 / 16)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MyDrawingDetailViewController {
            controller.graffiti = self.myDrawings[selectedIndex]
        }
    }

}
