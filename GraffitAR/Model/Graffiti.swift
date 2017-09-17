//
//  Graffiti.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

class Graffiti: NSObject, Codable {
    
    var name: String = ""
    
    var imageRef: String = ""
    
    var creator: UserID = ""
    
    var created: Date = Date()
    
    var downloads: Int = 0
    
    var isPublished: Bool = false
    
    var detail: String = ""
    
}
