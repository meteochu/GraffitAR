//
//  CAMetalLayer++.swift
//  GraffitAR
//
//  Created by Andy Liang on 2017-09-17.
//  Copyright © 2017 GraffitAR. All rights reserved.
//

import Foundation
import UIKit

extension CAMetalLayer {
    
    static func setupSwizzling() {
        let copiedOriginalSelector = #selector(CAMetalLayer.orginalNextDrawable)
        let originalSelector = #selector(CAMetalLayer.nextDrawable)
        let swizzledSelector = #selector(CAMetalLayer.newNextDrawable)
        
        let copiedOriginalMethod = class_getInstanceMethod(self, copiedOriginalSelector)
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let oldImp = method_getImplementation(originalMethod!)
        method_setImplementation(copiedOriginalMethod!, oldImp)
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
    
    
    @objc func newNextDrawable() -> CAMetalDrawable? {
        let drawable = orginalNextDrawable()
        VertBrush.currentSceneDrawable = drawable
        return drawable
    }
    
    @objc func orginalNextDrawable() -> CAMetalDrawable? {
        // This is just a placeholder. Implementation will be replaced with nextDrawable.
        return nil
    }
}
