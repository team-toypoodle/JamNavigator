import UIKit

import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class RequestDemotapeTableViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func didTapRejectButton(_ sender: Any) {
           // ステータスを更新する
        guard let matchingItem = requestData?.matchingItem else { return }
        updateMatchingStatus(from: matchingItem, status: "Rejected"){ success, newItem in
            guard success else { return }
            DispatchQueue.main.async {
                self.alert(caption: "message", message: "Matching request has been rejected!", button1: "OK") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    @IBAction func didTapConfirmButton(_ sender: Any) {
        setMatchingOkState() { success in
            print("success", success)
            guard success else { return }
            DispatchQueue.main.async {
                print("alert")
                self.alert(caption: "message", message: "Matching request has been confirmed!", button1: "OK") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var rejectButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var demotapesTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = [Demotape]()
    var audioPlayer: AVAudioPlayer!
    var requestData: RequestData?
    var playingRowIndex: IndexPath = IndexPath()
    var isPlaying = false

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
        if reqData.isSent {
            confirmButton.isHidden = true
            rejectButton.setTitle("❌pull back", for: .normal)
            rejectButtonWidth.constant = 315
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
        cell.detailTextLabel?.text = Array(demotape.instruments?.map{$0!} ?? []).joined(separator: ", ") + "   " + Array(demotape.genres?.map{$0!} ?? []).joined(separator: ", ")
        if indexPath == playingRowIndex {
            cell.imageView?.image = UIImage(named: "StopButton")
        }else{
            cell.imageView?.image = UIImage(named: "PlayButton")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
            playingRowIndex = IndexPath()
            demotapesTableView.deselectRow(at: indexPath, animated: true)
            demotapesTableView.reloadData()
        } else {
            let item = demotapes[indexPath.row]
            downloadMusic(key: item.s3StorageKey ?? "") {
                (success, data) in
                guard success, let data = data else { return }
                DispatchQueue.main.async {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "demotapeCell", for: indexPath)
                    cell.imageView?.image = UIImage(named: "StopButton")
                    self.isPlaying = true
                    self.demotapesTableView.reloadData()
                    self.playingRowIndex = indexPath
                    self.audioPlayer = try! AVAudioPlayer(data: data)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()
                }
            }
        }
    }
    
    private func setMatchingOkState(callback:  ((Bool) -> Void)? = nil ) {

        guard let matchingItem = requestData?.matchingItem else {
            fatalError("demotapeが nilなのに、マッチング成立できるのはおかしいので停止")
        }
        callback?(true)
        if matchingItem.userId == "MATCHING" {
        //GraphQL（データベース）にDemotapeオブジェクトを利用して、マッチング情報を新規作成・登録する
        updateMatchingStatus(from: matchingItem, status: "WAITING_THE_REAL")
        }
    }
}

