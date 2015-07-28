//
//  CardBuilder.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/24/15.
//
//

import UIKit

class CardBuilder: NSObject {
    static let cardMargin: CGFloat = 8
    static let outerMargin: CGFloat = 24
    static let innerMargin: CGFloat = 8
    
    static func getCurrentCards(viewBounds: CGRect) -> [CardView] {
        return [makeBarGraphCard(viewBounds)]
    }
    
    static private func makeBasicCard(viewBounds: CGRect) -> CardView {
        var card: CardView = CardView(frame: CGRect(
            x: cardMargin,
            y: 0,
            width: viewBounds.width - 2 * cardMargin,
            height: 200
            ), headerText: "Trend Card")
        return card
    }
    
    static private func makeBarGraphCard(viewBounds: CGRect) -> CardView {
        var returnCard: CardView = CardView(frame: CGRect(
            x: cardMargin,
            y: 0,
            width: viewBounds.width - 2 * cardMargin,
            height: 0
            ), headerText: "Bar Graph Card")
        
        // This adds the bar graph.
        var barGraph: BarGraphView = BarGraphView()
        barGraph.frame = CGRect(
            x: 0,
            y: returnCard.headerBarSize,
            width: returnCard.frame.width,
            height: returnCard.frame.width * 0.6
        )
        barGraph.backgroundColor = UIColor.clearColor()
        barGraph.barDirection = "horizontal"
        barGraph.bgColor = UIColor.clearColor()
        barGraph.bgStrokeColor = UIColor.clearColor()
        barGraph.graphAreaY = 50
        barGraph.graphAreaHeight = 75
        barGraph.graphAreaX_Scale = "horizontal"
        barGraph.graphAreaX = 40
        barGraph.graphAreaWidth_Scale = "horizontal"
        barGraph.graphAreaWidth = 65
        barGraph.keyX_Scale = "horizontal"
        barGraph.keyX = 80
        
        var set1: BarGraphDataSet = BarGraphDataSet()
        set1.bars = [
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 4, name: "Running")
                ]),
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 13, name: "Running")
                ])
        ]
        
        var set2: BarGraphDataSet = BarGraphDataSet()
        set2.bars = [
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 6, name: "Walking")
                ]),
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 11, name: "Walking")
                ])
        ]
        
        var set3: BarGraphDataSet = BarGraphDataSet()
        set3.bars = [
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 15, name: "Sitting")
                ]),
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 3, name: "Sitting")
                ])
        ]
        
        var set4: BarGraphDataSet = BarGraphDataSet()
        set4.bars = [
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 8, name: "Driving")
                ]),
            BarGraphBar(segments: [
                BarGraphBarSegment(length: 4, name: "Driving")
                ])
        ]
        
        barGraph.data = [
            set1,
            set2,
            set3,
            set4
        ]
        
        barGraph.colors = [
            "Running" : UIColor(red: 0xBF / 255, green: 0x30 / 255, blue: 0x30 / 255, alpha: 1),
            "Walking" : UIColor(red: 0xA6 / 255, green: 0x00 / 255, blue: 0x00 / 255, alpha: 1),
            "Sitting" : UIColor(red: 0x26 / 255, green: 0x99 / 255, blue: 0x26 / 255, alpha: 1),
            "Driving" : UIColor(red: 0x00 / 255, green: 0x85 / 255, blue: 0x00 / 255, alpha: 1)
        ]
        
        returnCard.addSubview(barGraph)
        
        returnCard.frame = CGRect(
            x: cardMargin,
            y: 0,
            width: viewBounds.width - 2 * cardMargin,
            height: returnCard.headerBarSize + barGraph.frame.height
        )
        
        return returnCard
    }
}