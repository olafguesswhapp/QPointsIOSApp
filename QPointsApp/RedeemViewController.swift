//
//  RedeemViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 23.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit
import CoreData

// Monadic bind for Optionals
//infix operator >>= {associativity left}
//func >>= <A,B> (m: A?, f: A -> B?) -> B? {
//    if let x = m {return f(x)}
//    return .None
//}
//
extension Character {
    func utf8() -> UInt8 {
        let utf8 = String(self).utf8
        return utf8[utf8.startIndex]
    }
}

class RedeemViewController: UIViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsCircleView: UIView!
    @IBOutlet weak var programEndDateLabel: UILabel!
    @IBOutlet weak var redeemView: UIView!
    @IBOutlet weak var programCompanyLabel: UILabel!
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
        
        let brandView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        brandView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "QPointsBrand")
        brandView.image = image
        self.navigationItem.titleView = brandView
        
        self.view.backgroundColor = QPColors.dunkelBlau
        self.redeemView.backgroundColor = QPColors.mittelGruen
        self.programCompanyLabel.textColor = UIColor.whiteColor()
        self.ProgramNameLabel.textColor = UIColor.whiteColor()
        self.pointsLabel.textColor = UIColor.whiteColor()
        self.programEndDateLabel.textColor = UIColor.whiteColor()
        self.ProgramNameLabel.sizeToFit()
        self.pointsLabel.textAlignment = .Center
        self.pointsCircleView.layer.cornerRadius = 45.0
        self.pointsCircleView.backgroundColor = QPColors.hellGruen
        self.VerificationButton.backgroundColor = QPColors.dunkelRot

        // Do any additional setup after loading the view.
        self.programCompanyLabel.text = redeemProgramModel.programCompany
        self.ProgramNameLabel.text = redeemProgramModel.programName
        self.pointsLabel.text = "\(redeemProgramModel.myCount) / \(redeemProgramModel.programGoal)"
        self.programEndDateLabel.text = "gütig bis \(NSDateFormatter.localizedStringFromDate(redeemProgramModel.programEndDate, dateStyle: .MediumStyle, timeStyle: .NoStyle))"
        self.VerificationButton.layer.cornerRadius = 5
        self.RequestDeclinedButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "returnDetailVCSegue" {
            let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
            detailVC.detailProgramModel = redeemProgramModel
        }
    }
    
    @IBAction func VerifiyRedeemCodeButtonTapped(sender: UIButton) {
        // Beispiel als Verification Code = 2T@
//        var decryptedVerification:String = encryptKey(redeemProgramModel.programKey)(message: VerificationCodeInputField.text)!
//        println(decryptedVerification)
//        VerificationCodeLabel.layer.borderColor = UIColor.blueColor().CGColor!
//        VerificationCodeLabel.layer.cornerRadius = 5
//        VerificationCodeLabel.layer.borderWidth = 1.0
//        VerificationCodeLabel.text = redeemProgramModel.programKey //decryptedVerification
//        VerificationCodeLabel.hidden = false
        RedeemRequestLabel.hidden = false
        RequestDeclinedButton.hidden = false
        RequestDeclinedButton.backgroundColor = QPColors.hellRot
        VerificationButton.hidden = true
        VerificationRequestLabel.hidden = true
//        VerificationCodeInputField.hidden = true
//        VerificationCodeInputField.text = ""
        RedeemProcessFinishedButton.layer.cornerRadius = 5
        RedeemProcessFinishedButton.backgroundColor = QPColors.dunkelRot
        RedeemProcessFinishedButton.hidden = false
        VerificationCodeInputField.resignFirstResponder()
    }
    
    @IBAction func FinishRedeemProcessButtonTapped(sender: UIButton) {
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        self.redeemProgramModel.programsFinished -= 1
        println(self.redeemProgramModel.programsFinished)
        appDelegate.saveContext()
        var reconTask: ReconciliationModel = self.setReconciliationList(2,setRecLiUser: NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as! String, setRecLiProgNr: redeemProgramModel.programNr,setRecLiGoalToHit: redeemProgramModel.programGoal, setRecLiQPCode: "", setRecLiPW: "", setRecLiGender: 0)
        self.navigationController?.popViewControllerAnimated(true)
        
        // if Internet available ...
        if Reachability.isConnectedToNetwork() {
            self.APIPostRequest(reconTask,apiType: 2){
                (responseDict: NSDictionary) in
            }
        }

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
    
//    func encrypt(key:Character, c:Character) -> String? {
//        let byte = [key.utf8() ^ c.utf8()]
//        return String(bytes: byte, encoding: NSUTF8StringEncoding)
//    }
    
    // Curried func for convenient use with map
//    func encryptKey(key:String)(message:String) -> String? {
//        return reduce(Zip2(key, message), Optional("")) { str, c in str >>= { s in self.encrypt(c).map {s + $0} }}
//    }
    
}
