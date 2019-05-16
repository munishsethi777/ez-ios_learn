//
//  ViewController.swift
//  RightManagement
//
//  Created by Munish Sethi on 09/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var workingAreaView: UIView!
    var moduleSeq = 0
    var lpSeq = 0
    var  progressHUD: ProgressHUD!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.isEnabled = false
        usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        let windowHeight = self.view.frame.height
        self.workingAreaView.frame.origin.y = (windowHeight/2) - 135
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                if self.view.frame.height - keyboardSize.height < 350{
                    let shiftingHeight = keyboardSize.height - 100
                    self.view.frame.origin.y -= shiftingHeight
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                if self.view.frame.height - keyboardSize.height < 350{
                    let shiftingHeight = keyboardSize.height - 100
                    self.view.frame.origin.y += shiftingHeight
                }
            }
        }
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        let loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        UIApplication.shared.applicationIconBadgeNumber = 0
        if(loggedInUserSeq > 0){
            self.performSegue(withIdentifier: "DashboardTabController", sender: nil)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBAction func loginButton(_ sender: UIButton) {
        var username: String = usernameTextField.text!;
        var password: String = passwordTextField.text!;
        username = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        password = password.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        var deviceId = PreferencesUtil.sharedInstance.getDeviceId()
        if(deviceId == nil){
            deviceId = ""
        }
        let args: [String] = [username,password,deviceId!]
        let url: String = MessageFormat.format(pattern: StringConstants.LOGIN_URL, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: url, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        UserMgr.sharedInstance.saveUser(response: json)
                        self.performSegue(withIdentifier: "DashboardTabController", sender: nil)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Validation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let userName = usernameTextField.text, !userName.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else {
                loginBtn.isEnabled = false
                return
        }
        loginBtn.isEnabled = true
    }
    
    
}

