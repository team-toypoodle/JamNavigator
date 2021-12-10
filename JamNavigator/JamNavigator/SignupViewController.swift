//
//  SignupViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.
//

import UIKit

class SignupViewController: UIViewController {
    var username: String = ""
    var password: String = ""
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    
    
    override func viewDidLoad() {
        textFieldUsername.text = username
        textFieldPassword.text = password
    }
    
    
    @IBAction func didTapDoSignup(_ sender: Any) {
        if checkSignupFields() == false {
            alert(caption: "NOTE", message: "Please confirm signup information", button1: "OK")
            return
        }
        let username = textFieldUsername.text!
        let password = textFieldPassword.text!
        let email = textFieldEmail.text!
        signUp(username: username, password: password, email: email){
            (status, message) in
            
            switch status {
            case .Done:
                self.dismiss(animated: true, completion: nil)
            case .ConfirmingCode:
                break
            case .Err:
                self.alert(caption: "WARNING", message: message ?? "Signup errror", button1: "Cancel")
                break
            default:
                break
            }
        }
    }
    
    @IBAction func didTapCancelSignup(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkSignupFields() -> Bool {
        guard let username = textFieldUsername.text else {  // textFieldUsernameが入力されてなかったら return
            print("usename = nil is not accepted")
            return false
        }
        guard let password = textFieldPassword.text else {  // textFieldPasswordが入力されてなかったら return
            print("password = nil is not accepted")
            return false
        }
        guard let email = textFieldEmail.text else {  // textFieldEmailが入力されてなかったら return
            print("email = nil is not accepted")
            return false
        }
        if username.count < 2 || password.count < 2 {       // 入力文字が短すぎたら return
            print( "Expecting a little longer account information" )
            return false
        }
        if username.count > 120 || password.count > 120 || email.count > 120 {   // 入力文字が長すぎたら return
            print( "Expecting a little shorter account information" )
            return false
        }
        return true
    }

}
