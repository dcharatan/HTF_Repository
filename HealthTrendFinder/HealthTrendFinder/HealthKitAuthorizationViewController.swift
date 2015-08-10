//
//  HealthKitAuthorizationViewController.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/29/15.
//
//

import UIKit

class HealthKitAuthorizationViewController: UIViewController {
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This resizes textView so that it's the size of the text.
        textView.sizeToFit()
        textView.layoutIfNeeded()
        textViewHeight.constant = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, CGFloat.max)).height
        
        // This asks for notification authorization.
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
    }

    @IBAction func authorizeHK(sender: AnyObject) {
        var healthManager = HKManager()
        healthManager.authorizeHealthKit({success, error in
            if success {
                StorageManager.setValue(true, forKey: StorageManager.StorageKeys.HealthKitAuthorized)
                
                // You have to wait until everything's ready for a new animation before animating out. This is accomplished with dispatch_async.
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("segueToApp", sender: nil)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
