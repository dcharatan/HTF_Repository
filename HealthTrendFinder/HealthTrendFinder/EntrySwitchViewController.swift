//
//  EntrySwitchViewController.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/29/15.
//
//

import UIKit

class EntrySwitchViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
        // Depending on whether HealthKit has been activated, this either goes to the HealthKit activation screen or the app.
        let defaults = NSUserDefaults.standardUserDefaults()
        if let healthKitAuthorized = defaults.valueForKey(StorageManager.StorageKeys.healthKitAuthorized.rawValue) as? Bool {
            if healthKitAuthorized {
                performSegueWithIdentifier("segueToApp", sender: nil)
            } else {
                performSegueWithIdentifier("segueToHealthKitAuthorization", sender: nil)
            }
        } else {
            println("EntrySwitchViewController: No value for StorageManager.StorageKeys.healthKitAuthorized.rawValue found. Switching to HealthKit authorization view.")
            performSegueWithIdentifier("segueToHealthKitAuthorization", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
