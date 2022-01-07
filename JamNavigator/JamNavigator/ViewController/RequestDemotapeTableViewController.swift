import UIKit

import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class RequestDemotapeTableViewController: UITableViewController, AVAudioPlayerDelegate {
    

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = [Demotape]()
    var audioPlayer: AVAudioPlayer!
    
    var userName:String?
    var userID:String?

    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 対象ユーザーに限定したデモテープ一覧を作成する
        guard let userID = self.userID else { return }
        self.listDemotapes(removeUserId: self.userSub, userIds: [userID]) { [weak self] (success, list) in
            guard success, let list = list else { return }
            self?.demotapes = list
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        title = userName
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demotapes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "demotapeCell", for: indexPath)
        let demotape = demotapes[indexPath.row]
        cell.textLabel?.text = demotape.name
        return cell
    }
}

