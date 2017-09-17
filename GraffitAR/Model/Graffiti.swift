//
//  Graffiti.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

class Graffiti: NSObject, Codable {

    init(name: String, imageRef: String, creator: UserID, created: Date, downloads:Int, isPublished:Bool, detail:String, graffitiObj:GraffitiObject!) {
        super.init()
        self.name = name
        self.imageRef = imageRef
        self.creator = creator
        self.created = created
        self.downloads = downloads
        self.isPublished = isPublished
        self.detail = detail
        self.graffitiObj = graffitiObj
    }
    
    var name: String = ""
    
    var imageRef: String = ""
    
    var creator: UserID = ""
    
    var created: Date = Date()
    
    var downloads: Int = 0
    
    var isPublished: Bool = false
    
    var detail: String = ""
    
    var graffitiObj: GraffitiObject?
    
}
