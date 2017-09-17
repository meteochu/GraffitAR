//
//  Graffiti.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

class Graffiti: NSObject, Codable {

    init(name: String, imageRef: String, creator: UserID, detail: String, fireBaseKey: String, graffitiObject: GraffitiObject) {
        super.init()
        self.name = name
        self.imageRef = imageRef
        self.creator = creator
        self.detail = detail
        self.graffitiObj = graffitiObject
        self.created = Date()
        self.downloads = 0
        self.isPublished = false
        self.fireBaseKey = fireBaseKey
    }
    
    var name: String = ""
    
    var imageRef: String = ""
    
    var creator: UserID = ""
    
    var created: Date = Date()
    
    var downloads: Int = 0
    
    var isPublished: Bool = false
    
    var detail: String = ""

    var fireBaseKey: String = ""
    
    var graffitiObj: GraffitiObject!
}
