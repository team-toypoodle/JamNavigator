//
//  AwsCognitoHandler.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.
//

import UIKit
import Amplify
import AWSPluginsCore

extension SignupViewController {
    
    enum SignupStatus {
        case Err
        case NA
        case ConfirmingCode
        case Done
    }
    
    // サインアップ（新しいユーザーアカウントを AWS Cognitoに作る）関数
    // username: ユーザー名（半角英数字で。例：tonosaki）
    // password: ログイン用の新しいパスワード
    // email: 確認コードを受信するための活きているメアド  例：myemail@mail.domain.co.jp
    func signUp(username: String, password: String, email: String, callback: @escaping (SignupStatus, String?) -> Void) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) {
            result in
            
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    let mes = String(describing: deliveryDetails)
                    print("Delivery details \(mes)")
                    callback(.ConfirmingCode, mes)
                } else {
                    print("SignUp Complete")
                    callback(.Done, nil)
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                callback(.Err, error.errorDescription)
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

extension TopViewController {
    // 自動認証機能
    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession {
            result in
            
            do {
                let session = try result.get()
                
                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    self.userSub = try identityProvider.getUserSub().get()
                    print("User sub - \(self.userSub)")    // as User backend ID
                    //let identityId = try identityProvider.getIdentityId().get()
                    //print("Identity id \(identityId)")
                    
                    // Menu用の Viewに画面遷移
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "segueTopToMenu", sender: self)
                    }
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
            }
        }
    }
    
    // ログイン
    // username: signUpでしていしたものと同じ
    // password:     同上
    func signIn(username: String, password: String, callback: @escaping (Bool, String?) -> Void ) {
        Amplify.Auth.signIn(username: username, password: password) {
            result in
            
            switch result {
            case .success:
                print("Sign in succeeded")
                callback(true, nil)
                
            case .failure(let error):
                print("Sign in failed \(error)")
                callback(false, error.errorDescription)
            }
        }
    }
    
    // サインアウト（PC内で）
    func signOutLocally() {
        Amplify.Auth.signOut() {
            result in
            
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    // サインアウト（クラウドから全体）
    func signOutGlobally() {
        Amplify.Auth.signOut(options: .init(globalSignOut: true)) {
            result in
            
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
}
