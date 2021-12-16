//  BackendClient.swift
//  JamNavigator
//  Created by Manabu Tonosaki on 2021/12/16.

import UIKit
import Amplify

extension UIViewController {

    func getTest() {
        let request = RESTRequest(path: "/item")
        Amplify.API.get(request: request) {
            result in
            
            switch result {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print("Success \(str)")
                    
            case .failure(let apiError):
                print("Failed", apiError)
            }
        }
    }
}

