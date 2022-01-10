import UIKit
import AVFoundation

class AccountViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    var playingRowIndex: IndexPath = IndexPath()
    var demotapes = Array<Demotape>()
    var audioPlayer: AVAudioPlayer!
    var isPlaying = false
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
        signOutGlobally() {(success, errMessage) in
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.alert(caption: "WARNING", message: errMessage ?? "logoff error", button1: "Cancel")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listDemotapes() {
            mayBeList in
            guard let list = mayBeList else { return }
            self.demotapes = list.filter{ tape in
                guard let username = tape.getValue(key: "userName") else { return false }
                return username == UserDefaults.standard.string(forKey: "userName")
            }
            DispatchQueue.main.async {
                self.tableview.reloadData()
                self.tableview.allowsSelection = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userName = UserDefaults.standard.string(forKey: "userName") else {return}
        userNameLabel.text = userName
    }
}

extension AccountViewController: UITableViewDataSource,UITableViewDelegate, AVAudioPlayerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demotapes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = demotapes[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = Array(item.instruments?.map{$0!} ?? []).joined(separator: ", ") + "   " + Array(item.genres?.map{$0!} ?? []).joined(separator: ", ")
        if indexPath == playingRowIndex{
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
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
        } else {
            let item = demotapes[indexPath.row]
            downloadMusic(key: item.s3StorageKey ?? "") {
                (success, data) in
                guard success, let data = data else { return }
                DispatchQueue.main.async {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    cell.imageView?.image = UIImage(named: "StopButton")
                    self.isPlaying = true
                    self.tableview.reloadData()
                    self.playingRowIndex = indexPath
                    self.audioPlayer = try! AVAudioPlayer(data: data)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()
                }
            }
        }
    }
}
