//
//  NotesViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 24/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class NotesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    var notesCount:Int = 0
    var loggedInUserSeq:Int = 0
    var loggedInCompanySeq:Int = 0
    var notes:[Notes]=[]
    var selectedNoteSeq:Int = 0
    var refreshControl:UIRefreshControl!
    var  progressHUD: ProgressHUD!
    @IBOutlet weak var notesTableView: UITableView!
    override func viewDidLoad() {
        //setbackround()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        notesTableView.dataSource = self
        notesTableView.delegate = self
        //getNotes()
        
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
            notesTableView.refreshControl = refreshControl
        }
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
    }
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.notesTableView.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    
    @objc func refreshView(refreshControl: UIRefreshControl) {
        getNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         getNotes()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavBarColor()
    }
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        let color = UIColor.init(red: 99/255.0, green: 144/255.0, blue: 198/255.0, alpha: 0.5)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageFromColor(color: color), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NotesTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotesTableViewCell
        let note = notes[indexPath.row]
        cell?.titleLabel.text = note.title
        cell?.dateTime.text = note.dateTime
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        selectedNoteSeq = note.seq
        self.performSegue(withIdentifier: "NotesViewController", sender: nil)
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // action two
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.delete(tableView:tableView,index:indexPath)
        })
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    private func delete(tableView:UITableView,index:IndexPath){
        let refreshAlert = UIAlertController(title: "Delete Notes", message: "Are you realy want to delete this Note?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
             self.progressHUD.show()
             self.deleteNote(tableView:tableView,index:index)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    func deleteNote(tableView:UITableView,index:IndexPath){
        let note = notes[index.row]
        let noteSeq = note.seq
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,noteSeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.DELETE_NOTES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.notes.remove(at: index.row)
                        self.progressHUD.hide()
                        tableView.deleteRows(at: [index], with: .fade)
                        self.showAlert(message: message!,title:"Success")
                    }else{
                        self.showAlert(message: message!,title:"Failed")
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description,title:"Exception")
            }
        })
    }
    func getNotes(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_NOTES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadNotes(response: json)
                    }else{
                        self.showAlert(message: message!,title:"Failed")
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description,title:"Exception")
            }
        })
    }
    
    func loadNotes(response:[String: Any]){
        let notesArr = response["notes"] as! [Any]
        self.notesCount = notesArr.count
        notes = []
        for i in 0..<notesArr.count{
            let note = notesArr[i] as! [String: Any]
            let noteSeq = note["seq"] as! String;
            let noteDetails = note["details"] as! String;
            let noteCreatedOn = note["createdon"] as! String;
            let noteObj = Notes.init(seq: Int(noteSeq)!, title: noteDetails, dateTime: noteCreatedOn)
            notes.append(noteObj)
        }
        self.progressHUD.hide()
        if #available(iOS 10.0, *) {
            refreshControl.endRefreshing()
        }
        notesTableView.reloadData()
    }
    
    func showAlert(message: String,title:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "NotesViewController") {
            let destinationVC:CreateNoteViewController = segue.destination as! CreateNoteViewController
            destinationVC.noteSeq = self.selectedNoteSeq
        }
    }
    
    
}
