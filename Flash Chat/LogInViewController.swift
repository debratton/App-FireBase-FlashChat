//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        if let email = emailTextfield.text {
            if let password = passwordTextfield.text {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        SVProgressHUD.dismiss()
                        print("Login Success")
                        self.emailTextfield.text = ""
                        self.passwordTextfield.text = ""
                        self.performSegue(withIdentifier: "goToChat", sender: self)
                    }
                }
            }
        }
    }
}  
