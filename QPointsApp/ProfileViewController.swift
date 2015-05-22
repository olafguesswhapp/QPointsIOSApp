//
//  ProfileViewController.swift
//  QPointsApp
//
//  Created by Olaf Peters on 19.05.15.
//  Copyright (c) 2015 GuessWhapp. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var UserEmailTextField: UITextField!

    @IBOutlet weak var UserPasswordTextField1: UITextField!
    @IBOutlet weak var UserPasswordTextField2: UITextField!
    @IBOutlet weak var SaveProfileUpdateButton: UIButton!
    @IBOutlet weak var UserGenderPicker: UIPickerView!
    
    var userGender = ["Nicht angeben", "Weiblich", "Männlich"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UserEmailTextField.text = NSUserDefaults.standardUserDefaults().objectForKey(USERMAIL_KEY) as? String
        UserEmailTextField.userInteractionEnabled = false
        UserPasswordTextField1.text = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as? String
        UserPasswordTextField2.text = NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as? String
        UserGenderPicker.dataSource = self
        UserGenderPicker.delegate = self
        self.SaveProfileUpdateButton.layer.cornerRadius = 5
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LogoutSegue" {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func LogoutBtnTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("LogoutSegue", sender: self)
    }
    
    @IBAction func SaveProfileUpdateBtnTapped(sender: UIButton) {
        var gender: Int16 = Int16(UserGenderPicker.selectedRowInComponent(0))
        var reconTask: ReconciliationModel = self.setReconciliationList(5, setRecLiUser: UserEmailTextField.text, setRecLiProgNr: "", setRecLiGoalToHit: 0, setRecLiQPCode: UserPasswordTextField2.text, setRecLiPW: NSUserDefaults.standardUserDefaults().objectForKey(PASSWORD_KEY) as String, setRecLiGender: gender)
        self.APIPostRequest(reconTask,apiType: 5){
            (responseDict: NSDictionary) in

            if (responseDict["success"] as Bool == false) {
                println(responseDict["message"] as String)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(reconTask.reconQpInput, forKey: PASSWORD_KEY)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // UIPicker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userGender.count
    }
    
    // UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return userGender[row]
    }

}
