//
//  UploadViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/09.
//

import UIKit

class UploadViewController: UIViewController,UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.]
        titleText.delegate = self
        commentText.delegate = self
    }

    @IBAction func uploadButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    @IBAction func tapwhitespace(_ sender: UITapGestureRecognizer) {
        titleText.resignFirstResponder()
        commentText.resignFirstResponder()
    }
    
}
