//
//  BarGraphBar.swift
//  BarGraphing
//
//  Created by David Charatan on 7/24/15.
//  Copyright (c) 2015 David Charatan. All rights reserved.
//

import UIKit

class BarGraphBar: NSObject {
    internal var segments: [BarGraphBarSegment] = []
    internal var length: CGFloat {
        get {
            var returnValue: CGFloat = 0
            for segment: BarGraphBarSegment in segments {
                returnValue += segment.length
            }
            return returnValue
        }
    }
}
