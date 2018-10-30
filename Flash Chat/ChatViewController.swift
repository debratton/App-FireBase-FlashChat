//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // Declare instance variables here
    // Test array
    //let messageArray = ["First Message", "Second Message", "Third Message", "Fourth Message"]
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")

        // TODO: Call func to set height of rows in tableview
        configureTableView()
        
        // TODO: Get new messages
        retrieveMessages()
        
        // Remove seperator lines, you should be able to do this in storyboard as well
        messageTableView.separatorStyle = .none
        
    }

    
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
        
    }
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        // Defined in CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    //MARK:- TextField Delegate Methods
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Keyboard hieght is 250 and the text field is 50 so 258 + 50 = 308
        //heightConstraint.constant = 308
        // Now you have to redraw everything
        //view.layoutIfNeeded()
        // Now make it so the animation is more smooth
        // Move two cmds from above into the closure in this method
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
            })
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    // Same as above, except we just move it back to 50
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        // Check make sure value is added to text field
        if let newMsg = messageTextfield.text {
            // Set key to Messages, can be any name, just what we called it
            let messagesDB = Database.database().reference().child("Messages")
            // Create dictionary and add sender email and text message
            let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": newMsg]
            // Save with auto id, manually add closure by adding curly brackets
            messagesDB.childByAutoId().setValue(messageDictionary) {
                (error, reference) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Message Saved Successfully!")
                    self.messageTextfield.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextfield.text = ""
                }
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        // Call same name you specified above
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            if let text = snapshotValue["MessageBody"] {
                if let sender = snapshotValue["Sender"] {
                    // Create message object
                    let message = Message()
                    message.messageBody = text
                    message.sender = sender
                    // Now append that object into the blank array at top
                    self.messageArray.append(message)
                    // Have to call func to to redraw
                    self.configureTableView()
                    // Have to reload data
                    self.messageTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error, there was an error")
        }
    }
}
