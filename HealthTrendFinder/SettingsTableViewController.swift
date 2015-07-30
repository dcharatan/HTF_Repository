
//
//  SettingsTableViewController.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/22/15.
//
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var authorizationCell: UITableViewCell!
    @IBOutlet weak var allowDailyNotificationsCell: UITableViewCell!
    @IBOutlet weak var allowWeeklyNotificationsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let healthKitAuthorized = StorageManager.getValue(StorageManager.StorageKeys.healthKitAuthorized) as? Bool {
            if healthKitAuthorized {
                authorizationCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                self.authorizationCell.selectionStyle = UITableViewCellSelectionStyle.None
            }
        }
        
        allowDailyNotificationsCell.selectionStyle = UITableViewCellSelectionStyle.None
        var dailyNotificationsSwitch = UISwitch(frame: CGRectZero) as UISwitch
        dailyNotificationsSwitch.on = false
        allowDailyNotificationsCell.accessoryView = dailyNotificationsSwitch
        dailyNotificationsSwitch.addTarget(self, action: Selector("switchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        if let dailyNotificationsEnabled = StorageManager.getValue(StorageManager.StorageKeys.allowDailyNotifications) as? Bool {
            if dailyNotificationsEnabled {
                dailyNotificationsSwitch.on = true
            }
        }
        
        allowWeeklyNotificationsCell.selectionStyle = UITableViewCellSelectionStyle.None
        var weeklyNotificationsSwitch = UISwitch(frame: CGRectZero) as UISwitch
        weeklyNotificationsSwitch.on = false
        allowWeeklyNotificationsCell.accessoryView = weeklyNotificationsSwitch
        weeklyNotificationsSwitch.addTarget(self, action: Selector("switchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        if let weeklyNotificationsEnabled = StorageManager.getValue(StorageManager.StorageKeys.allowWeeklyNotifications) as? Bool {
            if weeklyNotificationsEnabled {
                weeklyNotificationsSwitch.on = true
            }
        }
    }
    
    func switchChanged(sender: UISwitch) {
        if sender == allowDailyNotificationsCell.accessoryView {
            StorageManager.setValue(sender.on, forKey: StorageManager.StorageKeys.allowDailyNotifications)
        }
        if sender == allowWeeklyNotificationsCell.accessoryView {
            StorageManager.setValue(sender.on, forKey: StorageManager.StorageKeys.allowWeeklyNotifications)
        }
    }

    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == tableView.indexPathForCell(authorizationCell) {
            if let healthKitAuthorized = StorageManager.getValue(StorageManager.StorageKeys.healthKitAuthorized) as? Bool {
                if !healthKitAuthorized {
                    authorizeHealthKit()
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    private func authorizeHealthKit() {
        self.authorizationCell.selectionStyle = UITableViewCellSelectionStyle.None
        self.authorizationCell.accessoryType = UITableViewCellAccessoryType.None
        self.authorizationCell.detailTextLabel!.text = "HealthKit authorization is in progress. Please wait."
        var healthManager = HKManager()
        healthManager.authorizeHealthKit({success, error in
            if success {
                self.authorizationCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                self.authorizationCell.detailTextLabel!.text = "Use the Health app to change HealthKit authorizations."
                StorageManager.setValue(true, forKey: StorageManager.StorageKeys.healthKitAuthorized)
            }
        })
    }

}
