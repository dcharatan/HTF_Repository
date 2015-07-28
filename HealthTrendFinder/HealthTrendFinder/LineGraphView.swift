import UIKit

@IBDesignable

class LineGraphView: UIView {
    @IBInspectable var xStartIsZero: Bool = false // If this is true, the graphWindow's x will go from 0 to dataExtremeX (+ margin).
    @IBInspectable var yStartIsZero: Bool = false // If this is true, the graphWindow's y will go from 0 to dataExtremeY (+ margin).
    
    @IBInspectable var xExactWindow: Bool = false // If this is true, then the window won't go to the nearest x grid line.
    @IBInspectable var yExactWindow: Bool = false // If this is true, then the window won't go to the nearest y grid line.
    
    @IBInspectable var xIsReversed: Bool = false // If this is true, x is graphed from the highest value on the left to the lowest value on the right.
    @IBInspectable var yIsReversed: Bool = false // If this is true, y is graphed from the highest value on the bottom to the lowest value on the top.
    
    @IBInspectable var xMarginPrcnt: CGFloat = 25 // This is the minimum percent margin of the x axis.
    @IBInspectable var yMarginPrcnt: CGFloat = 25 // This is the minimum percent margin of the y axis.
    
    @IBInspectable var bgColor: UIColor = UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1.0)
    @IBInspectable var bgStrokeColor: UIColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
    @IBInspectable var bgStrokeWidth: CGFloat = 1
    
    @IBInspectable var xPositionScale: String = "horizontal"
    @IBInspectable var yPositionScale: String = "vertical"
    
    @IBInspectable var xSizeScale: String = "horizontal"
    @IBInspectable var ySizeScale: String = "vertical"
    
    @IBInspectable var xGraphSize: CGFloat = 60
    @IBInspectable var yGraphSize: CGFloat = 60
    
    @IBInspectable var graphAreaX: CGFloat = 45
    @IBInspectable var graphAreaY: CGFloat = 50
    
    @IBInspectable var graphAreaColor: UIColor = UIColor.clearColor()
    
    @IBInspectable var axisLineColor: UIColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1.0)
    @IBInspectable var axisLineWidth: CGFloat = 2
    
    @IBInspectable var dataLineWidth: CGFloat = 2
    @IBInspectable var dataLineColor: UIColor = UIColor.lightGrayColor()
    
    @IBInspectable var dataMarkerStyle: Int = 1
    @IBInspectable var dataMarkerColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var dataMarkerSize: CGFloat = 6
    
    @IBInspectable var hGridLineWidth: CGFloat = 1
    @IBInspectable var vGridLineWidth: CGFloat = 1
    
    @IBInspectable var hGridLineColor: UIColor = UIColor(red: 232 / 255, green: 232 / 255, blue: 232 / 255, alpha: 1.0)
    @IBInspectable var vGridLineColor: UIColor = UIColor(red: 232 / 255, green: 232 / 255, blue: 232 / 255, alpha: 1.0)
    
    @IBInspectable var xGridUnit: String = ""
    @IBInspectable var yGridUnit: String = ""
    
    @IBInspectable var xLabelSize: CGFloat = 4
    @IBInspectable var yLabelSize: CGFloat = 4
    
    @IBInspectable var xLabelColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var yLabelColor: UIColor = UIColor.lightGrayColor()
    
    @IBInspectable var xLabelMargin: CGFloat = 5
    @IBInspectable var yLabelMargin: CGFloat = 5
    
    @IBInspectable var xLabelMarginScale: String = "vertical"
    @IBInspectable var yLabelMarginScale: String = "vertical"
    
    @IBInspectable var xOneCoordSys: Bool = true
    @IBInspectable var yOneCoordSys: Bool = true
    
    @IBInspectable var emptyWindowSize: CGFloat = 2
    
    @IBInspectable var verticalGraph: Bool = false
    
    @IBInspectable var xOfKeyScale: String = "horizontal"
    @IBInspectable var yOfKeyScale: String = "vertical"
    @IBInspectable var keySizeScale: String = "vertical"
    
    @IBInspectable var keyX: CGFloat = 77.5
    @IBInspectable var keyY: CGFloat = 50
    
    @IBInspectable var swatchSize: CGFloat = 5
    @IBInspectable var swatchGap: CGFloat = 5
    
    @IBInspectable var fontSize: CGFloat = 5
    @IBInspectable var fontMargin: CGFloat = 2.5
    @IBInspectable var fontColor: UIColor = UIColor.darkGrayColor()
    
    // Since @IBInspectable doesn't support arrays, you have to configure this here.
    // The format here is (a, b). This stuff configures the cutoffs for grid spacing.
    // If abs(x)*10^n < a*10^n, b*10^n is the grid spacing, where x*10^n is the extreme in the graph
    private let xThresholds: [(CGFloat, CGFloat)] = [
        (1.0, 0.25),
        (2.5, 0.5),
        (5.0, 1.0),
        (10.0, 2.0)
    ]
    private let yThresholds: [(CGFloat, CGFloat)] = [
        (1.0, 0.25),
        (2.5, 0.5),
        (5.0, 1.0),
        (10.0, 2.0)
    ]
    
    internal var data: [LineGraphDataSet] = [LineGraphDataSet()] // This is where data is stored.
    
    private var graphingArea: CGRect = CGRect() // This keeps track of the area in which the graph is drawn.
    
    // These variables are used to keep track of things related to the key.
    private var keySizeUnit: CGFloat = 0
    private var keyCoords: CGPoint = CGPoint()
    
    // These variables are used when (parts of) data points are graphed in the same coordinate system.
    private var mutualExtreme: CGPoint = CGPoint()
    private var mutualOppositeExtreme: CGPoint = CGPoint()
    
    override func drawRect(rect: CGRect) {
        sortData()
        determineExtremes()
        if xOneCoordSys || yOneCoordSys {
            determineMutualExtremes()
        }
        determineGridLineSpacing()
        determineGraphingWindow()
        drawBackground()
        determineGraphingAreaDimensions()
        drawGraphingAreaBackground()
        drawGridLines()
        drawAxisLines()
        drawDataLines()
        drawDataMarkers()
        determineKeyScaling()
        drawKey()
    }
    
    private func sortData() {
        if verticalGraph {
            for dataSet: LineGraphDataSet in data {
                dataSet.points.sort({$0.y < $1.y})
            }
        } else {
            for dataSet: LineGraphDataSet in data {
                dataSet.points.sort({$0.x < $1.x})
            }
        }
    }
    
    // This function is pretty simple. It finds the x and y values in each data set that are furthest from zero, and then finds the x and y values that are furthest from those.
    private func determineExtremes() {
        for dataSet: LineGraphDataSet in data {
            dataSet.extreme.x = 0
            dataSet.extreme.y = 0
            
            for point: CGPoint in dataSet.points {
                if abs(point.x) > abs(dataSet.extreme.x) {
                    dataSet.extreme.x = point.x
                }
                if abs(point.y) > abs(dataSet.extreme.y) {
                    dataSet.extreme.y = point.y
                }
            }
            
            dataSet.oppositeExtreme = dataSet.extreme
            
            for point: CGPoint in dataSet.points {
                if abs(point.x - dataSet.extreme.x) > abs(dataSet.oppositeExtreme.x - dataSet.extreme.x) {
                    dataSet.oppositeExtreme.x = point.x
                }
                if abs(point.y - dataSet.extreme.y) > abs(dataSet.oppositeExtreme.y - dataSet.extreme.y) {
                    dataSet.oppositeExtreme.y = point.y
                }
            }
        }
    }
    
    // This function merges the extremes to allow all data sets to be graphed on one coordinate system. To do so, it first finds the most extreme of the extremes, and then determines which extreme/ oppositeExtreme is furthest from that (the furthest away extreme/ oppositeExtreme becomes the overall oppositeExtreme.
    private func determineMutualExtremes() {
        mutualExtreme.x = 0
        mutualExtreme.y = 0
        
        for dataSet: LineGraphDataSet in data {
            if dataSet.points.count > 0 {
                if abs(dataSet.extreme.x) > abs(mutualExtreme.x) {
                    mutualExtreme.x = dataSet.extreme.x
                }
                if abs(dataSet.extreme.y) > abs(mutualExtreme.y) {
                    mutualExtreme.y = dataSet.extreme.y
                }
            }
        }
        
        mutualOppositeExtreme = mutualExtreme
        
        for dataSet: LineGraphDataSet in data {
            if dataSet.points.count > 0 {
                if abs(dataSet.extreme.x - mutualExtreme.x) > abs(mutualOppositeExtreme.x - mutualExtreme.x) {
                    mutualOppositeExtreme.x = dataSet.extreme.x
                }
                if abs(dataSet.extreme.y - mutualExtreme.y) > abs(mutualOppositeExtreme.y - mutualExtreme.y) {
                    mutualOppositeExtreme.y = dataSet.extreme.y
                }
            }
        }
        for dataSet: LineGraphDataSet in data {
            if dataSet.points.count > 0 {
                if abs(dataSet.oppositeExtreme.x - mutualExtreme.x) > abs(mutualOppositeExtreme.x - mutualExtreme.x) {
                    mutualOppositeExtreme.x = dataSet.oppositeExtreme.x
                }
                if abs(dataSet.oppositeExtreme.y - mutualExtreme.y) > abs(mutualOppositeExtreme.y - mutualExtreme.y) {
                    mutualOppositeExtreme.y = dataSet.oppositeExtreme.y
                }
            }
        }
    }
    
    private func determineGridLineSpacing() {
        // This subfunction calculates the grid line spacing for a specific axis given that axis' extreme, oppositeExtreme and axisThresholds.
        func determineForChunk(axisExtreme: CGFloat, axisOppositeExtreme: CGFloat, axisThresholds: [(CGFloat, CGFloat)], axisStartIsZero: Bool) -> CGFloat {
            var returnValue: CGFloat = 0
            var axisDistance: CGFloat = 0
            
            if axisStartIsZero {
                if axisExtreme != 0 {
                    axisDistance = distance(axisExtreme, b: 0)
                } else {
                    axisDistance = emptyWindowSize
                }
            } else if axisExtreme == axisOppositeExtreme {
                axisDistance = emptyWindowSize
            } else {
                axisDistance = distance(axisExtreme, b: axisOppositeExtreme)
            }
            
            let axisExtremeBaseTenFloor: CGFloat = floor(log10(axisDistance))
            let axisSpacingUnit: CGFloat = pow(10, axisExtremeBaseTenFloor)
            
            for var i: Int = axisThresholds.count - 1; i >= 0; --i {
                if abs(axisDistance) <= axisSpacingUnit * axisThresholds[i].0 {
                    returnValue = axisSpacingUnit * axisThresholds[i].1
                }
            }
            
            return returnValue
        }
        
        // This calculates x grid spacing for all dataSet objects.
        if xOneCoordSys {
            // If there is one x coordinate system, the x grid spacing is calculated once using the data's mutual extreme/ oppositeExtreme and assigned to all data sets.
            let xGridSpacing: CGFloat = determineForChunk(mutualExtreme.x, mutualOppositeExtreme.x, xThresholds, xStartIsZero)
            
            for dataSet: LineGraphDataSet in data {
                dataSet.gridSpacing.x = xGridSpacing
            }
        } else {
            // If each data set has its own x coordinate system, x grid spacing is calculated separately.
            for dataSet: LineGraphDataSet in data {
                dataSet.gridSpacing.x = determineForChunk(dataSet.extreme.x, dataSet.oppositeExtreme.x, xThresholds, xStartIsZero)
            }
        }
        
        // This calculates y grid spacing for all dataSet objects.
        if yOneCoordSys {
            // If there is one y coordinate system, the y grid spacing is calculated once using the data's mutual extreme/ oppositeExtreme and assigned to all data sets.
            let yGridSpacing: CGFloat = determineForChunk(mutualExtreme.y, mutualOppositeExtreme.y, yThresholds, yStartIsZero)
            for dataSet: LineGraphDataSet in data {
                dataSet.gridSpacing.y = yGridSpacing
            }
        } else {
            // If each data set has its own y coordinate system, y grid spacing is calculated separately.
            for dataSet: LineGraphDataSet in data {
                dataSet.gridSpacing.y = determineForChunk(dataSet.extreme.y, dataSet.oppositeExtreme.y, yThresholds, yStartIsZero)
            }
        }
    }
    
    private func determineGraphingWindow() {
        func determineForChunk(axisExtreme: CGFloat, axisOppositeExtreme: CGFloat, axisGridSpacing: CGFloat, axisStartIsZero: Bool, axisExactWindow: Bool, axisMarginPercent: CGFloat) -> (startValue: CGFloat, length: CGFloat) {
            var a: CGFloat = 0
            var b: CGFloat = 0
            var axisMarginAbsolute: CGFloat = 0
            var returnValue: (startValue: CGFloat, length: CGFloat) = (0, 0)
            
            if axisExtreme == 0 {
                if axisStartIsZero {
                    a = 0
                    b = emptyWindowSize
                } else {
                    a = emptyWindowSize * -0.5
                    b = emptyWindowSize * +0.5
                }
            } else {
                if axisExactWindow {
                    if axisStartIsZero {
                        axisMarginAbsolute = abs(axisExtreme) * axisMarginPercent * 0.01
                        a = 0
                        if axisExtreme == 0 {
                            b = emptyWindowSize
                        } else {
                            b = increaseMagnitude(axisExtreme, increaseBy: axisMarginAbsolute)
                        }
                    } else {
                        if axisExtreme == axisOppositeExtreme {
                            a = axisExtreme - emptyWindowSize * 0.5
                            b = axisExtreme + emptyWindowSize * 0.5
                        } else {
                            axisMarginAbsolute = distance(axisExtreme, b: axisOppositeExtreme) * axisMarginPercent * 0.01
                            if axisExtreme > 0 {
                                a = axisExtreme + axisMarginAbsolute
                                b = axisOppositeExtreme - axisMarginAbsolute
                            } else if axisExtreme < 0 {
                                a = axisExtreme - axisMarginAbsolute
                                b = axisOppositeExtreme + axisMarginAbsolute
                            }
                        }
                    }
                } else {
                    if axisStartIsZero {
                        axisMarginAbsolute = abs(axisExtreme) * axisMarginPercent * 0.01
                        a = 0
                        if axisExtreme == 0 {
                            b = emptyWindowSize
                        } else {
                            while abs(b) < abs(increaseMagnitude(axisExtreme, increaseBy: axisMarginAbsolute)) {
                                if axisExtreme > 0 {
                                    b += axisGridSpacing
                                } else {
                                    b -= axisGridSpacing
                                }
                            }
                        }
                    } else {
                        var conditionA: Void -> Bool
                        var conditionB: Void -> Bool
                        var multiplier: CGFloat
                        
                        if axisExtreme == axisOppositeExtreme {
                            axisMarginAbsolute = emptyWindowSize * 0.5
                        } else {
                            axisMarginAbsolute = distance(axisExtreme, b: axisOppositeExtreme) * axisMarginPercent * 0.01
                        }
                        
                        if axisExtreme >= 0 {
                            conditionA = {return a < axisExtreme + axisMarginAbsolute}
                            conditionB = {return b > axisOppositeExtreme - axisMarginAbsolute}
                            multiplier = 1
                        } else {
                            conditionA = {return a > axisExtreme - axisMarginAbsolute}
                            conditionB = {return b < axisOppositeExtreme + axisMarginAbsolute}
                            multiplier = -1
                        }
                        
                        a = 0
                        
                        while conditionA() {
                            a += axisGridSpacing * multiplier
                        }
                        
                        b = a
                        
                        while conditionB() {
                            b -= axisGridSpacing * multiplier
                        }
                    }
                }
            }
            
            if a < b {
                returnValue.startValue = a
                returnValue.length = distance(a, b: b)
            } else if a > b {
                returnValue.startValue = b
                returnValue.length = distance(a, b: b)
            } else {
                returnValue.startValue = a - emptyWindowSize * 0.5
                returnValue.length = emptyWindowSize
            }
            
            return returnValue
        }
        
        if xOneCoordSys {
            let mutualX: (startValue: CGFloat, length: CGFloat) = determineForChunk(mutualExtreme.x, mutualOppositeExtreme.x, data[0].gridSpacing.x, xStartIsZero, xExactWindow, xMarginPrcnt)
            if yOneCoordSys {
                let mutualY: (startValue: CGFloat, length: CGFloat) = determineForChunk(mutualExtreme.y, mutualOppositeExtreme.y, data[0].gridSpacing.y, yStartIsZero, yExactWindow, yMarginPrcnt)
                for dataSet: LineGraphDataSet in data {
                    dataSet.window = CGRect(x: mutualX.startValue, y: mutualY.startValue, width: mutualX.length, height: mutualY.length)
                }
            } else {
                for dataSet: LineGraphDataSet in data {
                    let individualY: (startValue: CGFloat, length: CGFloat) = determineForChunk(dataSet.extreme.y, dataSet.oppositeExtreme.y, dataSet.gridSpacing.y, yStartIsZero, yExactWindow, yMarginPrcnt)
                    dataSet.window = CGRect(x: mutualX.startValue, y: individualY.startValue, width: mutualX.length, height: individualY.length)
                }
            }
        } else {
            if yOneCoordSys {
                let mutualY: (startValue: CGFloat, length: CGFloat) = determineForChunk(mutualExtreme.y, mutualOppositeExtreme.y, data[0].gridSpacing.y, yStartIsZero, yExactWindow, yMarginPrcnt)
                for dataSet: LineGraphDataSet in data {
                    let individualX: (startValue: CGFloat, length: CGFloat) = determineForChunk(dataSet.extreme.x, dataSet.oppositeExtreme.x, dataSet.gridSpacing.x, xStartIsZero, xExactWindow, xMarginPrcnt)
                    dataSet.window = CGRect(x: individualX.startValue, y: mutualY.startValue, width: individualX.length, height: mutualY.length)
                }
            } else {
                for dataSet: LineGraphDataSet in data {
                    let individualX: (startValue: CGFloat, length: CGFloat) = determineForChunk(dataSet.extreme.x, dataSet.oppositeExtreme.x, dataSet.gridSpacing.x, xStartIsZero, xExactWindow, xMarginPrcnt)
                    let individualY: (startValue: CGFloat, length: CGFloat) = determineForChunk(dataSet.extreme.y, dataSet.oppositeExtreme.y, dataSet.gridSpacing.y, yStartIsZero, yExactWindow, yMarginPrcnt)
                    dataSet.window = CGRect(x: individualX.startValue, y: individualY.startValue, width: individualX.length, height: individualY.length)
                }
            }
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
    
    private func determineGraphingAreaDimensions() {
        var rWidth: CGFloat = 0
        var rHeight: CGFloat = 0
        var rX: CGFloat = 0
        var rY: CGFloat = 0
        
        if xSizeScale == "horizontal" {
            rWidth = self.bounds.width * xGraphSize / 100
        }
        if xSizeScale == "vertical" {
            rWidth = self.bounds.height * xGraphSize / 100
        }
        if ySizeScale == "horizontal" {
            rHeight = self.bounds.width * yGraphSize / 100
        }
        if ySizeScale == "vertical" {
            rHeight = self.bounds.height * yGraphSize / 100
        }
        if xPositionScale == "horizontal" {
            rX = self.bounds.width * graphAreaX / 100 - rWidth * 0.5
        }
        if xPositionScale == "vertical" {
            rX = self.bounds.height * graphAreaX / 100 - rWidth * 0.5
        }
        if yPositionScale == "horizontal" {
            rY = self.bounds.width * graphAreaY / 100 - rHeight * 0.5
        }
        if yPositionScale == "vertical" {
            rY = self.bounds.height * graphAreaY / 100 - rHeight * 0.5
        }
        
        graphingArea = CGRect(x: rX, y: rY, width: rWidth, height: rHeight)
    }
    
    private func drawGraphingAreaBackground() {
        let context = UIGraphicsGetCurrentContext()
        CGContextAddRect(context, graphingArea)
        CGContextSetFillColorWithColor(context, graphAreaColor.CGColor)
        CGContextFillRect(context, graphingArea)
    }
    
    private func drawGridLines() {
        if data.count == 1 || yOneCoordSys {
            for var i: CGFloat = 0; i <= data[0].window.maxY; i += data[0].gridSpacing.y {
                if i >= data[0].window.minY {
                    horizontalGridLine(i)
                }
            }
            for var i: CGFloat = 0; i >= data[0].window.minY; i -= data[0].gridSpacing.y {
                if i <= data[0].window.maxY {
                    horizontalGridLine(i)
                }
            }
        }
        
        if data.count == 1 || xOneCoordSys {
            for var i: CGFloat = 0; i <= data[0].window.maxX; i += data[0].gridSpacing.x {
                if i >= data[0].window.minX {
                    verticalGridLine(i)
                }
            }
            for var i: CGFloat = 0; i >= data[0].window.minX; i -= data[0].gridSpacing.x {
                if i <= data[0].window.maxX {
                    verticalGridLine(i)
                }
            }
        }
    }
    
    private func horizontalGridLine(y: CGFloat) {
        // This part draws the actual line.
        let context = UIGraphicsGetCurrentContext()
        if y != 0 {
            CGContextSetLineWidth(context, hGridLineWidth)
            CGContextSetStrokeColorWithColor(context, hGridLineColor.CGColor)
            CGContextMoveToPoint(context, graphingArea.minX, translateY(y, windowRef: data[0].window))
            CGContextAddLineToPoint(context, graphingArea.maxX, translateY(y, windowRef: data[0].window))
            CGContextStrokePath(context)
        }
        
        // This part draws the label to the left of the line.
        var prelimText: String = ""
        
        // This converts the numbers to scientific notation if the spacing is 10,000+
        if data[0].gridSpacing.y < 10000 {
            prelimText = String(format: "%.\(getPrecision(data[0].gridSpacing.y))f", y)
        } else {
            var formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.ScientificStyle
            prelimText = formatter.stringFromNumber(y)!
        }
        
        var yLabelMarginAbsolute: CGFloat = 0
        if yLabelMarginScale == "horizontal" {
            yLabelMarginAbsolute = yLabelMargin / 100 * self.bounds.width
        }
        if yLabelMarginScale == "vertical" {
            yLabelMarginAbsolute = yLabelMargin / 100 * self.bounds.height
        }
        
        let text: NSString = ("\(prelimText)" + "\(yGridUnit)" as NSString)
        let textRect: CGRect = CGRectMake(0,
            translateY(y, windowRef: data[0].window) - yLabelSize / 100 * self.bounds.height * 0.5,
            graphingArea.minX - yLabelMarginAbsolute,
            yLabelSize / 100 * self.bounds.height)
        let font: UIFont = UIFont(name: "Helvetica Neue", size: yLabelSize / 100 * self.bounds.height)!
        var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Right
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: yLabelColor,
            NSParagraphStyleAttributeName: textStyle]
        text.drawInRect(textRect, withAttributes: textAttributes)
    }
    
    private func verticalGridLine(x: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        if x != 0 {
            CGContextSetLineWidth(context, vGridLineWidth)
            CGContextSetStrokeColorWithColor(context, vGridLineColor.CGColor)
            CGContextMoveToPoint(context, translateX(x, windowRef: data[0].window), graphingArea.minY)
            CGContextAddLineToPoint(context, translateX(x, windowRef: data[0].window), graphingArea.maxY)
            CGContextStrokePath(context)
        }
        
        // This part draws the label to the left of the line.
        var prelimText: String = ""
        
        // This converts the numbers to scientific notation if the spacing is 10,000+
        if data[0].gridSpacing.x < 10000 {
            prelimText = String(format: "%.\(getPrecision(data[0].gridSpacing.x))f", x)
        } else {
            var formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.ScientificStyle
            prelimText = formatter.stringFromNumber(x)!
        }
        
        let text: NSString = ("\(prelimText)" + "\(xGridUnit)" as NSString)
        
        var xLabelMarginAbsolute: CGFloat = 0
        if xLabelMarginScale == "horizontal" {
            xLabelMarginAbsolute = xLabelMargin / 100 * self.bounds.width
        }
        if xLabelMarginScale == "vertical" {
            xLabelMarginAbsolute = xLabelMargin / 100 * self.bounds.height
        }
        
        let xLabelSizeAbsolute = xLabelSize / 100 * self.bounds.height
        let textRect: CGRect = CGRectMake(translateX(x, windowRef: data[0].window) - xLabelSizeAbsolute * 0.5,
            self.bounds.height,
            self.bounds.height - graphingArea.maxY - xLabelMarginAbsolute,
            xLabelSizeAbsolute)
        let font: UIFont = UIFont(name: "Helvetica Neue", size: xLabelSize / 100 * self.bounds.height)!
        var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.Right
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: xLabelColor,
            NSParagraphStyleAttributeName: textStyle]
        
        CGContextSaveGState(context)
        let transform: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(270 * M_PI / 180))
        CGContextTranslateCTM(context, textRect.minX, textRect.minY)
        CGContextConcatCTM(context, transform)
        CGContextTranslateCTM(context, -textRect.minX, -textRect.minY)
        text.drawInRect(textRect, withAttributes: textAttributes)
        CGContextRestoreGState(context)
    }
    
    private func drawAxisLines() {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, axisLineWidth)
        CGContextSetStrokeColorWithColor(context, axisLineColor.CGColor)
        
        // x-axis line
        if data.count == 1 || yOneCoordSys {
            let lineY:CGFloat = translateY(0, windowRef: data[0].window)
            if !(lineY < graphingArea.minY || lineY > graphingArea.maxY) {
                CGContextMoveToPoint(context, graphingArea.minX, lineY)
                CGContextAddLineToPoint(context, graphingArea.maxX, lineY)
                CGContextStrokePath(context)
            }
        }
        
        // y-axis line
        if data.count == 1 || xOneCoordSys {
            let lineX:CGFloat = translateX(0, windowRef: data[0].window)
            if !(lineX < graphingArea.minX || lineX > graphingArea.maxX) {
                CGContextMoveToPoint(context, lineX, graphingArea.minY)
                CGContextAddLineToPoint(context, lineX, graphingArea.maxY)
                CGContextStrokePath(context)
            }
        }
    }
    
    private func drawDataLines() {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, dataLineWidth)
        
        for dataSet: LineGraphDataSet in data {
            if dataSet.lineColor == nil {
                CGContextSetStrokeColorWithColor(context, dataLineColor.CGColor)
            } else {
                CGContextSetStrokeColorWithColor(context, dataSet.lineColor!.CGColor)
            }
            
            for j in 0..<dataSet.points.count {
                var pointX: CGFloat = translateX(dataSet.points[j].x, windowRef: dataSet.window)
                var pointY: CGFloat = translateY(dataSet.points[j].y, windowRef: dataSet.window)
                
                if j == 0 {
                    CGContextMoveToPoint(context, pointX, pointY)
                } else {
                    CGContextAddLineToPoint(context, pointX, pointY)
                }
            }
            if dataSet.points.count > 1 {
                CGContextStrokePath(context)
            }
        }
    }
    
    private func drawDataMarkers() {
        for dataSet in data {
            var color: CGColor
            if dataSet.lineColor == nil {
                color = dataMarkerColor.CGColor
            } else {
                color = dataSet.markerColor!.CGColor
            }
            var style: Int
            if dataSet.markerStyle == nil {
                style = dataMarkerStyle
            } else {
                style = dataSet.markerStyle!
            }
            
            for j in 0..<dataSet.points.count {
                var pointX: CGFloat = translateX(dataSet.points[j].x, windowRef: dataSet.window)
                var pointY: CGFloat = translateY(dataSet.points[j].y, windowRef: dataSet.window)
                drawMarker(pointX, y: pointY, color: color, style: style)
            }
        }
    }
    
    private func drawMarker(x: CGFloat, y: CGFloat, color: CGColor, style: Int) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color)
        switch style {
        case 1, 2:
            let markerRectangle: CGRect = CGRect(x: x - dataMarkerSize * 0.5, y: y - dataMarkerSize * 0.5, width: dataMarkerSize, height: dataMarkerSize)
            if(style == 1) {
                CGContextAddEllipseInRect(context, markerRectangle)
                CGContextFillEllipseInRect(context, markerRectangle)
            } else {
                CGContextAddRect(context, markerRectangle)
                CGContextFillRect(context, markerRectangle)
            }
        case 3:
            CGContextMoveToPoint(context, x, y - dataMarkerSize * 0.7)
            CGContextAddLineToPoint(context, x + dataMarkerSize * 0.7, y)
            CGContextAddLineToPoint(context, x, y + dataMarkerSize * 0.7)
            CGContextAddLineToPoint(context, x - dataMarkerSize * 0.7, y)
            CGContextAddLineToPoint(context, x, y - dataMarkerSize * 0.7)
            CGContextFillPath(context)
        default:
            break; // None
        }
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
        let fontMarginAbsolute: CGFloat = keySizeUnit * fontMargin
        let fontSizeAbsolute: CGFloat = keySizeUnit * fontSize
        let totalHeight: CGFloat = swatchSizeAbsolute * CGFloat(data.count) + swatchGapAbsolute * CGFloat(data.count - 1)
        let startY: CGFloat = keyCoords.y - totalHeight * 0.5
        
        var i: Int = 0
        for dataSet: LineGraphDataSet in data {
            let context = UIGraphicsGetCurrentContext()
            let rectangle = CGRect(
                x: keyCoords.x,
                y: startY + CGFloat(i) * (swatchSizeAbsolute + swatchGapAbsolute),
                width: swatchSizeAbsolute,
                height: swatchSizeAbsolute
            )
            CGContextAddRect(context, rectangle)
            if dataSet.lineColor == nil {
                CGContextSetFillColorWithColor(context, dataLineColor.CGColor)
            } else {
                CGContextSetFillColorWithColor(context, dataSet.lineColor!.CGColor)
            }
            CGContextFillRect(context, rectangle)
            
            let text: NSString = (dataSet.name as NSString)
            let textRect: CGRect = CGRect(
                x: keyCoords.x + swatchSizeAbsolute + fontMarginAbsolute,
                y: startY + (CGFloat(i) + 0.5) * swatchSizeAbsolute + CGFloat(i) * swatchGapAbsolute - fontSizeAbsolute * 0.625,
                width: self.bounds.width - keyCoords.x - swatchGapAbsolute - fontMarginAbsolute,
                height: fontSizeAbsolute * 1.25
            )
            let font: UIFont = UIFont(name: "Helvetica Neue", size: fontSizeAbsolute)!
            var textStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            let textAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle]
            text.drawInRect(textRect, withAttributes: textAttributes)
            
            i += 1
        }
    }
    
    // This function translates x in the graphing window's coordinate system to x in the graphing area's coordinate system.
    private func translateX(x: CGFloat, windowRef: CGRect) -> CGFloat {
        if xIsReversed {
            return graphingArea.maxX - graphingArea.width * (x - windowRef.minX) / (windowRef.maxX - windowRef.minX)
        } else {
            return graphingArea.minX + graphingArea.width * (x - windowRef.minX) / (windowRef.maxX - windowRef.minX)
        }
    }
    
    // This function translates y in the graphing window's coordinate system to y in the graphing area's coordinate system.
    private func translateY(y: CGFloat, windowRef: CGRect) -> CGFloat {
        if yIsReversed {
            return graphingArea.minY + graphingArea.height * (y - windowRef.minY) / (windowRef.maxY - windowRef.minY)
        } else {
            return graphingArea.maxY - graphingArea.height * (y - windowRef.minY) / (windowRef.maxY - windowRef.minY)
        }
    }
    
    // This makes negative numbers more negative and positive numbers more positive. Zero remains zero regardless of the increaseBy value.
    private func increaseMagnitude(number: CGFloat, increaseBy: CGFloat) -> CGFloat {
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
    
    // This returns the distance between two numbers.
    private func distance(a: CGFloat, b: CGFloat) -> CGFloat {
        return abs(a - b)
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