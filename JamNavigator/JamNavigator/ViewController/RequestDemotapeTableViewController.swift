import UIKit

import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class RequestDemotapeTableViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func didTapRejectButton(_ sender: Any) {
    }
    @IBAction func didTapConfirmButton(_ sender: Any) {
    }
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var demotapesTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = [Demotape]()
    var audioPlayer: AVAudioPlayer!
    
    var requestData: RequestData?

    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 対象ユーザーに限定したデモテープ一覧を作成する
        guard let reqData = requestData else { return }
        self.listDemotapes(removeUserId: self.userSub, userIds: [reqData.userId]) { [weak self] (success, list) in
            guard success, let list = list else { return }
            self?.demotapes = list
            DispatchQueue.main.async {
                self?.demotapesTableView.reloadData()
            }
        }
        title = reqData.userName
        whenLabel.text = reqData.dateString
        whereLabel.text = reqData.locatioin
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demotapes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "demotapeCell", for: indexPath)
        let demotape = demotapes[indexPath.row]
        cell.textLabel?.text = demotape.name
        return cell
    }
}

