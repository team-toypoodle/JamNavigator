import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

protocol FilterDelegate: AnyObject {
    func applyFilter(filter:[String])
}

class DemotapesTableViewClass :UITableViewController,AVAudioPlayerDelegate{

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = Array<Demotape>()
    var activeDemotapes = Array<Demotape>()
    var audioPlayer: AVAudioPlayer!
    var selectedIndexPath: IndexPath? = nil
    var activeFilter = [
        "guiter",
        "piano",
        "violin",
        "other"
    ]
    var playingRowIndex: IndexPath = IndexPath()
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listDemotapes() {
            mayBeList in
            guard let list = mayBeList else { return }
            self.demotapes = list
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.allowsSelection = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toRequest":
            guard let destination = segue.destination as? RequestViewController else { return }
            guard let selectedIndexPath = selectedIndexPath else { return }
            destination.demotape = demotapes[selectedIndexPath.row]
            destination.userSub = userSub
        case "toFilter":
            guard
                let filterTableViewNavVC = segue.destination as? UINavigationController,
                let destination = filterTableViewNavVC.topViewController as? FilterTableViewController
            else { return }
            destination.delegate = self
        default :
            return
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let request = UIContextualAction(style: .normal, title: "Match", handler: {
            (action: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "toRequest", sender: self)
            
        })
        request.backgroundColor = .darkGray
        return UISwipeActionsConfiguration(actions: [request])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(activeFilter)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
            playingRowIndex = IndexPath()
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
        } else {
            let item = demotapes[indexPath.row]
            downloadMusic(key: item.s3StorageKey ?? "") {
                (success, data) in
                guard success, let data = data else { return }
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingRowIndex = IndexPath()
        tableView.reloadData()
        isPlaying = false
    }
}

extension DemotapesTableViewClass: FilterDelegate {
    func applyFilter(filter:[String]) {
        print("動いた")
        activeFilter = filter
        tableView.reloadData()
    }
}
