//
//  LoginViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 08.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var UserPasswordTextField: UITextField!
    @IBOutlet weak var UserEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.LoginButton.layer.cornerRadius = 5
        self.CreateAccountButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSuccessfulSegue" {
            
        }
    }
    
    @IBAction func LoginBtnTapped(sender: UIButton) {
        let savedUserEmail = NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as String
        let savedPassword = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as String
        
        if UserEmailTextField.text == savedUserEmail && UserPasswordTextField.text == savedPassword {
            performSegueWithIdentifier("loginSuccessfulSegue", sender: self)
        }

    }

    @IBAction func CreateAccountBtnTapped(sender: UIButton) {
        performSegueWithIdentifier("createAccountSegue", sender: self)
    }
}
