import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
        signOutGlobally() {(success, errMessage) in
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.alert(caption: "WARNING", message: errMessage ?? "logoff error", button1: "Cancel")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userName = UserDefaults.standard.string(forKey: "userName") else {return}
        userNameLabel.text = userName
    }
}
