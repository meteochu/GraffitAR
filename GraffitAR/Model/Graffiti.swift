//
//  Graffiti.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

class Graffiti: NSObject, Codable {

    init(name: String, imageRef: String, creator: UserID, detail: String, id: String, graffitiObject: GraffitiObject) {
        super.init()
        self.name = name
        self.imageRef = imageRef
        self.creator = creator
        self.detail = detail
        self.graffitiObj = graffitiObject
        self.created = Date()
        self.downloads = 0
        self.isPublished = false
        self.id = id
    }
    
    var name: String = ""
    
    var imageRef: String = ""
    
    var creator: UserID = ""
    
    var created: Date = Date()
    
    var downloads: Int = 0
    
    var isPublished: Bool = false
    
    var detail: String = ""

    var id: String = ""
    
    var graffitiObj: GraffitiObject!
}
