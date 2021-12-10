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
    @IBOutlet weak var buttonSignup: UIButton!
    @IBOutlet weak var buttonCancelSignup: UIButton!

    @IBOutlet weak var labelConfirm: UILabel!
    @IBOutlet weak var textFieldConfirm: UITextField!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var buttonCancelConfirm: UIButton!

    override func viewDidLoad() {
        textFieldUsername.text = username
        textFieldPassword.text = password
        
        _ = [labelConfirm, textFieldConfirm, buttonConfirm, buttonCancelConfirm].map{
            $0.isHidden = true
        }
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
                DispatchQueue.main.async {
                    // 確認コードを入力するコントロールを有効化
                    _ = [self.labelConfirm, self.textFieldConfirm, self.buttonConfirm, self.buttonCancelConfirm].map{
                        $0.isHidden = false
                    }
                    // サインアップ情報（アカウント、PW、email）を非活性に
                    _ = [self.textFieldUsername, self.textFieldPassword, self.textFieldEmail, self.buttonSignup].map {
                        $0?.isEnabled = false
                        $0?.alpha = 0.25
                    }
                    self.buttonCancelSignup.isHidden = true
                }
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
    
    @IBAction func didTapCancelConfirm(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        guard let code = textFieldConfirm.text else {
            return
        }
        if code.count < 4 || code.count > 12 {
            return
        }
        confirmSignUp(for: textFieldUsername.text!, with: code) {
            (success, errMessage) in
            
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.alert(caption: "WARNING", message: errMessage ?? "unknown error", button1: "OK")
            }
        }
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
