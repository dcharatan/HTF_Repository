//
//  StartViewController.swift
//  HealthTrendFinder
//
//  Created by Holden Lee on 7/23/15.
//
//

import UIKit
import CoreLocation

class StartViewController: UIViewController, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This view controller exists solely to keep the AppDelegate light. It appears at the start, executes functions, then disappears permanently
        var itWorks: Bool = false
        var waiting: Bool = true
        var locationManager: CLLocationManager!
        var seenError : Bool = false
        var locationFixAchieved : Bool = false
        var locationStatus : NSString = "Not Started"
        
        
        // Authorize HealthKit
        let healthManager = HKManager()
        healthManager.authorizeHealthKit({success, error in
            if success {
                println("HealthKit Authorized")
                itWorks = true
            }
        })
        
        while waiting {
            if itWorks {
                
                // Read the past month's step data
                healthManager.stepsInPastMonth({Double, NSError in
                    
                })
                    
                // Read the past week's step data
                healthManager.stepsInPastWeek({Double, NSError in
                    
                })
                
                // Read the past days's step data
                healthManager.stepsInPastDay({Double, NSError in
                    
                })
                
                // Read All-Time Step Data
                healthManager.allTimeStepsTotal = 0.0
                healthManager.allTimeStepsSum = 0.0
                healthManager.stepsAllTimeTotal({Double, NSError in
                    println("All Done")
                })
                println("Finished executing stepsAllTime")
                waiting = false
            }
        }
        self.performSegueWithIdentifier("moveOn", sender: nil)
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
