//
//  ViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit
import Amplify
import AWSPluginsCore

class TopViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchCurrentAuthSession()   // 自動認証を トライしてみる
        
        //以下は、サインアップの手順サンプル
        //signUp(username: "tonosaki", password: "tonotono", email: "manabu@tomarika.com") // received 568764
        //confirmSignUp(for: "tonosaki", with: "568764")
        
        //以下は、ログインの手順サンプル
        //signIn(username: "tonosaki", password: "tonotono")
    }
    
    // 自動認証機能
    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession {
            result in
            
            do {
                let session = try result.get()
                
                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    print("User sub - \(usersub)")    // as User backend ID
                    //let identityId = try identityProvider.getIdentityId().get()
                    //print("Identity id \(identityId)")
                }
                
                // Get AWS credentials
                //if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                //    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                //    print("Access key - \(credentials.accessKey) ")
                //}
                
                // Get cognito user pool token
                //if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                //    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                //    print("Id token - \(tokens.idToken) ")
                //}
                
            } catch {
                print("Fetch auth session failed with error - \(error)")
            }        }
    }
    
    // ログイン
    // username: signUpでしていしたものと同じ
    // password:     同上
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) {
            result in
            
            switch result {
            case .success:
                print("Sign in succeeded")
                
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    // サインアップ（新しいユーザーアカウントを AWS Cognitoに作る）関数
    // username: ユーザー名（半角英数字で。例：tonosaki）
    // password: ログイン用の新しいパスワード
    // email: 確認コードを受信するための活きているメアド  例：myemail@mail.domain.co.jp
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) {
            result in
            
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                } else {
                    print("SignUp Complete")
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    
    // サインアップ signUp(usename, email)実行後、指定emailに届いた確認コードを AWS Cognitoに知らせる関数
    // username: signUpで指定したものと同じ
    // confirmationCode: emailで受信した確認コード
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) {
            result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
}

