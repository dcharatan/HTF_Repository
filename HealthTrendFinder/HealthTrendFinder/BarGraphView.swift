//
//  BarGraphView.swift
//  BarGraphing
//
//  Created by David Charatan on 7/24/15.
//  Copyright (c) 2015 David Charatan. All rights reserved.
//

import UIKit

@IBDesignable

class BarGraphView: UIView {
    
    @IBInspectable var graphAreaX_Scale: String = "horizontal"
    @IBInspectable var graphAreaY_Scale: String = "vertical"
    @IBInspectable var graphAreaX: CGFloat = 40
    @IBInspectable var graphAreaY: CGFloat = 50
    
    @IBInspectable var graphAreaWidth_Scale: String = "vertical"
    @IBInspectable var graphAreaHeight_Scale: String = "vertical"
    @IBInspectable var graphAreaWidth: CGFloat = 80
    @IBInspectable var graphAreaHeight: CGFloat = 60
    
    @IBInspectable var barDirection: String = "vertical"
    
    @IBInspectable var barSizing_Scale: String = "vertical"
    @IBInspectable var barSpacing: CGFloat = 1
    @IBInspectable var barGroupSpacing: CGFloat = 5
    
    @IBInspectable var barStartIsZero: Bool = true
    @IBInspectable var defaultBarColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var barsAreReversed: Bool = false
    @IBInspectable var windowMargin: CGFloat = 25
    @IBInspectable var emptyWindowSize: CGFloat = 2
    @IBInspectable var exactWindow: Bool = false
    
    @IBInspectable var bgColor: UIColor = UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1.0)
    @IBInspectable var bgStrokeWidth: CGFloat = 1
    @IBInspectable var bgStrokeColor: UIColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
    
    @IBInspectable var axisLineColor: UIColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
    @IBInspectable var axisLineWidth: CGFloat = 2
    
    @IBInspectable var gridLineColor: UIColor = UIColor(red: 232 / 255, green: 232 / 255, blue: 232 / 255, alpha: 1.0)
    @IBInspectable var gridLineWidth: CGFloat = 1
    @IBInspectable var gridUnits: String = ""
    
    @IBInspectable var labelMarginScale: String = "vertical"
    @IBInspectable var labelMargin: CGFloat = 5
    @IBInspectable var labelSize: CGFloat = 4
    @IBInspectable var labelColor: UIColor = UIColor.lightGrayColor()
    
    @IBInspectable var keyX_Scale: String = "vertical"
    @IBInspectable var keyY_Scale: String = "vertical"
    @IBInspectable var keySize_Scale: String = "vertical"
    
    @IBInspectable var keyEnabled: Bool = true
    @IBInspectable var keyMode: String = "bars" // can be either "bars" or "segments"
    @IBInspectable var keyX: CGFloat = 110
    @IBInspectable var keyY: CGFloat = 50
    
    @IBInspectable var swatchSize: CGFloat = 5
    @IBInspectable var swatchGap: CGFloat = 2.5
    @IBInspectable var swatchFontSize: CGFloat = 5
    @IBInspectable var swatchFontMargin: CGFloat = 2.5
    @IBInspectable var swatchFontColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var swatchDefault: UIColor = UIColor.darkGrayColor()
    
    private let gridThresholds: [(CGFloat, CGFloat)] = [
        (1.0, 0.25),
        (2.5, 0.5),
        (5.0, 1.0),
        (10.0, 2.0)
    ]
    
    internal var colors: [String : UIColor] = [:]
    internal var data: [BarGraphDataSet] = []
    
    private var graphingArea: CGRect = CGRect()
    private var barSpacingAbsolute: CGFloat = 0
    private var barGroupSpacingAbsolute: CGFloat = 0
    private var barWidthAbsolute: CGFloat = 0
    private var barLengthExtreme: CGFloat = 0
    private var barLengthOppositeExtreme: CGFloat = 0
    private var gridSpacing: CGFloat = 0
    private var graphingWindow: (startValue: CGFloat, length: CGFloat) = (0, 0)
    
    override func drawRect(rect: CGRect) {
        determineGraphingArea()
        determineBarWidths()
        determineBarLengthExtremes()
        determineBarLengthGridLineSpacing()
        determineBarLengthWindow()
        drawBackground()
        drawAxisLine()
        drawGridLines()
        drawBars()
        if keyEnabled {
            drawKey()
        }
    }
    
    private func determineGraphingArea() {
        var rectX: CGFloat = 0
        var rectY: CGFloat = 0
        var rectWidth: CGFloat = 0
        var rectHeight: CGFloat = 0
        
        if graphAreaWidth_Scale == "horizontal" {
            rectWidth = self.bounds.width * graphAreaWidth * 0.01
        }
        if graphAreaWidth_Scale == "vertical" {
            rectWidth = self.bounds.height * graphAreaWidth * 0.01
        }
        
        if graphAreaHeight_Scale == "horizontal" {
            rectHeight = self.bounds.width * graphAreaHeight * 0.01
        }
        if graphAreaHeight_Scale == "vertical" {
            rectHeight = self.bounds.height * graphAreaHeight * 0.01
        }
        if graphAreaX_Scale == "horizontal" {
            rectX = self.bounds.width * graphAreaX * 0.01 - rectWidth * 0.5
        }
        if graphAreaX_Scale == "vertical" {
            rectX = self.bounds.height * graphAreaX * 0.01 - rectWidth * 0.5
        }
        
        if graphAreaY_Scale == "horizontal" {
            rectY = self.bounds.width * graphAreaY * 0.01 - rectHeight * 0.5
        }
        if graphAreaY_Scale == "vertical" {
            rectY = self.bounds.height * graphAreaY * 0.01 - rectHeight * 0.5
        }
        
        graphingArea = CGRect(
            x: rectX,
            y: rectY,
            width: rectWidth,
            height: rectHeight
        )
    }
    
    private func determineBarWidths() {
        if barSizing_Scale == "horizontal" {
            barSpacingAbsolute = self.bounds.width * barSpacing * 0.01
            barGroupSpacingAbsolute = self.bounds.width * barGroupSpacing * 0.01
        }
        if barSizing_Scale == "vertical" {
            barSpacingAbsolute = self.bounds.height * barSpacing * 0.01
            barGroupSpacingAbsolute = self.bounds.height * barGroupSpacing * 0.01
        }
        
        var mostBars: Int = 0
        
        for dataSet: BarGraphDataSet in data {
            if dataSet.bars.count > mostBars {
                mostBars = dataSet.bars.count
            }
        }
        
        var availableDistance: CGFloat = 0
        
        if barDirection == "vertical" {
            availableDistance = graphingArea.width
        }
        if barDirection == "horizontal" {
            availableDistance = graphingArea.height
        }
        
        let combinedWidthOfBars: CGFloat = availableDistance - CGFloat(mostBars + 1) * barGroupSpacingAbsolute - CGFloat(data.count - 1) * barSpacingAbsolute * CGFloat(mostBars)
        let numberOfBars: Int = mostBars * data.count
        barWidthAbsolute = combinedWidthOfBars / CGFloat(numberOfBars)
    }
    
    private func determineBarLengthExtremes() {
        barLengthExtreme = 0
        for dataSet: BarGraphDataSet in data {
            for bar: BarGraphBar in dataSet.bars {
                if abs(bar.length) > abs(barLengthExtreme) {
                    barLengthExtreme = bar.length
                }
            }
        }
        
        barLengthOppositeExtreme = barLengthExtreme
        for dataSet: BarGraphDataSet in data {
            for bar: BarGraphBar in dataSet.bars {
                if abs(bar.length - barLengthExtreme) > abs(barLengthOppositeExtreme - barLengthExtreme) {
                    barLengthOppositeExtreme = bar.length
                }
            }
        }
    }
    
    private func determineBarLengthGridLineSpacing() {
        var difference: CGFloat = 0
        
        if barStartIsZero {
            if barLengthExtreme != 0 {
                difference = abs(barLengthExtreme)
            } else {
                difference = emptyWindowSize
            }
        } else if barLengthExtreme == barLengthOppositeExtreme {
            difference = emptyWindowSize
        } else {
            difference = abs(barLengthExtreme - barLengthOppositeExtreme)
        }
        
        let differenceBaseTenFloor: CGFloat = floor(log10(difference))
        let differenceSpacingUnit: CGFloat = pow(10, differenceBaseTenFloor)
        
        for var i: Int = gridThresholds.count - 1; i >= 0; --i {
            if abs(difference) <= differenceSpacingUnit * gridThresholds[i].0 {
                gridSpacing = differenceSpacingUnit * gridThresholds[i].1
            }
        }
    }
    
    private func determineBarLengthWindow() {
        func increaseMagnitude(number: CGFloat, increaseBy: CGFloat) -> CGFloat {
            if number == 0 {
                return 0
            } else if increaseBy == 0 {
                return number
            } else if number < 0 {
                return number - increaseBy
            } else {
                return number + increaseBy
            }
        }
        
        var a: CGFloat = 0
        var b: CGFloat = 0
        var barLengthMarginAbsolute: CGFloat = 0
        
        if barLengthExtreme == 0 {
            if barStartIsZero {
                a = 0
                b = emptyWindowSize
            } else {
                a = emptyWindowSize * -0.5
                b = emptyWindowSize * +0.5
            }
        } else {
            if exactWindow {
                if barStartIsZero {
                    barLengthMarginAbsolute = abs(barLengthExtreme) * windowMargin * 0.01
                    a = 0
                    if barLengthExtreme == 0 {
                        b = emptyWindowSize
                    } else {
                        b = increaseMagnitude(barLengthExtreme, barLengthMarginAbsolute)
                    }
                } else {
                    if barLengthExtreme == barLengthOppositeExtreme {
                        a = barLengthExtreme - emptyWindowSize * 0.5
                        b = barLengthExtreme + emptyWindowSize * 0.5
                    } else {
                        barLengthMarginAbsolute = abs(barLengthExtreme - barLengthOppositeExtreme) * windowMargin * 0.01
                        if barLengthExtreme > 0 {
                            a = barLengthExtreme + barLengthMarginAbsolute
                            b = barLengthOppositeExtreme - barLengthMarginAbsolute
                        } else if barLengthExtreme < 0 {
                            a = barLengthExtreme - barLengthMarginAbsolute
                            b = barLengthOppositeExtreme + barLengthMarginAbsolute
                        }
                    }
                }
            } else {
                if barStartIsZero {
                    barLengthMarginAbsolute = abs(barLengthExtreme) * windowMargin * 0.01
                    a = 0
                    if barLengthExtreme == 0 {
                        b = emptyWindowSize
                    } else {
                        while abs(b) < abs(increaseMagnitude(barLengthExtreme, barLengthMarginAbsolute)) {
                            if barLengthExtreme > 0 {
                                b += gridSpacing
                            } else {
                                b -= gridSpacing
                            }
                        }
                    }
                } else {
                    var conditionA: Void -> Bool
                    var conditionB: Void -> Bool
                    var multiplier: CGFloat
                    
                    if barLengthExtreme == barLengthOppositeExtreme {
                        barLengthMarginAbsolute = emptyWindowSize * 0.5
                    } else {
                        barLengthMarginAbsolute = abs(barLengthExtreme - barLengthOppositeExtreme) * windowMargin * 0.01
                    }
                    
                    if barLengthExtreme >= 0 {
                        conditionA = {return a < self.barLengthExtreme + barLengthMarginAbsolute}
                        conditionB = {return b > self.barLengthOppositeExtreme - barLengthMarginAbsolute}
                        multiplier = 1
                    } else {
                        conditionA = {return a > self.barLengthExtreme - barLengthMarginAbsolute}
                        conditionB = {return b < self.barLengthOppositeExtreme + barLengthMarginAbsolute}
                        multiplier = -1
                    }
                    
                    a = 0
                    
                    while conditionA() {
                        a += gridSpacing * multiplier
                    }
                    
                    b = a
                    
                    while conditionB() {
                        b -= gridSpacing * multiplier
                    }
                }
            }
        }
        
        if a < b {
            graphingWindow.startValue = a
            graphingWindow.length = abs(a - b)
        } else if a > b {
            graphingWindow.startValue = b
            graphingWindow.length = abs(a - b)
        } else {
            graphingWindow.startValue = a - emptyWindowSize * 0.5
            graphingWindow.length = emptyWindowSize
        }
    }
    
    private func drawBackground() {
        let context = UIGraphicsGetCurrentContext()
        let bgRect = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
        CGContextAddRect(context, bgRect)
        CGContextSetFillColorWithColor(context, bgColor.CGColor)
        CGContextFillRect(context, bgRect)
        CGContextSetLineWidth(context, bgStrokeWidth)
        CGContextSetStrokeColorWithColor(context, bgStrokeColor.CGColor)
        CGContextStrokeRect(context, bgRect)
    }
    
    private func drawAxisLine() {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, axisLineWidth)
        CGContextSetStrokeColorWithColor(context, axisLineColor.CGColor)
        
        if barDirection == "vertical" {
            let lineY:CGFloat = translateY(0)
            if !(lineY < graphingArea.minY || lineY > graphingArea.maxY) {
                CGContextMoveToPoint(context, graphingArea.minX, lineY)
                CGContextAddLineToPoint(context, graphingArea.maxX, lineY)
                CGContextStrokePath(context)
            }
        }
        if barDirection == "horizontal" {
            let lineX:CGFloat = translateX(0)
            if !(lineX < graphingArea.minX || lineX > graphingArea.maxX) {
                CGContextMoveToPoint(context, lineX, graphingArea.minY)
                CGContextAddLineToPoint(context, lineX, graphingArea.maxY)
                CGContextStrokePath(context)
            }
        }
    }
    
    private func drawGridLines() {
        var lineFunction: CGFloat -> () = {x in}
        
        if barDirection == "horizontal" {
            lineFunction = verticalGridLine
        }
        if barDirection == "vertical" {
            lineFunction = horizontalGridLine
        }
        
        for var i: CGFloat = 0; i <= graphingWindow.startValue + graphingWindow.length; i += gridSpacing {
            if i >= graphingWindow.startValue {
                lineFunction(i)
            }
        }
        for var i: CGFloat = 0; i >= graphingWindow.startValue; i -= gridSpacing {
            if i <= graphingWindow.startValue + graphingWindow.length {
                lineFunction(i)
            }
        }
    }
    
    private func horizontalGridLine(y: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        if y != 0 {
            CGContextSetLineWidth(context, gridLineWidth)
            CGContextSetStrokeColorWithColor(context, gridLineColor.CGColor)
            CGContextMoveToPoint(context, graphingArea.minX, translateY(y))
            CGContextAddLineToPoint(context, graphingArea.maxX, translateY(y))
            CGContextStrokePath(context)
        }
        
        // This part draws the label to the left of the line.
        var prelimText: String = ""
        
        // This converts the numbers to scientific notation if the spacing is 10,000+
        if gridSpacing < 10000 {
            prelimText = String(format: "%.\(getPrecision(gridSpacing))f", y)
        } else {
            var formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.ScientificStyle
            prelimText = formatter.stringFromNumber(y)!
        }
        
        var labelMarginAbsolute: CGFloat = 0
        if labelMarginScale == "horizontal" {
            labelMarginAbsolute = labelMargin / 100 * self.bounds.width
        }
        if labelMarginScale == "vertical" {
            labelMarginAbsolute = labelMargin / 100 * self.bounds.height
        }
        
        let text: NSString = (("\(prelimText)" + "\(gridUnits)") as NSString)
        let textRect: CGRect = CGRectMake(0,
            translateY(y) - labelSize / 100 * self.bounds.height * 0.5,
            graphingArea.minX - labelMarginAbsolute,
            labelSize / 100 * self.bounds.height)
        let font: UIFont = UIFont(name: "Helvetica Neue", size: labelSize / 100 * self.bounds.height)!
        var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Right
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: labelColor,
            NSParagraphStyleAttributeName: textStyle]
        text.drawInRect(textRect, withAttributes: textAttributes)
    }
    
    private func verticalGridLine(x: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        if x != 0 {
            CGContextSetLineWidth(context, gridLineWidth)
            CGContextSetStrokeColorWithColor(context, gridLineColor.CGColor)
            CGContextMoveToPoint(context, translateX(x), graphingArea.minY)
            CGContextAddLineToPoint(context, translateX(x), graphingArea.maxY)
            CGContextStrokePath(context)
        }
        
        // This part draws the label to the left of the line.
        var prelimText: String = ""
        
        // This converts the numbers to scientific notation if the spacing is 10,000+
        if gridSpacing < 10000 {
            prelimText = String(format: "%.\(getPrecision(gridSpacing))f", x)
        } else {
            var formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.ScientificStyle
            prelimText = formatter.stringFromNumber(x)!
        }
        
        let text: NSString = (("\(prelimText)" + "\(gridUnits)") as NSString)
        
        var labelMarginAbsolute: CGFloat = 0
        if labelMarginScale == "horizontal" {
            labelMarginAbsolute = labelMargin / 100 * self.bounds.width
        }
        if labelMarginScale == "vertical" {
            labelMarginAbsolute = labelMargin / 100 * self.bounds.height
        }
        
        let labelSizeAbsolute = labelSize / 100 * self.bounds.height
        let textRect: CGRect = CGRectMake(translateX(x) - labelSizeAbsolute * 0.5,
            self.bounds.height,
            (self.bounds.height - graphingArea.height) * 0.5 - labelMarginAbsolute,
            labelSizeAbsolute)
        let font: UIFont = UIFont(name: "Helvetica Neue", size: labelSize / 100 * self.bounds.height)!
        var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Right
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: labelColor,
            NSParagraphStyleAttributeName: textStyle]
        
        CGContextSaveGState(context)
        let transform: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(270 * M_PI / 180))
        CGContextTranslateCTM(context, textRect.minX, textRect.minY)
        CGContextConcatCTM(context, transform)
        CGContextTranslateCTM(context, -textRect.minX, -textRect.minY)
        text.drawInRect(textRect, withAttributes: textAttributes)
        CGContextRestoreGState(context)
    }
    
    private func drawBars() {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        
        CGContextClipToRect(context, graphingArea)
        
        for i in 0..<data.count {
            for j in 0..<data[i].bars.count {
                var barWidthPosition: CGFloat = 0
                var upToNowSegmentTotal: CGFloat = 0
                if barDirection == "vertical" {
                    barWidthPosition = graphingArea.minX + barGroupSpacingAbsolute + CGFloat(j) * (barGroupSpacingAbsolute + CGFloat(data.count) * barWidthAbsolute + CGFloat(data.count - 1) * barSpacingAbsolute) + CGFloat(i) * (barSpacingAbsolute + barWidthAbsolute)
                }
                if barDirection == "horizontal" {
                    barWidthPosition = graphingArea.minY + barGroupSpacingAbsolute + CGFloat(j) * (barGroupSpacingAbsolute + CGFloat(data.count) * barWidthAbsolute + CGFloat(data.count - 1) * barSpacingAbsolute) + CGFloat(i) * (barSpacingAbsolute + barWidthAbsolute)
                }
                
                for k in 0..<data[i].bars[j].segments.count {
                    var segmentRect: CGRect = CGRect()
                    
                    if barDirection == "vertical" {
                        let a: CGFloat = translateY(upToNowSegmentTotal)
                        let b: CGFloat = translateY(upToNowSegmentTotal + data[i].bars[j].segments[k].length)
                        upToNowSegmentTotal += data[i].bars[j].segments[k].length
                        
                        var rectY: CGFloat
                        
                        if a > b {
                            rectY = b
                        } else {
                            rectY = a
                        }
                        
                        segmentRect = CGRect(
                            x: barWidthPosition,
                            y: rectY,
                            width: barWidthAbsolute,
                            height: abs(a - b)
                        )
                    }
                    if barDirection == "horizontal" {
                        let a: CGFloat = translateX(upToNowSegmentTotal)
                        let b: CGFloat = translateX(upToNowSegmentTotal + data[i].bars[j].segments[k].length)
                        upToNowSegmentTotal += data[i].bars[j].segments[k].length
                        
                        var rectX: CGFloat
                        
                        if a > b {
                            rectX = b
                        } else {
                            rectX = a
                        }
                        
                        segmentRect = CGRect(
                            x: rectX,
                            y: barWidthPosition,
                            width: abs(a - b),
                            height: barWidthAbsolute
                        )
                    }
                    
                    if colors[data[i].bars[j].segments[k].name] == nil {
                        CGContextSetFillColorWithColor(context, defaultBarColor.CGColor)
                    } else {
                        CGContextSetFillColorWithColor(context, colors[data[i].bars[j].segments[k].name]!.CGColor)
                    }
                    CGContextAddRect(context, segmentRect)
                    CGContextFillRect(context, segmentRect)
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    private func drawKey() {
        var keyCoords: CGPoint = CGPoint()
        var keySizeUnit: CGFloat = 0
        
        if keyX_Scale == "horizontal" {
            keyCoords.x = self.bounds.width * keyX * 0.01
        }
        if keyX_Scale == "vertical" {
            keyCoords.x = self.bounds.height * keyX * 0.01
        }
        if keyY_Scale == "horizontal" {
            keyCoords.y = self.bounds.width * keyY * 0.01
        }
        if keyY_Scale == "vertical" {
            keyCoords.y = self.bounds.height * keyY * 0.01
        }
        if keySize_Scale == "horizontal" {
            keySizeUnit = self.bounds.width * 0.01
        }
        if keySize_Scale == "vertical" {
            keySizeUnit = self.bounds.height * 0.01
        }
        
        let swatchSizeAbsolute: CGFloat = keySizeUnit * swatchSize
        let swatchGapAbsolute: CGFloat = keySizeUnit * swatchGap
        let swatchFontMarginAbsolute: CGFloat = keySizeUnit * swatchFontMargin
        let swatchFontSizeAbsolute: CGFloat = keySizeUnit * swatchFontSize
        
        var totalSwatches: Int = 0
        
        if keyMode == "segments" {
            totalSwatches = colors.count
        }
        if keyMode == "bars" {
            totalSwatches = data.count
        }
        
        let totalHeight: CGFloat = swatchSizeAbsolute * CGFloat(totalSwatches) + swatchGapAbsolute * CGFloat(totalSwatches - 1)
        let startY: CGFloat = keyCoords.y - totalHeight * 0.5
        let context = UIGraphicsGetCurrentContext()
        
        func drawSwatch(name: String, color: UIColor, i: Int) {
            let rectangle = CGRect(
                x: keyCoords.x - swatchSizeAbsolute * 0.5,
                y: startY + CGFloat(i) * (swatchSizeAbsolute + swatchGapAbsolute),
                width: swatchSizeAbsolute,
                height: swatchSizeAbsolute
            )
            CGContextAddRect(context, rectangle)
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, rectangle)
            
            let text: NSString = (name as NSString)
            let textRect: CGRect = CGRect(
                x: keyCoords.x + swatchSizeAbsolute * 0.5 + swatchFontMarginAbsolute,
                y: startY + (CGFloat(i) + 0.5) * swatchSizeAbsolute + CGFloat(i) * swatchGapAbsolute - swatchFontSizeAbsolute * 0.625,
                width: self.bounds.width - keyCoords.x - swatchGapAbsolute - swatchFontMarginAbsolute,
                height: swatchFontSizeAbsolute * 1.25
            )
            let font: UIFont = UIFont(name: "Helvetica Neue", size: swatchFontSizeAbsolute)!
            var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            let textAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: swatchFontColor,
                NSParagraphStyleAttributeName: textStyle]
            text.drawInRect(textRect, withAttributes: textAttributes)
        }
        
        
        var i: Int = 0
        if keyMode == "segments" {
            for (name, color) in colors {
                drawSwatch(name, color, i)
                i += 1
            }
        }
        if keyMode == "bars" {
            for dataSet: BarGraphDataSet in data {
                var swatchColor: UIColor
                
                // Messy AF
                if dataSet.bars.count > 0 {
                    if dataSet.bars[0].segments.count > 0 {
                        if colors[dataSet.bars[0].segments[0].name] != nil {
                            swatchColor = colors[dataSet.bars[0].segments[0].name]!
                        } else {
                            swatchColor = swatchDefault
                        }
                    } else {
                        swatchColor = swatchDefault
                    }
                } else {
                    swatchColor = swatchDefault
                }
                // End messy AF
                
                drawSwatch(dataSet.name, swatchColor, i)
                i += 1
            }
        }

    }
    
    // This function translates x in the graphing window's coordinate system to x in the graphing area's coordinate system.
    private func translateX(x: CGFloat) -> CGFloat {
        if barsAreReversed {
            return graphingArea.maxX - graphingArea.width * (x - graphingWindow.startValue) / (graphingWindow.length)
        } else {
            return graphingArea.minX + graphingArea.width * (x - graphingWindow.startValue) / (graphingWindow.length)
        }
    }
    
    // This function translates y in the graphing window's coordinate system to y in the graphing area's coordinate system.
    private func translateY(y: CGFloat) -> CGFloat {
        if barsAreReversed {
            return graphingArea.minY + graphingArea.height * (y - graphingWindow.startValue) / (graphingWindow.length)
        } else {
            return graphingArea.maxY - graphingArea.height * (y - graphingWindow.startValue) / (graphingWindow.length)
        }
    }
    
    // This returns the precision of a CGFloat.
    func getPrecision(value: CGFloat) -> Int {
        var tens: CGFloat = 1.0
        var precision: Int = 0
        
        while (floor((value * tens) + 0.1) / tens) != value {
            tens *= 10
            precision++
        }
        
        return precision
    }
}
