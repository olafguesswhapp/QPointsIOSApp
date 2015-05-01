//
//  RedeemViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 23.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

// Monadic bind for Optionals
infix operator >>= {associativity left}
func >>= <A,B> (m: A?, f: A -> B?) -> B? {
    if let x = m {return f(x)}
    return .None
}

extension Character {
    func utf8() -> UInt8 {
        let utf8 = String(self).utf8
        return utf8[utf8.startIndex]
    }
}

class RedeemViewController: UIViewController {

    @IBOutlet weak var RequestDeclinedButton: UIButton!
    @IBOutlet weak var RedeemRequestLabel: UILabel!
    @IBOutlet weak var VerificationRequestLabel: UILabel!
    @IBOutlet weak var ProgramNameLabel: UILabel!
    @IBOutlet weak var RedeemProcessFinishedButton: UIButton!
    @IBOutlet weak var VerificationCodeLabel: UILabel!
    @IBOutlet weak var VerificationButton: UIButton!
    @IBOutlet weak var VerificationCodeInputField: UITextField!
    
    var redeemProgramModel: ProgramModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ProgramNameLabel.text = redeemProgramModel.programName
        self.VerificationButton.layer.cornerRadius = 5
        self.RequestDeclinedButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "returnDetailVCSegue" {
            let detailVC: DetailViewController = segue.destinationViewController as DetailViewController
            detailVC.detailProgramModel = redeemProgramModel
        }
    }
    
    @IBAction func VerifiyRedeemCodeButtonTapped(sender: UIButton) {
        // Beispiel als Verification Code = 2T@
        var decryptedVerification:String = encryptKey(redeemProgramModel.programKey)(message: VerificationCodeInputField.text)!
        println(decryptedVerification)
        VerificationCodeLabel.layer.borderColor = UIColor.blueColor().CGColor!
        VerificationCodeLabel.layer.cornerRadius = 5
        VerificationCodeLabel.layer.borderWidth = 1.0
        VerificationCodeLabel.text = decryptedVerification
        VerificationCodeLabel.hidden = false
        RedeemRequestLabel.hidden = false
        RequestDeclinedButton.hidden = false
        VerificationButton.hidden = true
        VerificationRequestLabel.hidden = true
        VerificationCodeInputField.hidden = true
        VerificationCodeInputField.text = ""
        RedeemProcessFinishedButton.layer.cornerRadius = 5
        RedeemProcessFinishedButton.hidden = false
        VerificationCodeInputField.resignFirstResponder()
    }
    
    @IBAction func FinishRedeemProcessButtonTapped(sender: UIButton) {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        self.redeemProgramModel.programsFinished -= 1
        println(self.redeemProgramModel.programsFinished)
        appDelegate.saveContext()
        redeemCodes()
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func RequestDeclineButtonTapped(sender: UIButton) {
        self.VerificationCodeLabel.text = ""
        self.VerificationCodeLabel.hidden = true
        self.VerificationButton.hidden = true
        self.RedeemProcessFinishedButton.hidden = true
        self.RedeemRequestLabel.hidden = true
        self.RequestDeclinedButton.hidden = true
        self.VerificationRequestLabel.hidden = false
        self.VerificationButton.hidden = false
        self.VerificationCodeInputField.hidden = false
    }
    
    func encrypt(key:Character, c:Character) -> String? {
        let byte = [key.utf8() ^ c.utf8()]
        return String(bytes: byte, encoding: NSUTF8StringEncoding)
    }
    
    // Curried func for convenient use with map
    func encryptKey(key:String)(message:String) -> String? {
        return reduce(Zip2(key, message), Optional("")) { str, c in str >>= { s in self.encrypt(c).map {s + $0} }}
    }
    
    func redeemCodes()-> Void {
        // Prepare API Redeem Post request
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/apicoderedeem")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
        "user" : "j2@guesswhapp.de",
        "programNr" : redeemProgramModel.programNr,
        "programGoal" : String(redeemProgramModel.programGoal)
        ]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // API Redeem Post request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary!)
            var answer:String = jsonDictionary!["message"]! as String
            println("Answer from WebServer to Redeem Request: \(answer)")
            println(jsonDictionary!["success"]! as Bool)
        })
        task.resume()
    }
}
