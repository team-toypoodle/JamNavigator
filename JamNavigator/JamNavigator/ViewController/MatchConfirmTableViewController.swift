import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

struct RequestData {
    var isSent: Bool
    var matchingItem: Demotape
    var userId: String
    var userName: String
    var dateString: String
    var locatioin: String
}

class MatchConfirmTableViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func didTapSegmentController(_ sender: UISegmentedControl) {
        self.userNameTableView.reloadData()
    }
    
    @IBOutlet weak var userNameTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var audioPlayer: AVAudioPlayer!
    var sentRequestDatas = [RequestData]()
    var inboxRequestDatas = [RequestData]()
    
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
        sentRequestDatas.removeAll()
        inboxRequestDatas.removeAll()
        listMatchingItems(targetUseId: userSub) {[weak self] success, matchingItems in
            guard success, let matchingItems = matchingItems else { return }
            
            matchingItems.forEach { record in
                guard
                    let instruments = record.instruments,
                    let fromUserId = instruments[0],
                    let toUserId = instruments[1]
                else {
                    return
                }
                let adid = record.getValue(key: "LOCID")!
                let fromUserName = record.getValue(key: "frmUname")!
                if fromUserName == UserDefaults.standard.string(forKey: "userName") {
                    let requestData = RequestData(
                        isSent: true,
                        matchingItem: record,
                        userId: toUserId,
                        userName: record.getValue(key: "toUname_")!,
                        dateString: "\(record.getValue(key: "DATEFT")!)-\(record.getValue(key: "TIMEBOXF")!) 〜 \(record.getValue(key: "TIMEBOXS")!)minutes",
                        locatioin: addresses.filter{ $0.id == adid }.first!.name
                    )
                    self?.sentRequestDatas.append(requestData)
                } else {
                    let requestData = RequestData(
                        isSent: false,
                        matchingItem: record,
                        userId: fromUserId,
                        userName: fromUserName,
                        dateString: "\(record.getValue(key: "DATEFT")!)-\(record.getValue(key: "TIMEBOXF")!) 〜 \(record.getValue(key: "TIMEBOXS")!)minutes",
                        locatioin: addresses.filter{ $0.id == adid }.first!.name
                    )
                    self?.inboxRequestDatas.append(requestData)
                    
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
            destination.requestData = sentRequestDatas[indexPath.row]
        case 1:
            destination.requestData = inboxRequestDatas[indexPath.row]
        default:
            destination.requestData = nil
        }
        destination.userSub = userSub
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentController.selectedSegmentIndex {
        case 0:
            return sentRequestDatas.count
        case 1:
            return inboxRequestDatas.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath)
        var userName: String
        switch segmentController.selectedSegmentIndex {
        case 0:
            userName = sentRequestDatas[indexPath.row].userName
        case 1:
            userName = inboxRequestDatas[indexPath.row].userName
        default:
            userName = ""
        }
        cell.textLabel?.text = userName
        cell.imageView?.image = UIImage(systemName: "person.crop.circle")
        cell.imageView?.tintColor = UIColor.systemGray
        return cell
    }
}
