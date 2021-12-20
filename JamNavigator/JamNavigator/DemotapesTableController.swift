//
//  DemotapesTableController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation


class DemotapesTableViewClass : DemotapesTableViewBase {

    override func viewDidLoad() {
        super.viewDidLoad()

        listDemotapes(){
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
        tableView.allowsSelection = true
    }
}

class DemotapesTableViewBase : UITableViewController, AVAudioPlayerDelegate {
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes: Array<Demotape> = []
    var audioPlayer: AVAudioPlayer!

    var selectedIndexPath: IndexPath? = nil
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let request = UIContextualAction(style: .normal, title: "Match", handler: {
            (action: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "toRequest", sender: self)
            
        })
        request.backgroundColor = .darkGray
        return UISwipeActionsConfiguration(actions: [request])
    }
    
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "toRequest":
                guard let destination = segue.destination as? RequestViewController else {
                    fatalError("\(segue.destination) Error")
                }
                guard let selectedIndexPath = selectedIndexPath else {
                    return
                }
                destination.demotape = demotapes[selectedIndexPath.row]
                destination.userSub = userSub
        default:
            print("Warning: missing segue identifire = \(segue.identifier ?? "nil")")
            break
        }
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

}
