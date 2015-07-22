//
//  EnableHealthKitViewController.swift
//  HealthTrendFinder
//
//  Created by Holden Lee on 7/16/15.
//
//

import UIKit

class EnableHealthKitViewController: UIViewController {

    
    @IBOutlet weak var textLabel: UILabel!
    
    // Note to self: change this to a slider at some point
    
    @IBAction func authorizationButton(sender: UIButton) {
        var healthManager = HKManager()
        healthManager.authorizeHealthKit({success, error in
            if success {
                println("HealthKit Authorized")
            }
        })
        
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
