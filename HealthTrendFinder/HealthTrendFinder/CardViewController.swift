//
//  CardViewController.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/29/15.
//
//

import UIKit
import Foundation

class CardViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let swipeOutAnimationDuration = 0.33 // The duration of the swiping away CardView animation
    let verticalAnimationDuration = 0.25 // The duration of the vertical CardView animation
    let verticalAnimationDelay = 0.05 // The delay between each CardView's animation after another CardView is deleted
    let deletionThreshold: CGFloat = 50.0 // The distance you have to drag to delete a CardView
    let margin: CGFloat = 8.0 // This is needed for a few calculations, so it's kept here.
    
    private var cardArray: [CardView] = []
    
    // This is a temporary button used to add cards.
    @IBAction func plusButtonPressed(sender: AnyObject) {
        addCard()
    }
    
    // This is the outlet for the UIScrollView the CardView instances are placed in.
    @IBOutlet weak var cardScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = [(0.0, 4.0),
            (2.0, 5.0),
            (3.0, 7.0),
            (4.0, 8.0),
            (7.0, 9.0)]
        println("data = \(data)")
        println("r = \(AnalysisTools.pcc(data))")
    }
    
    // This is used to allow the UIPanGestureRecognizers to work together with the UIScrollView's scrolling.
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func addCard() {
        let cardIndex = cardArray.count
        let width: CGFloat = self.view.bounds.width - 2 * margin
        let height: CGFloat = CGFloat(100 + Int(arc4random_uniform(200)))
        let newCard = CardView(frame: CGRectMake(margin,
            cardHeightsAndMarginsUpToButNotIncludingIndex(cardArray.count),
            width,
            height))
        
        // This is where each CardView's UIPanGestureRecognizer is created.
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "detectPan:")
        
        // This is used to allow the UIPanGestureRecognizer to work together with the UIScrollView's scrolling.
        panRecognizer.delegate = self
        
        // Each CardView has a UIPanGestureRecognizer attached to it.
        newCard.addGestureRecognizer(panRecognizer)
        
        // A reference to the UIPanGestureRecognizer is left with the card.
        newCard.panGestureRecognizerReference = panRecognizer
        
        // This adds the CardView to the screen.
        cardScrollView.addSubview(newCard)
        
        // This creates a reference to the CardView within the cardArray.
        cardArray.append(newCard)
        
        // This adjusts the UIScrollView to accomodate the new card.
        adjustCardScrollView(0.0)
    }
    
    func detectPan(recognizer: UIPanGestureRecognizer) {
        for i in 0..<cardArray.count {
            if(recognizer.view != nil && recognizer.view == cardArray[i]) {
                // This prepares the CardView for dragging.
                if recognizer.state == .Began {
                    cardArray[i].lastLocation = cardArray[i].center
                }
                
                // This moves the CardView when you drag.
                var translation = recognizer.translationInView(self.cardArray[i].superview!)
                cardArray[i].center = CGPointMake(cardArray[i].lastLocation.x + translation.x, cardArray[i].lastLocation.y)
                
                // This detects the end of drag gestures.
                if recognizer.state == .Ended {
                    if cardArray[i].center.x < cardArray[i].originalLocation.x - deletionThreshold {
                        // This removes the CardView if you've moved it far enough to the left.
                        removeCardAtIndex(i)
                    } else {
                        // This moves the CardView back to its original position if you haven't moved it far enough.
                        UIView.animateWithDuration(swipeOutAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.cardArray[i].center.x = self.cardArray[i].originalLocation.x
                            }, completion: nil)
                    }
                }
            }
        }
    }
    
    private func repositionRemainingCards(deletedCardIndex: Int) {
        // This variable is used to track the largest animation delay. It is later used to synchronize the animation of the last CardView with that of the UIScrollView.
        var largestDelayInterval: Double = 0.0
        
        // This loop iterates over all of the cards that come after the deleted CardView.
        for j in deletedCardIndex..<self.cardArray.count {
                // This animates the selected CardView up.
                let delayInterval: Double = 0.05 * Double(j - deletedCardIndex) // deletedCardIndex is subtracted to only create delay after the first CardView
                UIView.animateWithDuration(self.verticalAnimationDuration, delay: delayInterval, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.cardArray[j].center.y = self.cardArray[j].bounds.height * 0.5 + self.cardHeightsAndMarginsUpToButNotIncludingIndex(j)
                    }, completion: nil)
                if(delayInterval > largestDelayInterval) {
                    largestDelayInterval = delayInterval
                }
        }
        self.adjustCardScrollView(largestDelayInterval)
    }
    
    private func removeCardAtIndex(i: Int) {
        var card: CardView = cardArray[i]
        card.removeGestureRecognizer(card.panGestureRecognizerReference!)
        self.cardArray.removeAtIndex(i)
        
        UIView.animateWithDuration(swipeOutAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            // This makes the card fade out and move away.
            card.center.x = -card.bounds.width
            card.alpha = 0
            }, completion: {(value: Bool) in
                // Here, the card is removed from the UIScrollView and deleted.
                card.removeFromSuperview()
                
                // This repositions the remaining cards and adjusts their positions.
                self.repositionRemainingCards(i)
        })
    }
    
    private func adjustCardScrollView(animationDelay: NSTimeInterval) {
        UIView.animateWithDuration(verticalAnimationDuration, delay: animationDelay, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.cardScrollView.contentSize = CGSizeMake(self.view.bounds.width, self.cardHeightsAndMarginsUpToButNotIncludingIndex(self.cardArray.count))
            }, completion: nil)
    }
    
    private func cardHeightsAndMarginsUpToButNotIncludingIndex(i: Int) -> CGFloat {
        var totalHeight: CGFloat = margin // Setting totalHeight to margin at first accounts for the very top margin (there are always x cards and x + 1 margins).
        for j in 0..<i {
            totalHeight += cardArray[j].bounds.height + margin
        }
        return totalHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

