//
//  PopoverViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 09.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var newUserBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var PopoverMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        newUserBtn.layer.cornerRadius = 5
        CancelBtn.layer.cornerRadius = 5
        PopoverMessageLabel.text = "Auf diesem Gerät waren Sie bisher mit einer anderen User-Email angemeldet.\n\nWollen Sie sich als neuer User anmelden und die auf diesem Gerät gespeicherten Punkte löschen?\nDann drücken Sie bitte unten auf 'new User' und loggen Sie sich erneut ein."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newUserBtnTapped(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: HASBEENVERIFIED_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func CancelBtnTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
