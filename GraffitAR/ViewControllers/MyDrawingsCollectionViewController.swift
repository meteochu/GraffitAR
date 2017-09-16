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
    
    var drawingRef: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerNib(GalleryItemCell.self)
        
        if let uid = Auth.auth().currentUser?.uid {
            self.drawingRef = DataController.shared.fetchDrawings(for: uid, with: { [weak self] array in
                if let array = array {
                    print("I loaded data.")
                    self?.myDrawings = array
                    self?.collectionView?.reloadData()
                } else {
                    print("I don't know what's wrong. fuck")
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
        return myDrawings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as GalleryItemCell
        cell.graffiti = myDrawings[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = floor(self.collectionView!.bounds.width/3)
        return CGSize(width: itemWidth, height: itemWidth * 9 / 16)
    }

}
