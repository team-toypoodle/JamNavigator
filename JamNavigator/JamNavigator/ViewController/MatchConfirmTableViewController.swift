import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MatchConfirmTableViewController: UITableViewController, AVAudioPlayerDelegate {
    private var matchingFirstItem: Demotape? = nil

    @IBOutlet var userNameTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = [Demotape]()
    var userNames = [String]()
    var audioPlayer: AVAudioPlayer!
    var userIDs = [String]()

    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 対象ユーザー一覧を生成する
        listMatchingItems(targetUseId: userSub) {[weak self] success, matchingItems in
            guard success, let matchingItems = matchingItems else { return }
                
            let unionUsers = matchingItems
                //nilを取り除く
                .compactMap{ $0.instruments }
                //1次元配列にする
                .flatMap{ $0.compactMap{ $0 } }
    
            self?.userIDs = Array(Set(unionUsers))  // 重複を取り除く
            // 自分＋誰かがマッチングレコードある場合は、マッチング要求きている状態
            guard let userIDs = self?.userIDs else { return }
            print("userIDs-------", userIDs)
            if userIDs.count >= 2 {
                self?.matchingFirstItem = matchingItems[0]
            }
            
            // 対象ユーザーに限定したデモテープ一覧を作成する
            guard let userSub = self?.userSub else { return }
            self?.listDemotapes(removeUserId: userSub, userIds: userIDs) { [weak self] (success, list) in
                guard success, let list = list else { return }
                self?.demotapes = list
                let unionUserNames = list.compactMap{ $0.attributes }.flatMap{ $0.compactMap{ $0 } }.map{ String($0.dropFirst(9)) }
                print("----------", unionUserNames, type(of: unionUserNames))
                self?.userNames = Array(Set(unionUserNames))
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
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
        print("prepare-----------")
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
