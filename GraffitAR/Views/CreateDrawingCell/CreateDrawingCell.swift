//
//  CreateDrawingCell.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import UIKit

class CreateDrawingCell: UICollectionViewCell {
    
    private let borderLayer = CAShapeLayer()

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderLayer.strokeColor = UIColor.darkGray.cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [4, 2]
        borderLayer.fillColor = nil
        self.layer.addSublayer(borderLayer)
        self.layer.cornerRadius = 12
        imageView.image = #imageLiteral(resourceName: "Paintbrush").withRenderingMode(.alwaysTemplate)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.bounds
        borderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath
    }
    
}
