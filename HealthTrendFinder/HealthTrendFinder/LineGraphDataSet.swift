//
//  LineGraphDataSet.swift
//  LineGraphingV3
//
//  Created by David Charatan on 7/31/15.
//  Copyright (c) 2015 David Charatan. All rights reserved.
//

import UIKit

class LineGraphDataSet: NSObject {
    var name: String = ""
    var unit: String = ""
    var points: [(x: NSDate, y: CGFloat)] = []
}
