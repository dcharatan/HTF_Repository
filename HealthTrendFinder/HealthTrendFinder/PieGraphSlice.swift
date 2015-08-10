//
//  PieGraphSlice.swift
//  PieGraphing
//
//  Created by David Charatan on 7/20/15.
//
//

import UIKit

class PieGraphSlice: NSObject {
    internal var magnitude: CGFloat = 0
    internal var name: String = ""
    
    init(magnitude: CGFloat, name: String) {
        self.magnitude = magnitude
        self.name = name
    }
}
