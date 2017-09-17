//
//  Graffiti.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

class Graffiti: NSObject, Codable {
    
    init(imageRef: String, creator: UserID, created: Date, downloads:Int, isPublished:Bool, detail:String) {
        super.init()
        self.imageRef = imageRef
        self.creator = creator
        self.created = created
        self.downloads = downloads
        self.isPublished = isPublished
        self.detail = detail
    }
    
    var imageRef: String = ""
    
    var previewImageRef: String = ""
    
    var creator: UserID = ""
    
    var created: Date = Date()
    
    var downloads: Int = 0
    
    var isPublished: Bool = false
    
    var detail: String = ""
    
}
