//
//  RedeemViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 21.04.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

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
        VerificationCodeLabel.text = VerificationCodeInputField.text
        VerificationCodeLabel.hidden = false
        VerificationButton.hidden = true
        VerificationCodeInputField.text = ""
        RedeemProcessFinishedButton.layer.cornerRadius = 5
        RedeemProcessFinishedButton.hidden = false
    }
    
    @IBAction func FinishRedeemProcessButtonTapped(sender: UIButton) {
        println(self.redeemProgramModel.programsFinished)
        println("Vorher & Nachher")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        self.redeemProgramModel.programsFinished -= 1
        println(self.redeemProgramModel.programsFinished)
        appDelegate.saveContext()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
