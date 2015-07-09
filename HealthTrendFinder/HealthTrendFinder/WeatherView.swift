//
//  WeatherView.swift
//  HealthTrendFinder
//
//  Created by Holden Lee on 7/9/15.
//
//

import UIKit

class WeatherView: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData("api.openweathermap.org/data/2.5/weather?q=London,uk")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherData(urlString: String) {
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.setWeather(data)
            })
        }
        task.resume()
    }
    
    func setWeather(weatherData: NSData) {
        
        var temp: String?
        
        var jsonError: NSError?
        
        let json = NSJSONSerialization.JSONObjectWithData(weatherData, options: nil, error: &jsonError) as! NSDictionary
        if let name = json["name"] as? String {
            cityLabel.text = name
        }
        
        if let main = json["main"] as? NSDictionary {
            if let temperature = main["temp"] as? Double {
                temp = String(format: "4.1f", temperature)
                
            }
        }
        
    }
    
}
