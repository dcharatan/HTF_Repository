//
//  BarGraphBarSegment.swift
//  BarGraphing
//
//  Created by David Charatan on 7/27/15.
//  Copyright (c) 2015 David Charatan. All rights reserved.
//

import UIKit

class BarGraphBarSegment: NSObject {
    internal var length: CGFloat = 0
    internal var name: String = ""
    
    init(length: CGFloat, name: String) {
        self.length = length
        self.name = name
    }
    
    override init() {
        // empty init
    }
}
