//
//  CardDetailViewController.swift
//  HealthTrendFinder
//
//  Created by David Charatan on 8/4/15.
//
//

import UIKit

class CardDetailViewController: UIViewController {
    var cardTitle: String = "---"
    
    @IBOutlet weak var sampleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sampleLabel.text = cardTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
