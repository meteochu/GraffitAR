//
//  User.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

class User: NSObject, Codable {
    
    var name: String = ""
    
    var email: String = ""
    
    var id: String = ""
    
    var img: URL?
    
    var drawings: [String] = []
    
    var favourites: [String] = []
    
}
