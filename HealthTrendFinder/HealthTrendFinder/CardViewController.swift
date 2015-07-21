//
//  CardViewController.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 6/29/15.
//
//

import UIKit
import Foundation

class CardViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    private let swipeOutAnimationDuration = 0.33 // The duration of the swiping away CardView animation
    private let verticalAnimationDuration = 0.25 // The duration of the vertical CardView animation
    private let verticalAnimationDelay = 0.05 // The delay between each CardView's animation after another CardView is deleted
    private let scrollThreshold: CGFloat = 10.0 // The distance you have to scroll to be locked into scrolling
    private let movementThreshold: CGFloat = 10.0 // The distance you have to drag to be locked into dragging
    private let deletionThreshold: CGFloat = 50.0 // The distance you have to drag to delete a CardView
    private let margin: CGFloat = 8.0 // This is needed for a few calculations, so it's kept here.
    
    private var cardArray: [CardView] = []
    private lazy var cardRefreshControl:UIRefreshControl = UIRefreshControl() // This is the variable that stores the UIRefreshControl for cardScrollView.
    private var originalScrollPosition: CGFloat = 0.0 // This is used to track whether you've scrolled far enough to be locked into scrolling.
    private var scrollingLocked: Bool = false // This is used to track whether you're locked into scrolling.
    
    // This is a temporary button used to add cards.
    @IBAction func plusButtonPressed(sender: AnyObject) {
        addCard()
    }
    
    @IBOutlet weak var cardScrollView: UIScrollView! // This is the outlet for the UIScrollView the CardView instances are placed in.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This configures the UIRefreshControl which is a lazy var found above.
        cardRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        cardRefreshControl.addTarget(self, action: "refreshCards:", forControlEvents: UIControlEvents.ValueChanged)
        cardScrollView.addSubview(cardRefreshControl)
        
        // This must be done to allow a refresh to happen when cardScrollView does not fill its parent's height.
        cardScrollView.alwaysBounceVertical = true
        
        // This allows tracking scrolling.
        cardScrollView.delegate = self
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .MediumStyle
        
        println(formatter.stringFromDate(NSDate()))
        
        let UnknownString = "Unknown"
        
        var healthManager = HKManager()
        
        // Read basic data
        
        healthManager.allTimeStepsTotal = 0.0
        healthManager.allTimeStepsSum = 0.0
        healthManager.stepsAllTime({Double, NSError in
            println("All Done")
        })
        println("Finished executing stepsAllTime")
    }
    
    // This is called when cardScrollView begins to scroll.
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // Later, the originalScrollPosition is compared with the current scroll position to determine offset.
        originalScrollPosition = scrollView.contentOffset.y
    }
    
    // This is called when cardScrollView scrolls.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // If you're refreshing, it locks you into scrolling.
        if(cardRefreshControl.bounds.height > 0) {
            scrollingLocked = true
        }
        
        if(abs(originalScrollPosition - scrollView.contentOffset.y) > scrollThreshold) {
            scrollingLocked = true
        }
    }
    
    // scrollingLocked is disabled when scrolling ends due to deceleration or the cessation of dragging.
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollingLocked = false
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollingLocked = false
    }
    
    // This is used to allow the UIPanGestureRecognizers to work together with the UIScrollView's scrolling.
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // This is called when you refresh.
    func refreshCards(sender: AnyObject) {
        cardRefreshControl.endRefreshing()
    }
    
    // This adds a card.
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
        
        // Makes sure scrolling doesn't get locked into because of change in scroll window size.
        scrollingLocked = false
    }
    
    func detectPan(recognizer: UIPanGestureRecognizer) {
        for i in 0..<cardArray.count {
            if recognizer.view != nil && recognizer.view == cardArray[i] {
                // This prepares the CardView for dragging.
                if recognizer.state == .Began {
                    cardArray[i].lastLocation = cardArray[i].center
                }
                
                // This moves the CardView when you drag.
                var translation = recognizer.translationInView(self.cardArray[i].superview!)
                
                // This is done once the CardView has passed the threshold but not yet been marked as swiped. (Note that scrolling must not be happening)
                if abs(translation.x) >= movementThreshold && cardScrollView.scrollEnabled && !scrollingLocked {
                        // This is the point where swiping has just begun, so to prevent a horizontal jump that's exactly minDistance units long, you add translation.x to cardArray[i].lastLocation.
                        cardArray[i].lastLocation.x -= translation.x
                        
                        // Now that swiping is happening, scrolling is disabled.
                        cardScrollView.scrollEnabled = false
                }
                
                // This is where the cardArray is actually moved.
                if !cardScrollView.scrollEnabled {
                    cardArray[i].center = CGPointMake(cardArray[i].lastLocation.x + translation.x, cardArray[i].lastLocation.y)
                }
                
                // This detects the end of drag gestures.
                if recognizer.state == .Ended {
                    cardScrollView.scrollEnabled = true
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
        var newHeight: CGFloat = self.cardHeightsAndMarginsUpToButNotIncludingIndex(self.cardArray.count)
        
        UIView.animateWithDuration(verticalAnimationDuration, delay: animationDelay, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.cardScrollView.contentSize = CGSizeMake(self.view.bounds.width, newHeight)
            }, completion: {(value: Bool) in
                self.scrollingLocked = false
        })
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

