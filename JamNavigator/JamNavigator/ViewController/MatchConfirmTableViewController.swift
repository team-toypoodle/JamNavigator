import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MatchConfirmTableViewController: UITableViewController, AVAudioPlayerDelegate {
    private var matchingFirstItem: Demotape? = nil  // TODO: 複数同時マッチング非対応のため、最初のマッチングレコードだけ処理する

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = Array<Demotape>()
    var audioPlayer: AVAudioPlayer!

    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 対象ユーザー一覧を生成する
        listMatchingItems(targetUseId: userSub) {
            success, matchingItems in
            if success, let matchingItems = matchingItems {
                
                let unionUsers = matchingItems
                    .compactMap{ $0.instruments }
                    .flatMap{ $0.compactMap{ $0 } }
                let users = Array(Set(unionUsers))  // 重複を取り除く
                if users.count >= 2 {   // 自分＋誰かがマッチングレコードある場合は、マッチング要求きている状態
                    self.matchingFirstItem = matchingItems[0]
                }
                
                // 対象ユーザーに限定したデモテープ一覧を作成する
                self.listDemotapes(removeUserId: self.userSub, userIds: users) {
                    (success, list) in
                    if success {
                        if let list = list{
                            self.demotapes = list
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
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
        return demotapes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
        let item = demotapes[indexPath.row]
        
        cell.textLabel?.text = item.name
        if indexPath == playingRowIndex{
            cell.imageView?.image = UIImage(named: "StopButton")
        }else{
            cell.imageView?.image = UIImage(named: "PlayButton")
        }
        
        cell.detailTextLabel?.text = Array(item.instruments?.map{$0!} ?? []).joined(separator: ", ") + "   " + Array(item.genres?.map{$0!} ?? []).joined(separator: ", ")
        
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
