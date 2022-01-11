import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MeetsTableViewController :UITableViewController, AVAudioPlayerDelegate{

    @IBOutlet var meetsTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var meetsItems = Array<Demotape>()
    var playingRowIndex: IndexPath = IndexPath()
    var isPlaying = false
    var player: AVAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetsItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetsCell", for: indexPath)
        cell.subviews.forEach { subview in
            if type(of: subview) == type(of: UIButton()) {
                subview.removeFromSuperview()
            }
        }
        
        let item = meetsItems[indexPath.row]
        var fromUserName = item.getValue(key: "frmUname")!
        if fromUserName == UserDefaults.standard.string(forKey: "userName") {
            fromUserName = item.getValue(key: "toUname_")!
        }
        cell.textLabel?.text = "Jam with \(fromUserName) \(item.getValue(key: "DATEFT__")!)"
        cell.imageView?.image = UIImage(systemName: "speaker.wave.2.fill")
        cell.imageView?.tintColor = UIColor.black
        
        if indexPath == playingRowIndex{
            cell.imageView?.tintColor = UIColor.systemBlue
        }else{
            cell.imageView?.tintColor = UIColor.black
        }
        
        let actionButton = UIButton(frame: CGRect(x: cell.frame.width - 50, y: 0, width: 50, height: cell.frame.height))
        actionButton.tag = indexPath.row
        actionButton.addTarget(self, action: #selector(didTapActionButton(_:)), for: .touchUpInside)
        actionButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        cell.addSubview(actionButton)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPlaying {
            isPlaying = false
            player?.stop()
            return
        }
        
        if let sound = NSDataAsset(name: "call01") {
            let data = sound.data
            player = try? AVAudioPlayer(data: data)
            player?.delegate = self
            player?.play() // → これで音が鳴る
            isPlaying = true
            playingRowIndex = indexPath
            tableView.reloadData()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playingRowIndex = IndexPath()
        tableView.reloadData()
    }
    
    @objc func didTapActionButton(_ sender: UIButton) {
        let item = meetsItems[sender.tag]
        var fromUserName = item.getValue(key: "frmUname")!
        if fromUserName == UserDefaults.standard.string(forKey: "userName") {
            fromUserName = item.getValue(key: "toUname_")!
        }
        let eventTitle = "Jam with \(fromUserName)"
        let dateString = "\(item.getValue(key: "DATEFT")!)-\(item.getValue(key: "TIMEBOXF")!)"
        let date = DateUtils.dateFromString(string: dateString, format: "yyyy-MM-dd-hh:mm")
        let adid = item.getValue(key: "LOCID")!
        let address = addresses.filter{ $0.id == adid }.first!
        let shareItem: [Any] = [eventTitle, date - (9 * 60 * 60), date - (9 * 60 * 60) + (60 * 30), address.address]
        let VC = UIActivityViewController(activityItems: shareItem, applicationActivities: [CalenderActivity()])
        present(VC, animated: true, completion: nil)
    }
}
