//
//  ReplaceWithoutAnimationSegue.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 7/29/15.
//
//

import UIKit

class ReplaceWithoutAnimationSegue: UIStoryboardSegue {
    override func perform() {
        let source: UIViewController = sourceViewController as! UIViewController
        let destination: UIViewController = destinationViewController as! UIViewController
        
        if let navigation: UINavigationController = source.navigationController {
            navigation.presentViewController(destination, animated: false, completion: nil)
        }
    }
}
