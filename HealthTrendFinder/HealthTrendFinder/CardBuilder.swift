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
        return [makeBasicCard(viewBounds)]
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
    
    static private func makePieGraphCard(viewBounds: CGRect) -> CardView {
        // This creates an empty CardView.
        let newCard: CardView = CardView(frame: CGRect(), headerText: "ayy")
        
        // This creates the PieGraphView.
        var pieGraphView: PieGraphView = PieGraphView()
        
        // Here, the PieGraphView's paramaters are set.
        pieGraphView.labelUnit = "g"
        pieGraphView.labelFontSize = 3.5
        pieGraphView.guideY = 35
        pieGraphView.keyY = 65
        pieGraphView.colors = [
            "Fats" : UIColor(red: 44 / 255, green: 76 / 255, blue: 123 / 255, alpha: 1),
            "Sugars" : UIColor(red: 124 / 255, green: 41 / 255, blue: 43 / 255, alpha: 1),
            "Carbohydrates" : UIColor(red: 98 / 255, green: 123 / 255, blue: 50 / 255, alpha: 1)
        ]
        
        // Here, data sets for the PieGraphView are created.
        var weekdayDataSet: PieGraphDataSet = PieGraphDataSet()
        weekdayDataSet.name = "Weekday Average"
        weekdayDataSet.slices = [
            PieGraphSlice(magnitude: 31.2, name: "Fats"),
            PieGraphSlice(magnitude: 78.3, name: "Carbohydrates"),
            PieGraphSlice(magnitude: 23.5, name: "Sugars")
        ]
        
        var weekendDataSet: PieGraphDataSet = PieGraphDataSet()
        weekendDataSet.name = "Weekend Average"
        weekendDataSet.slices = [
            PieGraphSlice(magnitude: 54.2, name: "Fats"),
            PieGraphSlice(magnitude: 65.6, name: "Carbohydrates"),
            PieGraphSlice(magnitude: 31.7, name: "Sugars")
        ]
        
        pieGraphView.data = [
            weekdayDataSet,
            weekendDataSet
        ]
        
        // Here, the PieGraphView's frame is adjusted to fit the card.
        pieGraphView.frame = CGRect(
            x: outerMargin,
            y: outerMargin,
            width: viewBounds.width - 2 * 8 - outerMargin * 2,
            height: (viewBounds.width - 2 * 8 - outerMargin * 2) * 3 / 5
        )
        
        // This creates the UITextView.
        var textView: UITextView = UITextView(frame: CGRect(
            x: outerMargin,
            y: outerMargin + innerMargin + pieGraphView.frame.height,
            width: viewBounds.width - 2 * outerMargin,
            height: 48
            ))
        textView.font = UIFont(name: "Helvetica Neue", size: 11)
        textView.text = "There's a correlation between WEEKDAY and NUTRITION. On weekdays, you eat more carbohydrates, while on weekends, you eat more sugars and fats."
        
        // Here, the dimensions of the new CardView are calculated.
        newCard.frame = CGRect(
            x: 8,
            y: 0,
            width: viewBounds.width - 2 * 8,
            height: outerMargin * 2 + innerMargin + pieGraphView.frame.height + textView.frame.height
        )
        
        // Here, the subviews are added to the CardView
        newCard.addSubview(pieGraphView)
        newCard.addSubview(textView)
        
        return newCard
    }
}