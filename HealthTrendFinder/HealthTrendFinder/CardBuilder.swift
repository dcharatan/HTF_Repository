//
//  CardBuilder.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/24/15.
//
//

import UIKit

class CardBuilder: NSObject {
    static let margin: CGFloat = 8
    static let outerMargin: CGFloat = 24
    static let innerMargin: CGFloat = 8
    
    static func getCurrentCards(viewBounds: CGRect) -> [CardView] {
        return [makeBarGraphCard(viewBounds), makePieGraphCard(viewBounds), makeBasicCard(viewBounds), makePearsonRCard(viewBounds), makePearsonRCard(viewBounds), makePearsonRCard(viewBounds), makePearsonRCard(viewBounds), makePearsonRCard(viewBounds)]
    }
    
    static private func makeBasicCard(viewBounds: CGRect) -> CardView {
        var card: CardView = CardView(frame: CGRect(
            x: margin,
            y: 0,
            width: viewBounds.width - 2 * margin,
            height: 200
            ), headerText: "Trend Card")
        return card
    }
    
    static private func makePearsonRCard(viewBounds: CGRect) -> CardView {
        let cardWidth: CGFloat = viewBounds.width - 2 * margin
        let cardContentWidth: CGFloat = viewBounds.width - 4 * margin
        
        // This sets up the GraphView.
        var graphView: LineGraphView = LineGraphView(frame: CGRect(x: margin, y: yForPreviousViews(), width: cardContentWidth, height: cardContentWidth * 0.5))
        graphView.baseColor = ColorManager.colorForRGB(red: 245, green: 245, blue: 245)
        graphView.boundsLineColor = ColorManager.colorForRGB(red: 85, green: 85, blue: 85)
        graphView.labelFontColor = ColorManager.colorForRGB(red: 85, green: 85, blue: 85)
        graphView.graphMode = LineGraphView.graphModes.Day
        graphView.independentY = true
        graphView.dataSetLabelFontSize = 5.75
        graphView.dataColors = [
            ColorManager.colorForRGB(red: 0x77, green: 0x77, blue: 0x77),
            ColorManager.colorForRGB(red: 0x33, green: 0x33, blue: 0x33)
        ]
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var set1: LineGraphDataSet = LineGraphDataSet()
        set1.name = "Tomatoes Eaten"
        set1.unit = " tomatoes"
        for var i: Int = 0; i < 24; i++ {
            let date: NSDate = calendar.dateWithEra(1, year: 2015, month: 5, day: 1, hour: i, minute: 1, second: 1, nanosecond: 1)!
            let value: CGFloat = -4 * abs(CGFloat(i) - 12) + CGFloat(arc4random_uniform(48)) + 80
            set1.points += [(date, value)]
        }
        var set2: LineGraphDataSet = LineGraphDataSet()
        set2.name = "Potatoes Eaten"
        set2.unit = " potatoes"
        for var i: Int = 0; i < 24; i++ {
            let date: NSDate = calendar.dateWithEra(1, year: 2015, month: 5, day: 1, hour: i, minute: 1, second: 1, nanosecond: 1)!
            let value: CGFloat = -8 * abs(CGFloat(i) - 12) + CGFloat(arc4random_uniform(96)) + 120
            set2.points += [(date, value)]
        }
        
        graphView.data = [set1, set2]
        
        // This sets up the CorrelationView.
        let correlationViewHeight: CGFloat = 40
        var correlationView: CorrelationView = CorrelationView(frame: CGRect(x: margin, y: yForPreviousViews(graphView), width: cardContentWidth, height: 40))
        
        var rPoints: [CGPoint] = []
        for i: Int in 0..<set1.points.count {
            rPoints += [CGPoint(
                x: set1.points[i].y,
                y: set2.points[i].y
            )]
        }
        
        correlationView.r = round(AnalysisTools.pearsonR(rPoints) * 100) / 100
        
        // This sets up the TextView.
        var textView: UITextView = dynamicHeightTextView(
            margin,
            y: yForPreviousViews(graphView, correlationView),
            width: cardContentWidth,
            text: "This card will show correlation in terms of Pearson's r. This text will show a quick description of any correlation. Right now, it doesn't show anything. This is another sentence. This is also a sentence, but it's a lot longer. Welcome to the Michael Scott Paper Company."
        )
        
        // This sets up the returned CardView.
        var returnCard: CardView = CardView(frame: CGRect(x: margin, y: 0, width: cardWidth, height: yForPreviousViews(graphView, correlationView, textView)), headerText: "Pearson R Card")
        returnCard.addSubview(graphView)
        returnCard.addSubview(textView)
        returnCard.addSubview(correlationView)
        return returnCard
    }
    
    static private func dynamicHeightTextView(x: CGFloat, y: CGFloat, width: CGFloat, text: String) -> UITextView {
        var textView: UITextView = UITextView(frame: CGRect(x: x, y: y, width: width, height: 100))
        textView.text = text
        textView.scrollEnabled = false
        textView.selectable = false
        textView.sizeToFit()
        textView.layoutIfNeeded()
        let textViewHeight: CGFloat = textView.sizeThatFits(CGSizeMake(width, CGFloat.max)).height
        textView.frame = CGRect(x: x, y: y, width: width, height: textViewHeight)
        return textView
    }
    
    static private func yForPreviousViews(previousViews: UIView...) -> CGFloat {
        var returnValue: CGFloat = CardView.headerBarSize + margin
        
        for previousView: UIView in previousViews {
            returnValue += previousView.frame.height
            returnValue += margin
        }
        
        return returnValue
    }
    
    static private func makeBarGraphCard(viewBounds: CGRect) -> CardView {
        var returnCard: CardView = CardView(frame: CGRect(
            x: margin,
            y: 0,
            width: viewBounds.width - 2 * margin,
            height: 0
            ), headerText: "Bar Graph Card")
        
        // This adds the bar graph.
        var barGraph: BarGraphView = BarGraphView()
        barGraph.frame = CGRect(
            x: 0,
            y: CardView.headerBarSize,
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
            x: margin,
            y: 0,
            width: viewBounds.width - 2 * margin,
            height: CardView.headerBarSize + barGraph.frame.height
        )
        
        return returnCard
    }
    
    static private func makePieGraphCard(viewBounds: CGRect) -> CardView {
        var returnCard: CardView = CardView(frame: CGRect(), headerText: "Activity on Weekends vs. Weekdays")
        
        // This creates the pie graph.
        var pieGraph: PieGraphView = PieGraphView()
        pieGraph.frame = CGRect(
            x: margin,
            y: margin + CardView.headerBarSize,
            width: viewBounds.width - 3 * margin,
            height: (viewBounds.width - 2 * margin) * 0.5
        )
        
        // This adds data to the pie graph.
        var weekdayDataSet: PieGraphDataSet = PieGraphDataSet()
        weekdayDataSet.name = "Weekdays"
        weekdayDataSet.slices = [
            PieGraphSlice(magnitude: 3.1, name: "Activity"),
            PieGraphSlice(magnitude: 13.6, name: "Inactivity")
        ]
        
        var weekendDataSet: PieGraphDataSet = PieGraphDataSet()
        weekendDataSet.name = "Weekends"
        weekendDataSet.slices = [
            PieGraphSlice(magnitude: 5.2, name: "Activity"),
            PieGraphSlice(magnitude: 10.4, name: "Inactivity")
        ]
        
        pieGraph.data = [weekdayDataSet, weekendDataSet]
        pieGraph.colors = [
            "Activity": ColorManager.colors[0],
            "Inactivity": ColorManager.colors[1]
        ]
        pieGraph.guideFontSize = 7.5
        pieGraph.swatchFontMargin = 5
        pieGraph.swatchSize = 7.5
        pieGraph.swatchFontSize = 7.5
        pieGraph.labelFontSize = 5
        pieGraph.labelUnit = "h"
        
        returnCard.addSubview(pieGraph)
        
        returnCard.frame = CGRect(
            x: margin, y: 0, width: viewBounds.width - 2 * margin, height: CardView.headerBarSize + pieGraph.frame.height + margin * 2
        )
        
        return returnCard
    }
}