//
//  ChangePasswordViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 24/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class ChangePassworViewController: UIViewController{
    
    @IBOutlet weak var submitButton: UIButton!
    @IBAction func submitTapped(_ sender: Any) {
        if(isValidate()){
            exceuteChangePassword()
        }else{
            showAlert(message: "Confirm Password should match with new password", title: "Failed")
        }
    }
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var oldPasswordText: UITextField!
    var loggedInUserSeq:Int = 0
    var loggedInCompanySeq:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        confirmPassword.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        newPasswordText.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        oldPasswordText.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        loggedInUserSeq =  PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        //setbackround()
    }
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavBarColor()
    }
    
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        let color = UIColor.init(red: 255/255.0, green: 102/255.0, blue: 51/255.0, alpha: 0.5)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageFromColor(color: color), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func showAlert(message: String,title:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
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
            let confirmPassword = confirmPassword.text, !confirmPassword.isEmpty,
            let newPassword = newPasswordText.text, !newPassword.isEmpty,
            let oldPassword = oldPasswordText.text, !oldPassword.isEmpty
            else {
                self.submitButton.isEnabled = false
                return
        }
        submitButton.isEnabled = true
    }

    
    func exceuteChangePassword(){
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,oldPasswordText.text!,newPasswordText.text!]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.CHANGE_PASSWORD, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.showAlert(message: message!,title:"Success")
                        self.reset()
                    }else{
                        self.showAlert(message: message!,title:"Failed")
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description,title:"Exception")
            }
        })
    }
    
    func isValidate()->Bool{
        return newPasswordText.text == confirmPassword.text
    }
    
    private func reset(){
        confirmPassword.text = ""
        newPasswordText.text = ""
        oldPasswordText.text = ""
    }
}
