//
//  ScanCodeViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 13.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class ScanCodeViewController: UIViewController {

    @IBOutlet weak var CodeInputField: UITextField!
    @IBOutlet weak var CodeResponseField: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ScanButtonTapped(sender: UIButton) {
        requestProgramData(CodeInputField.text)
    }
    
    func requestProgramData(scannedCode: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicodecheck")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "user" : "j2@guesswhapp.de",
            "qpInput" : scannedCode
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary!)
            dispatch_async(dispatch_get_main_queue(),{
                self.CodeResponseField.hidden = false
                self.CodeResponseField.text = jsonDictionary!["message"]! as? String
            });
        })
        task.resume()
    }

}
