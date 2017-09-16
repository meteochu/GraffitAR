//
//  Light.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-16.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation

struct Light {
    
    let color: (Float, Float, Float)  // 1
    
    let ambientIntensity: Float       // 2
    
    let direction: (Float, Float, Float)
    
    let diffuseIntensity: Float
    
    let shininess: Float
    
    let specularIntensity: Float
    
    var time: Float
    
    static func size() -> Int {
        return MemoryLayout<Float>.size * 13
    }
    
    func raw() -> [Float] {
        return [color.0, color.1, color.2,
                ambientIntensity,
                direction.0, direction.1, direction.2,
                diffuseIntensity, shininess, specularIntensity, time]
    }
}

