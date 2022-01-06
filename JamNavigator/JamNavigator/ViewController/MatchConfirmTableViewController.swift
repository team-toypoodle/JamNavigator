import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MatchConfirmTableViewController: UITableViewController, AVAudioPlayerDelegate {
    private var matchingFirstItem: Demotape? = nil

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = [Demotape]()
    var userNames = [String]()
    var audioPlayer: AVAudioPlayer!

    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 対象ユーザー一覧を生成する
        listMatchingItems(targetUseId: userSub) {success, matchingItems in
            guard success, let matchingItems = matchingItems else { return }
                
            let unionUsers = matchingItems
                //nilを取り除く
                .compactMap{ $0.instruments }
                //1次元配列にする
                .flatMap{ $0.compactMap{ $0 } }
    
            let users = Array(Set(unionUsers))  // 重複を取り除く
            if users.count >= 2 {   // 自分＋誰かがマッチングレコードある場合は、マッチング要求きている状態
                self.matchingFirstItem = matchingItems[0]
            }
            
            // 対象ユーザーに限定したデモテープ一覧を作成する
            self.listDemotapes(removeUserId: self.userSub, userIds: users) { [weak self] (success, list) in
                guard success, let list = list else { return }
                self?.demotapes = list
                let unionUserNames = list.compactMap{ $0.attributes }.flatMap{ $0.compactMap{ $0 } }.map{ String($0.dropFirst(9)) }
                print("----------", unionUserNames, type(of: unionUserNames))
                self?.userNames = Array(Set(unionUserNames))
//                print("userNames", Array(Set(unionUserNames.dropFirst(9))))
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        tableView.allowsSelection = true
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
        guard let destination = segue.destination as? RequestViewController else {
            fatalError("\(segue.destination) Error")
        }
        destination.demotape = matchingFirstItem
        destination.userSub = userSub
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
            playingRowIndex = IndexPath()
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
        }else{
            let item = demotapes[indexPath.row]
            downloadMusic(key: item.s3StorageKey ?? ""){
                (success, data) in
                if success {
                    if let data = data {
                        DispatchQueue.main.async {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
                            cell.imageView?.image = UIImage(named: "StopButton")
                            self.isPlaying = true
                            self.tableView.reloadData()
                            self.playingRowIndex = indexPath
                            self.audioPlayer = try! AVAudioPlayer(data: data)
                            self.audioPlayer.delegate = self
                            self.audioPlayer.play()
                        }
                    }
                }
            }
        }
    }
    
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
