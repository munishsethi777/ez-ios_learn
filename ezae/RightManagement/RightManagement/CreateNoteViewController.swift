//
//  CreateNoteViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 26/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class CreateNoteViewController: UIViewController{
    var noteSeq:Int = 0
    var loggedInUserSeq:Int = 0
    var loggedInCompanySeq:Int = 0
    var  progressHUD: ProgressHUD!
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBAction func saveNoteAction(_ sender: Any) {
        saveNote()
    }
    override func viewDidLoad() {
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        progressHUD = ProgressHUD(text: "Loading")
        progressHUD.hide()
        self.view.addSubview(progressHUD)
        if(noteSeq > 0){
            progressHUD.show()
            getNoteDetail()
        }
    }
    @IBAction func saveNoteTapped(_ sender: Any) {
        saveNote()
    }
    func getNoteDetail(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq,self.noteSeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_NOTE_DETAIL, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadNoteDetail(response: json)
                    }else{
                        self.showAlert(message: message!,title:"Failed")
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description,title:"Exception")
            }
        })
    }
    
    func saveNote(){
        progressHUD.text = "Saving"
        progressHUD.show()
        var detailText = detailTextView.text as! String
        detailText = detailText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,self.noteSeq,detailText]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.SAVE_NOTES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.progressHUD.hide()
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.showAlert(message: message!,title:"Failed")
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description,title:"Exception")
            }
        })
    }
    
    func loadNoteDetail(response:[String: Any]){
        let notes = response["notes"] as! [String: Any]
        let noteSeq = notes["seq"] as! String;
        let noteDetails = notes["details"] as! String
        detailTextView.text = noteDetails
        progressHUD.hide()
    }
    
    func showAlert(message: String,title:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
