import UIKit

class LineGraphDataSet: NSObject {
    // This array stores data points.
    internal var points: [CGPoint] = []
    internal var lineColor: UIColor? = nil
    internal var markerColor: UIColor? = nil
    internal var markerStyle: Int? = nil
    
    // These variables are calculated by GraphView to help with graphing.
    internal var extreme: CGPoint = CGPoint()
    internal var oppositeExtreme: CGPoint = CGPoint()
    internal var window: CGRect = CGRect()
    internal var gridSpacing: CGPoint = CGPoint()
    
    init(points: [CGPoint] = []) {
        self.points = points
    }
}