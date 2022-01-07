import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MatchConfirmTableViewController: UITableViewController, AVAudioPlayerDelegate {
    private var matchingFirstItem: Demotape? = nil

    @IBOutlet var userNameTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var userNames = [String]()
    var audioPlayer: AVAudioPlayer!
    var userIDs = [String]()

    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchMatchingItems), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchMatchingItems()
    }
    
    @objc func fetchMatchingItems() {
        // 対象ユーザー一覧を生成する
        listMatchingItems(targetUseId: userSub) {[weak self] success, matchingItems in
            guard success, let matchingItems = matchingItems else { return }
            
            let unionUsers = matchingItems
                .compactMap{ $0.instruments }
                .flatMap{ $0.compactMap{ $0 } }
            
            self?.userNames = matchingItems.compactMap { record -> String in
                guard
                    let attributes = record.attributes,
                    let userNameAttribute = attributes[6]
                else {
                    return ""
                }
                print("userNameAttribute------", userNameAttribute)
                return String(userNameAttribute.dropFirst(9))
            }
            
            self?.userIDs = Array(Set(unionUsers))  // 重複を取り除く
            // 自分＋誰かがマッチングレコードある場合は、マッチング要求きている状態
            guard let userIDs = self?.userIDs else { return }
            if userIDs.count >= 2 {
                self?.matchingFirstItem = matchingItems[0]
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    // マッチング拒否
    @IBAction func didTapReject(_ sender: Any) {

        guard let matchingFirstItem = matchingFirstItem else {
            print("マッチングアイテムがない状態で、Rejectボタンが押されたので無視する")
            return
        }
        // ステータスを更新する
        updateMatchingStatus(from: matchingFirstItem, status: "DONE"){
            success, newItem in
            
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
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
        destination.userName = userNames[indexPath.row]
        destination.userSub = userSub
        destination.userID = userIDs[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath)
        let userName = userNames[indexPath.row]
        
        cell.textLabel?.text = userName
//        if indexPath == playingRowIndex{
//            cell.imageView?.image = UIImage(named: "StopButton")
//        }else{
//            cell.imageView?.image = UIImage(named: "PlayButton")
//        }
        print("userNames--------", userNames)
        return cell
    }
    
    var playingRowIndex: IndexPath = IndexPath()
    var isPlaying = false
    // 選択したときのイベント
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if isPlaying {
//            audioPlayer.stop()
//            isPlaying = false
//            playingRowIndex = IndexPath()
//            tableView.deselectRow(at: indexPath, animated: true)
//            tableView.reloadData()
//        }else{
//            let item = demotapes[indexPath.row]
//            downloadMusic(key: item.s3StorageKey ?? ""){
//                (success, data) in
//                if success {
//                    if let data = data {
//                        DispatchQueue.main.async {
//                            let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
//                            cell.imageView?.image = UIImage(named: "StopButton")
//                            self.isPlaying = true
//                            self.tableView.reloadData()
//                            self.playingRowIndex = indexPath
//                            self.audioPlayer = try! AVAudioPlayer(data: data)
//                            self.audioPlayer.delegate = self
//                            self.audioPlayer.play()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingRowIndex = IndexPath()
        tableView.reloadData()
        isPlaying = false
    }
    
    // マッチングOK
    @IBAction func didTapMatch(_ sender: Any) {
        performSegue(withIdentifier: "segueConfirmToRequest", sender: self)
    }
    
}
