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
        // Beispiel als Verification Code = 2T@
        var interim = encryptKey(redeemProgramModel.programKey)(message: VerificationCodeInputField.text)
        VerificationCodeLabel.hidden = false
        println(interim!)
        VerificationCodeLabel.text = interim!
        VerificationButton.hidden = true
        VerificationCodeInputField.text = ""
        RedeemProcessFinishedButton.layer.cornerRadius = 5
        RedeemProcessFinishedButton.hidden = false
    }
    
    @IBAction func FinishRedeemProcessButtonTapped(sender: UIButton) {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        self.redeemProgramModel.programsFinished -= 1
        println(self.redeemProgramModel.programsFinished)
        appDelegate.saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func encrypt(key:Character, c:Character) -> String? {
        let byte = [key.utf8() ^ c.utf8()]
        return String(bytes: byte, encoding: NSUTF8StringEncoding)
    }
    
    // Curried func for convenient use with map
    func encryptKey(key:String)(message:String) -> String? {
        return reduce(Zip2(key, message), Optional("")) { str, c in str >>= { s in self.encrypt(c).map {s + $0} }}
    }
    
}
