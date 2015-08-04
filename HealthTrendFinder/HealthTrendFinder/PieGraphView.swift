//
//  PieGraphView.swift
//  PieGraphing
//
//  Created by David Charatan on 7/17/15.
//
//

import UIKit

@IBDesignable

class PieGraphView: UIView {
    @IBInspectable var xOfPieScale: String = "vertical"
    @IBInspectable var yOfPieScale: String = "vertical"
    @IBInspectable var xOfKeyScale: String = "vertical"
    @IBInspectable var yOfKeyScale: String = "vertical"
    @IBInspectable var xOfGuideScale: String = "vertical"
    @IBInspectable var keySizeScale: String = "vertical"
    @IBInspectable var labelSizeScale: String = "vertical"
    @IBInspectable var diameterScale: String = "vertical"
    @IBInspectable var guideLengthScale: String = "vertical"
    @IBInspectable var guideFontSizeScale: String = "vertical"
    
    @IBInspectable var pieX: CGFloat = 50
    @IBInspectable var pieY: CGFloat = 50
    @IBInspectable var innerDiameter: CGFloat = 40
    @IBInspectable var outerDiameter: CGFloat = 100
    @IBInspectable var ringGap: CGFloat = 1
    @IBInspectable var sliceGap: CGFloat = 1
    @IBInspectable var sliceColor: UIColor = UIColor.darkGrayColor()
    
    @IBInspectable var guideEnabled: Bool = true
    @IBInspectable var guideLength: CGFloat = 0
    @IBInspectable var guideStartColor: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    @IBInspectable var guideEndColor: UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    @IBInspectable var guideFontSize: CGFloat = 5
    @IBInspectable var guideFontColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var guideTextX: CGFloat = 110
    
    @IBInspectable var keyEnabled: Bool = true
    @IBInspectable var keyX: CGFloat = 110
    @IBInspectable var keyY: CGFloat = 50
    
    @IBInspectable var swatchSize: CGFloat = 5
    @IBInspectable var swatchGap: CGFloat = 2.5
    @IBInspectable var swatchFontSize: CGFloat = 5
    @IBInspectable var swatchFontMargin: CGFloat = 2.5
    @IBInspectable var swatchFontColor: UIColor = UIColor.darkGrayColor()
    
    @IBInspectable var labelEnabled: Bool = true
    @IBInspectable var labelFontSize: CGFloat = 2.5
    @IBInspectable var labelBoxWidth: CGFloat = 20
    @IBInspectable var labelFontColor: UIColor = UIColor.whiteColor()
    @IBInspectable var labelInPercent: Bool = false
    @IBInspectable var labelPrecision: Int = 1
    @IBInspectable var labelUnit: String = ""
    
    internal var data: [PieGraphDataSet] = []
    internal var colors: [String : UIColor] = [:]
    
    private var pieCenter: CGPoint = CGPoint()
    
    private var keyCoords: CGPoint = CGPoint()
    private var keySizeUnit: CGFloat = 0
    
    private var absoluteRingInnerRadii: [PieGraphDataSet : CGFloat] = [:]
    private var absoluteRingOuterRadii: [PieGraphDataSet : CGFloat] = [:]
    private var sliceGapAbsolute: CGFloat = 0
    
    override func drawRect(rect: CGRect) {
        clearDictionaries()
        sortData()
        determinePiePosition()
        determineRingDimensions()
        if guideEnabled {
            drawGuide()
        }
        drawRings()
        determineKeyScaling()
        if keyEnabled {
            drawKey()
        }
    }
    
    // This function is needed to prevent black backgrounds from appearing when drawRect is overridden.
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
    }
    
    private func clearDictionaries() {
        absoluteRingInnerRadii = [:]
        absoluteRingOuterRadii = [:]
    }
    
    private func sortData() {
        for dataSet: PieGraphDataSet in data {
            dataSet.slices.sort({$0.name < $1.name})
        }
    }
    
    private func determinePiePosition() {
        if xOfPieScale == "horizontal" {
            pieCenter.x = self.bounds.width * pieX * 0.01
        }
        if xOfPieScale == "vertical" {
            pieCenter.x = self.bounds.height * pieX * 0.01
        }
        if yOfPieScale == "horizontal" {
            pieCenter.y = self.bounds.width * pieY * 0.01
        }
        if yOfPieScale == "vertical" {
            pieCenter.y = self.bounds.height * pieY * 0.01
        }
    }
    
    private func determineRingDimensions() {
        var outermostRadiusAbsolute: CGFloat = 0
        var innermostRadiusAbsolute: CGFloat = 0
        var ringGapAbsolute: CGFloat = 0
        var trueInnermostRadiusAbsolute: CGFloat = 0
        
        if diameterScale == "horizontal" {
            outermostRadiusAbsolute = self.bounds.width * outerDiameter * 0.005
            innermostRadiusAbsolute = self.bounds.width * innerDiameter * 0.005
            ringGapAbsolute = self.bounds.width * ringGap * 0.01
            sliceGapAbsolute = self.bounds.width * sliceGap * 0.01
        }
        if diameterScale == "vertical" {
            outermostRadiusAbsolute = self.bounds.height * outerDiameter * 0.005
            innermostRadiusAbsolute = self.bounds.height * innerDiameter * 0.005
            ringGapAbsolute = self.bounds.height * ringGap * 0.01
            sliceGapAbsolute = self.bounds.height * sliceGap * 0.01
        }
        
        if innermostRadiusAbsolute < sliceGapAbsolute * 0.5 {
            trueInnermostRadiusAbsolute = sliceGapAbsolute * 0.5
        } else {
            trueInnermostRadiusAbsolute = innermostRadiusAbsolute
        }
        
        let combinedRingWidthAbsolute: CGFloat = outermostRadiusAbsolute - trueInnermostRadiusAbsolute - CGFloat(data.count - 1) * ringGapAbsolute
        let ringWidthAbsolute: CGFloat = combinedRingWidthAbsolute / CGFloat(data.count)
        
        for var i: Int = 0; i < data.count; ++i {
            absoluteRingInnerRadii[data[i]] = trueInnermostRadiusAbsolute + CGFloat(i) * (ringGapAbsolute + ringWidthAbsolute)
            absoluteRingOuterRadii[data[i]] = absoluteRingInnerRadii[data[i]]! + ringWidthAbsolute
        }
    }
    
    private func drawRings() {
        for dataSet: PieGraphDataSet in data {
            let context: CGContextRef = UIGraphicsGetCurrentContext()
            
            let outerSliceGapAngularDiameter: CGFloat = 2 * asin(sliceGapAbsolute * 0.5 / absoluteRingOuterRadii[dataSet]!)
            let outerTotalAngleAllocatedToData: CGFloat = 2 * CGFloat(M_PI) - CGFloat(dataSet.slices.count) * outerSliceGapAngularDiameter
            let sumOfSlices: CGFloat = dataSet.slices.reduce(0) {$0 + $1.magnitude}
            
            CGContextSaveGState(context)
            CGContextBeginTransparencyLayer(context, nil)
            
            var outerEndAngle: CGFloat = outerSliceGapAngularDiameter * -0.5
            var outerStartAngle: CGFloat = 0
            var nextOuterStartAngle: CGFloat {
                get {
                    return outerEndAngle + outerSliceGapAngularDiameter
                }
            }
            func nextOuterEndAngle(slice: PieGraphSlice) -> CGFloat {
                return outerStartAngle + slice.magnitude / sumOfSlices * outerTotalAngleAllocatedToData
            }
            var adjustedOuterStartAngle: CGFloat {
                get {
                    return CGFloat(M_PI * 2) - outerStartAngle
                }
            }
            var adjustedOuterEndAngle: CGFloat {
                get {
                    return CGFloat(M_PI * 2) - outerEndAngle
                }
            }
            
            for slice: PieGraphSlice in dataSet.slices {
                outerStartAngle = nextOuterStartAngle
                outerEndAngle = nextOuterEndAngle(slice)
                
                // This draws the arc that corresponds to each slice.
                CGContextMoveToPoint(context, pieCenter.x + cos(adjustedOuterStartAngle) * absoluteRingOuterRadii[dataSet]!, pieCenter.y + sin(adjustedOuterStartAngle) * absoluteRingOuterRadii[dataSet]!)
                CGContextAddArc(context, pieCenter.x, pieCenter.y, absoluteRingOuterRadii[dataSet]!, adjustedOuterStartAngle, adjustedOuterEndAngle, 1)
                CGContextAddLineToPoint(context, pieCenter.x, pieCenter.y)
                CGContextAddLineToPoint(context, pieCenter.x + cos(adjustedOuterStartAngle) * absoluteRingOuterRadii[dataSet]!, pieCenter.y + sin(adjustedOuterStartAngle) * absoluteRingOuterRadii[dataSet]!)
                
                // This finds the slice's name in colors and sets its color to its corresponding color in colors. If there is no specific color for it, it is assigned the default color.
                if let value = colors[slice.name] {
                    CGContextSetFillColorWithColor(context, value.CGColor)
                } else {
                    CGContextSetFillColorWithColor(context, sliceColor.CGColor)
                }
                
                CGContextFillPath(context)
            }
            
            // This makes the width of slice gaps uniform across the slice by subtracting extra fill. Because of this, only the outside of the slice is a perfectly accurate representation of the data.
            // This is in a separate loop since it must be done once all drawing is completed.
            // This is also where the labeling function is called.
            for slice: PieGraphSlice in dataSet.slices {
                outerStartAngle = nextOuterStartAngle
                outerEndAngle = nextOuterEndAngle(slice)
                
                let a: CGPoint = CGPoint(
                    x: pieCenter.x,
                    y: pieCenter.y + sliceGapAbsolute * 0.5
                )
                let b: CGPoint = CGPoint(
                    x: pieCenter.x + absoluteRingOuterRadii[dataSet]!,
                    y: pieCenter.y + sliceGapAbsolute * 0.5
                )
                let c: CGPoint = CGPoint(
                    x: pieCenter.x + absoluteRingOuterRadii[dataSet]!,
                    y: pieCenter.y - sliceGapAbsolute * 0.5
                )
                let d: CGPoint = CGPoint(
                    x: pieCenter.x,
                    y: pieCenter.y - sliceGapAbsolute * 0.5
                )
                
                CGContextSaveGState(context)
                CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
                
                let pointRotationAngle: CGFloat = adjustedOuterEndAngle - outerSliceGapAngularDiameter * 0.5
                var gapPath: UIBezierPath = UIBezierPath()
                gapPath.moveToPoint(rotatePoint(a, angle: pointRotationAngle, aroundPoint: pieCenter))
                gapPath.addLineToPoint(rotatePoint(b, angle: pointRotationAngle, aroundPoint: pieCenter))
                gapPath.addLineToPoint(rotatePoint(c, angle: pointRotationAngle, aroundPoint: pieCenter))
                gapPath.addLineToPoint(rotatePoint(d, angle: pointRotationAngle, aroundPoint: pieCenter))
                gapPath.addLineToPoint(rotatePoint(a, angle: pointRotationAngle, aroundPoint: pieCenter))
                gapPath.fill()
                
                CGContextRestoreGState(context)
                
                if labelEnabled {
                    let radius: CGFloat = (absoluteRingInnerRadii[dataSet]! + absoluteRingOuterRadii[dataSet]!) * 0.5
                    let angle: CGFloat = adjustedOuterStartAngle + (adjustedOuterEndAngle - adjustedOuterStartAngle) * 0.5
                    let segmentX: CGFloat = pieCenter.x + cos(angle) * radius
                    let segmentY: CGFloat = pieCenter.y + sin(angle) * radius
                    
                    addSegmentLabel(CGPoint(x: segmentX, y: segmentY), sliceSize: slice.magnitude, sliceSizeTotal: sumOfSlices)
                }
            }
            
            // This hollows out the center of the pie if the chart is a donut chart (or if sliceGap > 0).
            if absoluteRingInnerRadii[dataSet]! != 0 {
                CGContextSaveGState(context)
                CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
                CGContextAddEllipseInRect(context, CGRect(
                    x: pieCenter.x - absoluteRingInnerRadii[dataSet]!,
                    y: pieCenter.y - absoluteRingInnerRadii[dataSet]!,
                    width: absoluteRingInnerRadii[dataSet]! * 2,
                    height: absoluteRingInnerRadii[dataSet]! * 2
                    ))
                CGContextFillPath(context)
                CGContextRestoreGState(context)
            }
            
            CGContextEndTransparencyLayer(context)
            CGContextRestoreGState(context)
        }
    }
    
    private func addSegmentLabel(location: CGPoint, sliceSize: CGFloat, sliceSizeTotal: CGFloat) {
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        
        var fontSizeAbsolute: CGFloat = 0
        var textRectLengthAbsolute: CGFloat = 0
        
        if labelSizeScale == "horizontal" {
            fontSizeAbsolute = self.bounds.width * labelFontSize * 0.01
            textRectLengthAbsolute = self.bounds.width * labelBoxWidth * 0.01
        }
        if labelSizeScale == "vertical" {
            fontSizeAbsolute = self.bounds.height * labelFontSize * 0.01
            textRectLengthAbsolute = self.bounds.height * labelBoxWidth * 0.01
        }
        
        let textRect: CGRect = CGRect(
            x: location.x - textRectLengthAbsolute * 0.5,
            y: location.y - fontSizeAbsolute * 0.5,
            width: textRectLengthAbsolute,
            height: fontSizeAbsolute
        )
        
        var text: String
        
        if labelInPercent {
            text = String(format: "%.\(labelPrecision)f", sliceSize / sliceSizeTotal * 100) + "%"
        } else {
            text = String(format: "%.\(labelPrecision)f", sliceSize) + labelUnit
        }
        
        let font: UIFont = UIFont(name: "Helvetica Neue", size: fontSizeAbsolute)!
        var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Center
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: labelFontColor,
            NSParagraphStyleAttributeName: textStyle]
        
        (text as NSString).drawInRect(textRect, withAttributes: textAttributes)
    }
    
    private func rotatePoint(point: CGPoint, angle: CGFloat, aroundPoint: CGPoint) -> CGPoint {
        let sinTheta: CGFloat = sin(angle)
        let cosTheta: CGFloat = cos(angle)
        
        return CGPoint(
            x: cosTheta * (point.x - aroundPoint.x) - sinTheta * (point.y - aroundPoint.y) + aroundPoint.x,
            y: sinTheta * (point.x - aroundPoint.x) + cosTheta * (point.y - aroundPoint.y) + aroundPoint.y
        )
    }
    
    private func determineKeyScaling() {
        if xOfKeyScale == "horizontal" {
            keyCoords.x = self.bounds.width * keyX * 0.01
        }
        if xOfKeyScale == "vertical" {
            keyCoords.x = self.bounds.height * keyX * 0.01
        }
        if yOfKeyScale == "horizontal" {
            keyCoords.y = self.bounds.width * keyY * 0.01
        }
        if yOfKeyScale == "vertical" {
            keyCoords.y = self.bounds.height * keyY * 0.01
        }
        if keySizeScale == "horizontal" {
            keySizeUnit = self.bounds.width * 0.01
        }
        if keySizeScale == "vertical" {
            keySizeUnit = self.bounds.height * 0.01
        }
    }
    
    private func drawKey() {
        let swatchSizeAbsolute: CGFloat = keySizeUnit * swatchSize
        let swatchGapAbsolute: CGFloat = keySizeUnit * swatchGap
        let swatchFontMarginAbsolute: CGFloat = keySizeUnit * swatchFontMargin
        let swatchFontSizeAbsolute: CGFloat = keySizeUnit * swatchFontSize
        let totalHeight: CGFloat = swatchSizeAbsolute * CGFloat(colors.count) + swatchGapAbsolute * CGFloat(colors.count - 1)
        let startY: CGFloat = keyCoords.y - totalHeight * 0.5
        
        var i: Int = 0
        for (name, color) in colors {
            let context = UIGraphicsGetCurrentContext()
            let rectangle = CGRect(
                x: keyCoords.x,
                y: startY + CGFloat(i) * (swatchSizeAbsolute + swatchGapAbsolute),
                width: swatchSizeAbsolute,
                height: swatchSizeAbsolute
            )
            CGContextAddRect(context, rectangle)
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, rectangle)
            
            let text: NSString = (name as NSString)
            let textRect: CGRect = CGRect(
                x: keyCoords.x + swatchSizeAbsolute + swatchFontMarginAbsolute,
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
            
            i += 1
        }
    }
    
    private func drawGuide() {
        var guideLengthAbsolute: CGFloat = 0
        if guideLengthScale == "horizontal" {
            guideLengthAbsolute = guideLength * 0.01 * self.bounds.width
        }
        if guideLengthScale == "vertical" {
            guideLengthAbsolute = guideLength * 0.01 * self.bounds.height
        }
        if guideLength == 0 {
            println("aaa")
            guideLengthAbsolute = self.bounds.width - pieCenter.x
            println(guideLengthAbsolute)
        }
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        
        for i: Int in 0..<data.count {
            let guideHeightAbsolute: CGFloat = absoluteRingOuterRadii[data[i]]! - absoluteRingInnerRadii[data[i]]!
            let guideRect: CGRect = CGRect(
                x: pieCenter.x,
                y: pieCenter.y - absoluteRingOuterRadii[data[i]]!,
                width: guideLengthAbsolute,
                height: guideHeightAbsolute
            )
            
            CGContextSaveGState(context)
            
            CGContextClipToRect(context, guideRect)
            let locations: [CGFloat] = [0, 1]
            let gradientColors: [CGColor] = [guideStartColor.CGColor, guideEndColor.CGColor]
            let colorspace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
            let gradient: CGGradientRef = CGGradientCreateWithColors(colorspace, gradientColors, locations)
            let startPoint: CGPoint = CGPoint(x: pieCenter.x, y: 0)
            let endPoint: CGPoint = CGPoint(x: pieCenter.x + guideLengthAbsolute, y: 0)
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
            
            CGContextRestoreGState(context)
            
            // This writes the text.
            var guideTextXAbsolute: CGFloat = 0
            if xOfGuideScale == "horizontal" {
                guideTextXAbsolute = guideTextX * 0.01 * self.bounds.width
            }
            if xOfGuideScale == "vertical" {
                guideTextXAbsolute = guideTextX * 0.01 * self.bounds.height
            }
            
            var guideFontSizeAbsolute: CGFloat = 0
            if guideFontSizeScale == "horizontal" {
                guideFontSizeAbsolute = guideFontSize * 0.01 * self.bounds.width
            }
            if guideFontSizeScale == "vertical" {
                guideFontSizeAbsolute = guideFontSize * 0.01 * self.bounds.height
            }
            let guideTextYAbsolute: CGFloat = pieCenter.y - absoluteRingOuterRadii[data[i]]! + (guideHeightAbsolute - guideFontSizeAbsolute) * 0.4
            
            let textRect: CGRect = CGRect(
                x: guideTextXAbsolute,
                y: guideTextYAbsolute,
                width: guideLengthAbsolute,
                height: guideFontSizeAbsolute * 1.25 // It's best to add a bit, since letters like lowercase g are cut off otherwise.
            )
            let font: UIFont = UIFont(name: "Helvetica Neue", size: guideFontSizeAbsolute)!
            var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            let textAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: guideFontColor,
                NSParagraphStyleAttributeName: textStyle]
            (data[i].name as NSString).drawInRect(textRect, withAttributes: textAttributes)
        }
    }
}