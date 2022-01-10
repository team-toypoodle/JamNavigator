import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MatchConfirmTableViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func didTapSegmentController(_ sender: UISegmentedControl) {
        self.userNameTableView.reloadData()
    }
    
    @IBOutlet weak var userNameTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var audioPlayer: AVAudioPlayer!
    var sentuserIDs = [String]()
    var inboxuserIDs = [String]()
    var sentUserNames = [String]()
    var inboxUserNames = [String]()
    
    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchMatchingItems), for: UIControl.Event.valueChanged)
        self.userNameTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchMatchingItems()
    }
    
    @objc func fetchMatchingItems() {
        // 対象ユーザー一覧を生成する
        sentUserNames.removeAll()
        inboxUserNames.removeAll()
        listMatchingItems(targetUseId: userSub) {[weak self] success, matchingItems in
            guard success, let matchingItems = matchingItems else { return }
            
            matchingItems.forEach { record in
                guard
                    let attributes = record.attributes,
                    let userNameAttribute = attributes[6],
                    let instruments = record.instruments,
                    let fromUserId = instruments[0],
                    let toUserId = instruments[1]
                else {
                    return
                }
                let username = String(userNameAttribute.dropFirst(9))
                if username == UserDefaults.standard.string(forKey: "userName") {
                    self?.sentUserNames.append(username)
                    self?.sentuserIDs.append(toUserId)
                } else {
                    self?.inboxUserNames.append(username)
                    self?.inboxuserIDs.append(fromUserId)
                }
            }
            DispatchQueue.main.async {
                self?.userNameTableView.reloadData()
                self?.userNameTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segueConfirmToRequest
        guard
            let destination = segue.destination as? RequestDemotapeTableViewController,
            let indexPath = userNameTableView.indexPathForSelectedRow
        else { fatalError("\(segue.destination) Error") }
        switch segmentController.selectedSegmentIndex {
        case 0:
            destination.userName = sentUserNames[indexPath.row]
            destination.userID = sentuserIDs[indexPath.row]
        case 1:
            destination.userName = inboxUserNames[indexPath.row]
            destination.userID = inboxuserIDs[indexPath.row]
        default:
            destination.userName = ""
        }
        destination.userSub = userSub
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentController.selectedSegmentIndex {
        case 0:
            return sentUserNames.count
        case 1:
            return inboxUserNames.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath)
        var userName: String
        switch segmentController.selectedSegmentIndex {
        case 0:
            userName = sentUserNames[indexPath.row]
        case 1:
            userName = inboxUserNames[indexPath.row]
        default:
            userName = ""
        }
        cell.textLabel?.text = userName
        return cell
    }
}
