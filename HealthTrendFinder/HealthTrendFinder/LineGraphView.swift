//
//  GraphView.swift
//  
//
//  Created by David Charatan on 7/31/15.
//
//

import UIKit

@IBDesignable
class LineGraphView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var baseColor: UIColor = UIColor(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255, alpha: 1)
    
    @IBInspectable var independentY: Bool = true
    @IBInspectable var yEmptyWindow: CGFloat = 2
    @IBInspectable var yMargin: CGFloat = 20
    
    @IBInspectable var boundsLineColor: UIColor = UIColor.whiteColor()
    @IBInspectable var boundsFontColor: UIColor = UIColor.whiteColor()
    @IBInspectable var boundsFontSize: CGFloat = 5
    @IBInspectable var boundsFontSize_scaleIsBasedOnY: Bool = true
    @IBInspectable var boundsFontMargin: CGFloat = 2.5
    @IBInspectable var boundsFontMargin_scaleIsBasedOnY: Bool = true
    @IBInspectable var boundsMarkerSize: CGFloat = 5
    @IBInspectable var boundsMarkerSize_scaleIsBasedOnY: Bool = true
    
    @IBInspectable var dataMarkerSize: CGFloat = 3
    @IBInspectable var dataLineSize: CGFloat = 1
    
    @IBInspectable var labelFontSize: CGFloat = 5
    @IBInspectable var labelFontSize_scaleIsBasedOnY: Bool = true
    @IBInspectable var labelFontColor: UIColor = UIColor.whiteColor()
    
    @IBInspectable var topMargin: CGFloat = 15
    @IBInspectable var topMargin_scaleIsBasedOnY: Bool = true
    @IBInspectable var sideMargin: CGFloat = 10
    @IBInspectable var sideMargin_scaleIsBasedOnY: Bool = true
    @IBInspectable var bottomMargin: CGFloat = 15
    @IBInspectable var bottomMargin_scaleIsBasedOnY: Bool = true
    
    @IBInspectable var dataSetLabelFontSize: CGFloat = 5
    @IBInspectable var dataSetLabelFontSize_scaleIsBasedOnY: Bool = true
    
    @IBInspectable var shadowSize: CGFloat = 1
    @IBInspectable var shadowColor: UIColor = UIColor(white: 0, alpha: 0.1)
    
    internal var thresholds: [(maxValue: CGFloat, roundTo: CGFloat)] = [
        (1.0, 0.1),
        (2.5, 0.25),
        (5.0, 0.5),
        (10.0, 1.0)
    ]
    enum graphModes {
        case Day
        case Week
    }
    internal var graphMode: graphModes = graphModes.Week
    internal var dataColors: [UIColor] = [
        UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1),
        UIColor(red: 175 / 255, green: 175 / 255, blue: 175 / 255, alpha: 1),
        UIColor(red: 125 / 255, green: 125 / 255, blue: 125 / 255, alpha: 1)
    ]
    internal var data: [LineGraphDataSet] = []
    
    private var extremes: [LineGraphDataSet:CGFloat] = [:]
    private var oppositeExtremes: [LineGraphDataSet:CGFloat] = [:]
    private var mutualExtreme: CGFloat = 0
    private var mutualOppositeExtreme: CGFloat = 0
    
    private var yWindows: [LineGraphDataSet: (minY: CGFloat, maxY: CGFloat)] = [:]
    private var yWindowMutual: (minY: CGFloat, maxY: CGFloat) = (0, 0)
    
    private var xWindow: (minX: NSDate, maxX: NSDate) = (NSDate(), NSDate())
    
    private var graphingArea: CGRect = CGRect()
    
    override func drawRect(rect: CGRect) {
        reset()
        drawBackground()
        determineExtremes()
        if !independentY {
            determineMutualExtremes()
        }
        determineYWindows()
        determineXWindow()
        determineGraphingArea()
        drawAverageLines()
        drawDataLines()
        drawGraphingAreaBoundryLines()
        drawGraphingAreaBoundryLabels()
        drawDateLabels()
        drawDataSetNames()
    }
    
    // This function is needed to prevent black backgrounds from appearing when drawRect is overridden.
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
    }
    
    private func reset() {
        extremes = [:]
        oppositeExtremes = [:]
        yWindows = [:]
    }
    
    private func drawBackground() {
        // This rounds the corners.
        let clippingPath: UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        clippingPath.addClip()
        
        // This draws the background.
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        let baseRect: CGRect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - shadowSize)
        
        CGContextAddRect(context, self.bounds)
        CGContextSetFillColorWithColor(context, baseColor.CGColor)
        CGContextFillRect(context, self.bounds)
        
        CGContextAddRect(context, self.bounds)
        CGContextSetFillColorWithColor(context, shadowColor.CGColor)
        CGContextFillRect(context, self.bounds)
        
        let basePath: UIBezierPath = UIBezierPath(roundedRect: baseRect, cornerRadius: cornerRadius)
        baseColor.setFill()
        basePath.fill()
    }
    
    private func determineExtremes() {
        for dataSet: LineGraphDataSet in data {
            extremes[dataSet] = 0
            for point: (x: NSDate, y: CGFloat) in dataSet.points {
                if abs(point.y) > abs(extremes[dataSet]!) {
                    extremes[dataSet] = point.y
                }
            }
            oppositeExtremes[dataSet] = extremes[dataSet]
            for point: (x: NSDate, y: CGFloat) in dataSet.points {
                if abs(point.y - extremes[dataSet]!) > abs(oppositeExtremes[dataSet]! - extremes[dataSet]!) {
                    oppositeExtremes[dataSet] = point.y
                }
            }
        }
    }
    
    private func determineMutualExtremes() {
        mutualExtreme = 0
        for (key: LineGraphDataSet, currentExtreme: CGFloat) in extremes {
            if abs(currentExtreme) > abs(mutualExtreme) {
                mutualExtreme = currentExtreme
            }
        }
        mutualOppositeExtreme = mutualExtreme
        for (key: LineGraphDataSet, currentExtreme: CGFloat) in extremes {
            if abs(currentExtreme - mutualOppositeExtreme) > abs(mutualExtreme - mutualOppositeExtreme) {
                mutualExtreme = currentExtreme
            }
        }
        for (key: LineGraphDataSet, currentExtreme: CGFloat) in oppositeExtremes {
            if abs(currentExtreme - mutualOppositeExtreme) > abs(mutualExtreme - mutualOppositeExtreme) {
                mutualExtreme = currentExtreme
            }
        }
    }
    
    private func determineYWindows() {
        func determineWindowForChunk(extreme: CGFloat, oppositeExtreme: CGFloat) -> (minY: CGFloat, maxY: CGFloat){
            var distance: CGFloat = 0
            if extreme == oppositeExtreme {
                var returnValue: (minY: CGFloat, maxY: CGFloat)
                returnValue.minY = extreme - yEmptyWindow * 0.5
                returnValue.maxY = extreme + yEmptyWindow * 0.5
                return returnValue
            } else {
                distance = abs(extreme - oppositeExtreme)
            }
            
            let distanceBaseTenFloor: CGFloat = floor(log10(distance))
            let distanceUnit: CGFloat = pow(10, distanceBaseTenFloor)
            var roundingTarget: CGFloat = 0
            for var i: Int = 0; i < thresholds.count; ++i {
                if distance < distanceUnit * thresholds[i].maxValue {
                    roundingTarget = distanceUnit * thresholds[i].roundTo
                    break
                }
            }
            
            let margin: CGFloat = distance * yMargin * 0.01
            var prelimMaxY: CGFloat = 0
            var prelimMinY: CGFloat = 0
            
            if extreme > oppositeExtreme {
                prelimMaxY = extreme + margin
                prelimMinY = oppositeExtreme - margin
            } else {
                prelimMaxY = oppositeExtreme + margin
                prelimMinY = extreme - margin
            }
            
            var returnValue: (minY: CGFloat, maxY: CGFloat)
            returnValue.minY = roundingTarget * round(prelimMinY / roundingTarget)
            returnValue.maxY = roundingTarget * round(prelimMaxY / roundingTarget)
            
            return returnValue
        }
        
        if independentY {
            for dataSet: LineGraphDataSet in data {
                yWindows[dataSet] = determineWindowForChunk(extremes[dataSet]!, oppositeExtremes[dataSet]!)
            }
        } else {
            yWindowMutual = determineWindowForChunk(mutualExtreme, mutualOppositeExtreme)
        }
    }
    
    private func determineXWindow() {
        var dates: [NSDate] = []
        for dataSet: LineGraphDataSet in data {
            for point: (x: NSDate, y: CGFloat) in dataSet.points {
                dates += [point.x]
            }
        }
        
        if dates.count > 0 {
            var latestDate: NSDate = dates[0]
            for date: NSDate in dates {
                if date.timeIntervalSinceDate(latestDate) > 0 {
                    latestDate = date
                }
            }
            let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            switch graphMode {
            case graphModes.Day:
                xWindow.minX = calendar.startOfDayForDate(latestDate)
                xWindow.maxX = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: xWindow.minX, options: nil)!
            case graphModes.Week:
                var currentDateComponents: NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYearForWeekOfYear | NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: latestDate)
                xWindow.minX = calendar.dateFromComponents(currentDateComponents)!
                xWindow.maxX = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitWeekOfYear, value: 1, toDate: xWindow.minX, options: nil)!
            }
        }
    }
    
    private func determineGraphingArea() {
        var topMarginAbsolute: CGFloat
        if topMargin_scaleIsBasedOnY {
            topMarginAbsolute = topMargin * 0.01 * self.bounds.height
        } else {
            topMarginAbsolute = topMargin * 0.01 * self.bounds.width
        }
        
        var sideMarginAbsolute: CGFloat
        if sideMargin_scaleIsBasedOnY {
            sideMarginAbsolute = sideMargin * 0.01 * self.bounds.height
        } else {
            sideMarginAbsolute = sideMargin * 0.01 * self.bounds.width
        }
        
        var bottomMarginAbsolute: CGFloat
        if bottomMargin_scaleIsBasedOnY {
            bottomMarginAbsolute = bottomMargin * 0.01 * self.bounds.height
        } else {
            bottomMarginAbsolute = bottomMargin * 0.01 * self.bounds.width
        }
        
        graphingArea = CGRect(x: sideMarginAbsolute,
            y: topMarginAbsolute,
            width: self.bounds.width - 2 * sideMarginAbsolute,
            height: self.bounds.height - topMarginAbsolute - bottomMarginAbsolute)
    }
    
    private func drawAverageLines() {
        for i: Int in 0..<data.count {
            var total: CGFloat = 0
            for point: (x: NSDate, y: CGFloat) in data[i].points {
                total += point.y
            }
            let average: CGFloat = total / CGFloat(data[i].points.count)
            
            var window: (minY: CGFloat, maxY: CGFloat)
            if independentY {
                window = yWindows[data[i]]!
            } else {
                window = yWindowMutual
            }
            
            let context: CGContextRef = UIGraphicsGetCurrentContext()
            CGContextSaveGState(context)
            CGContextSetStrokeColorWithColor(context, dataColors[i].CGColor)
            CGContextSetAllowsAntialiasing(context, false)
            CGContextSetLineWidth(context, 1 / UIScreen.mainScreen().scale)
            CGContextSetLineDash(context, 0, [2, 1], 2)
            CGContextMoveToPoint(context, graphingArea.minX, translateY(average, yWindow: window))
            CGContextAddLineToPoint(context, graphingArea.maxX, translateY(average, yWindow: window))
            CGContextStrokePath(context)
            CGContextSetAllowsAntialiasing(context, true)
            CGContextRestoreGState(context)
        }
    }
    
    private func drawDataLines() {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        
        for j: Int in 0..<data.count {
            for var i: Int = 0; i < data[j].points.count; ++i {
                var window: (minY: CGFloat, maxY: CGFloat)
                if independentY {
                    window = yWindows[data[j]]!
                } else {
                    window = yWindowMutual
                }
                
                if dateInWindow(data[j].points[i].x) {
                    if i > 0 && dateInWindow(data[j].points[i - 1].x) {
                        CGContextMoveToPoint(context, translateX(data[j].points[i - 1].x), translateY(data[j].points[i - 1].y, yWindow: window))
                        CGContextAddLineToPoint(context, translateX(data[j].points[i].x), translateY(data[j].points[i].y, yWindow: window))
                        CGContextSetStrokeColorWithColor(context, dataColors[j % dataColors.count].CGColor)
                        CGContextSetLineWidth(context, dataLineSize * UIScreen.mainScreen().scale)
                        CGContextStrokePath(context)
                    }
                    
                    let markerRect: CGRect = CGRect(x: translateX(data[j].points[i].x) - dataMarkerSize * 0.5 * UIScreen.mainScreen().scale,
                        y: translateY(data[j].points[i].y, yWindow: window) - dataMarkerSize * 0.5 * UIScreen.mainScreen().scale,
                        width: dataMarkerSize * UIScreen.mainScreen().scale,
                        height: dataMarkerSize * UIScreen.mainScreen().scale)
                    CGContextAddEllipseInRect(context, markerRect)
                    CGContextSetFillColorWithColor(context, dataColors[j % dataColors.count].CGColor)
                    CGContextFillPath(context)
                }
            }
        }
    }
    
    private func drawGraphingAreaBoundryLines() {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetStrokeColorWithColor(context, boundsLineColor.CGColor)
        CGContextSetAllowsAntialiasing(context, false)
        CGContextSetLineWidth(context, 1 / UIScreen.mainScreen().scale)
        CGContextMoveToPoint(context, graphingArea.minX, graphingArea.minY)
        CGContextAddLineToPoint(context, graphingArea.maxX, graphingArea.minY)
        CGContextStrokePath(context)
        CGContextMoveToPoint(context, graphingArea.minX, graphingArea.maxY)
        CGContextAddLineToPoint(context, graphingArea.maxX, graphingArea.maxY)
        CGContextStrokePath(context)
        CGContextSetAllowsAntialiasing(context, true)
        CGContextRestoreGState(context)
    }
    
    private func drawGraphingAreaBoundryLabels() {
        var fontSizeAbsolute: CGFloat
        if boundsFontSize_scaleIsBasedOnY {
            fontSizeAbsolute = boundsFontSize * 0.01 * self.bounds.height
        } else {
            fontSizeAbsolute = boundsFontSize * 0.01 * self.bounds.width
        }
        var fontMarginAbsolute: CGFloat
        if boundsFontMargin_scaleIsBasedOnY {
            fontMarginAbsolute = boundsFontMargin * 0.01 * self.bounds.height
        } else {
            fontMarginAbsolute = boundsFontMargin * 0.01 * self.bounds.width
        }
        
        var iterations: Int
        
        if independentY {
            iterations = data.count
        } else {
            iterations = 1
        }
        
        for i: Int in 0..<iterations {
            var upperLabelText: String
            var lowerLabelText: String
            if independentY {
                upperLabelText = "\(yWindows[data[i]]!.maxY)" + "\(data[i].unit)"
                lowerLabelText = "\(yWindows[data[i]]!.minY)" + "\(data[i].unit)"
            } else {
                upperLabelText = "\(yWindowMutual.maxY)" + "\(data[i].unit)"
                lowerLabelText = "\(yWindowMutual.minY)" + "\(data[i].unit)"
            }
            drawTextAtPosition(upperLabelText,
                position: i,
                total: iterations,
                fontSizeAbsolute: fontSizeAbsolute,
                y: graphingArea.minY + fontMarginAbsolute - fontSizeAbsolute * 0.25,
                color: dataColors[i])
            drawTextAtPosition(lowerLabelText,
                position: i,
                total: iterations,
                fontSizeAbsolute: fontSizeAbsolute,
                y: graphingArea.maxY - fontMarginAbsolute - fontSizeAbsolute,
                color: dataColors[i])
        }
    }
    
    private func drawDateLabels() {
        var fontSizeAbsolute: CGFloat
        if labelFontSize_scaleIsBasedOnY {
            fontSizeAbsolute = labelFontSize * 0.01 * self.bounds.height
        } else {
            fontSizeAbsolute = labelFontSize * 0.01 * self.bounds.width
        }
        let textFont: UIFont = UIFont(name: "Helvetica Neue", size: fontSizeAbsolute)!
        
        func drawTextAtX(text: String, x: NSDate) {
            let textRectWidth: CGFloat = self.bounds.width
            let textRectX: CGFloat = translateX(x) - self.bounds.width * 0.475
            let textRect: CGRect = CGRect(x: textRectX,
                y: graphingArea.maxY + (self.bounds.height - graphingArea.maxY) * 0.5 - fontSizeAbsolute * 0.625,
                width: textRectWidth,
                height: fontSizeAbsolute * 1.25)
            var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            textStyle.alignment = NSTextAlignment.Center
            let fontAttributes: [NSObject : AnyObject] = [
                NSFontAttributeName: textFont,
                NSForegroundColorAttributeName: labelFontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            let labelText: NSString = text as NSString
            labelText.drawInRect(textRect, withAttributes: fontAttributes)
        }
        
        if graphMode == graphModes.Day {
            let fontY: CGFloat = graphingArea.maxY + (self.bounds.height - graphingArea.maxY) * 0.5 - fontSizeAbsolute * 0.5
            drawTextAtPosition("12 AM",
                position: 0,
                total: 3,
                fontSizeAbsolute: fontSizeAbsolute,
                y: fontY,
                color: labelFontColor)
            drawTextAtPosition("12 PM",
                position: 1,
                total: 3,
                fontSizeAbsolute: fontSizeAbsolute,
                y: fontY,
                color: labelFontColor)
            drawTextAtPosition("12 AM",
                position: 2,
                total: 3,
                fontSizeAbsolute: fontSizeAbsolute,
                y: fontY,
                color: labelFontColor)
        } else if graphMode == graphModes.Week {
            var mostRecentMonth: Int? = nil
            let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            for i: Int in 0..<7 {
                let currentDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: i, toDate: xWindow.minX, options: nil)!
                let currentDateComponents: NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth, fromDate: currentDate)
                
                var monthAddition: String = ""
                if currentDateComponents.month != mostRecentMonth {
                    mostRecentMonth = currentDateComponents.month
                    switch currentDateComponents.month {
                    case 1:
                        monthAddition = "Jan"
                    case 2:
                        monthAddition = "Feb"
                    case 3:
                        monthAddition = "Mar"
                    case 4:
                        monthAddition = "Apr"
                    case 5:
                        monthAddition = "May"
                    case 6:
                        monthAddition = "Jun"
                    case 7:
                        monthAddition = "Jul"
                    case 8:
                        monthAddition = "Aug"
                    case 9:
                        monthAddition = "Sep"
                    case 10:
                        monthAddition = "Oct"
                    case 11:
                        monthAddition = "Nov"
                    case 12:
                        monthAddition = "Dec"
                    default:
                        monthAddition = "---"
                    }
                    drawTextAtX("\(monthAddition) \(currentDateComponents.day)", currentDate)
                } else {
                    drawTextAtX("\(currentDateComponents.day)", currentDate)
                }
            }
        }
    }
    
    private func drawDataSetNames() {
        var dataSetLabelFontSizeAbsolute: CGFloat
        if dataSetLabelFontSize_scaleIsBasedOnY {
            dataSetLabelFontSizeAbsolute = dataSetLabelFontSize * 0.01 * self.bounds.height
        } else {
            dataSetLabelFontSizeAbsolute = dataSetLabelFontSize * 0.01 * self.bounds.width
        }
        
        for i: Int in 0..<data.count {
            let textY: CGFloat = graphingArea.minY * 0.5 - dataSetLabelFontSizeAbsolute * 0.625
            drawTextAtPosition(data[i].name,
                position: i,
                total: data.count,
                fontSizeAbsolute: dataSetLabelFontSizeAbsolute,
                y: textY,
                color: dataColors[i % dataColors.count])
        }
    }
    
    func drawTextAtPosition(text: String, position: Int, total: Int, fontSizeAbsolute: CGFloat, y: CGFloat, color: UIColor) {
        let textRectWidth: CGFloat = graphingArea.width / CGFloat(total)
        let textRectX: CGFloat = graphingArea.minX + CGFloat(position) * textRectWidth
        let textRect: CGRect = CGRect(x: textRectX,
            y: y,
            width: textRectWidth,
            height: fontSizeAbsolute * 1.25)
        var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        let textFont: UIFont = UIFont(name: "Helvetica Neue", size: fontSizeAbsolute)!
        if position == 0 {
            textStyle.alignment = NSTextAlignment.Left
        } else if position == total - 1 {
            textStyle.alignment = NSTextAlignment.Right
        } else {
            textStyle.alignment = NSTextAlignment.Center
        }
        let fontAttributes: [NSObject : AnyObject] = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: textStyle
        ]
        let labelText: NSString = text as NSString
        labelText.drawInRect(textRect, withAttributes: fontAttributes)
    }
    
    private func dateInWindow(x: NSDate) -> Bool {
        return x.timeIntervalSinceDate(xWindow.minX) >= 0 && xWindow.maxX.timeIntervalSinceDate(x) >= 0
    }
    
    private func translateX(x: NSDate) -> CGFloat {
        let partialTime: CGFloat = CGFloat(x.timeIntervalSinceDate(xWindow.minX))
        let totalTime: CGFloat = CGFloat(xWindow.maxX.timeIntervalSinceDate(xWindow.minX))
        return graphingArea.minX + graphingArea.width * (partialTime / totalTime)
    }
    
    private func translateY(y: CGFloat, yWindow: (minY: CGFloat, maxY: CGFloat)) -> CGFloat {
        let compensatedY: CGFloat = y - yWindow.minY
        let compensatedTotal: CGFloat = yWindow.maxY - yWindow.minY
        
        return graphingArea.maxY - graphingArea.height * (compensatedY / compensatedTotal)
    }
}
