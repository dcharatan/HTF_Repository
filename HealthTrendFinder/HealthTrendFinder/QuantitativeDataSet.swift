//
//  QuantitativeDataSet.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/28/15.
//
//

import UIKit

class QuantitativeDataSet: NSObject {
    var name: String = ""
    var data: [(date: NSDate, value: Double)] = []
    
    init(data: [(date: NSDate, value: Double)], name: String = "") {
        self.data = data
        self.name = name
    }
}
