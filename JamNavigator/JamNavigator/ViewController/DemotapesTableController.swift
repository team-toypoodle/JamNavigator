import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

struct Instrument{
    let name:String
    var isActive:Bool = true
}

struct FilterContents{
    var all = [
        Instrument(name:"Guitar"),
        Instrument(name:"Piano"),
        Instrument(name:"Violin"),
        Instrument(name:"Other")
    ]
    func getActiveContents() -> [String?] {
        let activeContents = all.filter { $0.isActive }
        return activeContents.map{ $0.name }
    }
}

protocol FilterDelegate: AnyObject {
    func applyFilter(filter:FilterContents)
}

class DemotapesTableViewClass :UITableViewController,AVAudioPlayerDelegate{

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var demotapes = Array<Demotape>()
    var activeDemotapes = Array<Demotape>()
    var audioPlayer: AVAudioPlayer!
    var selectedIndexPath: Int? = nil
    var activeFilter = FilterContents()
    var playingRowIndex: IndexPath = IndexPath()
    var isPlaying = false
    weak var delegate: BadgeControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchDemotapes), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listDemotapes() {
            mayBeList in
            guard let list = mayBeList else { return }
            self.demotapes = list
            self.activeDemotapes = self.demotapes
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.allowsSelection = true
                self.delegate?.updateBadge()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toRequest":
            guard let destination = segue.destination as? RequestViewController else { return }
            guard let selectedIndexPath = selectedIndexPath else { return }
            destination.demotape = demotapes[selectedIndexPath]
            destination.userSub = userSub
        case "toFilter":
            guard
                let filterTableViewNavVC = segue.destination as? UINavigationController,
                let destination = filterTableViewNavVC.topViewController as? FilterTableViewController
            else { return }
            destination.delegate = self
            destination.activeFilter = activeFilter
        default :
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeDemotapes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
        cell.subviews.forEach { subview in
            if type(of: subview) == type(of: UIButton()) {
                subview.removeFromSuperview()
            }
        }
        
        let item = activeDemotapes[indexPath.row]
    
        let reqestButton = UIButton(frame: CGRect(x: cell.frame.width - 50, y: 0, width: 50, height: cell.frame.height))
        reqestButton.tag = indexPath.row
        reqestButton.addTarget(self, action: #selector(didTapRequestButton(_:)), for: .touchUpInside)
        reqestButton.setImage(UIImage(systemName: "heart.text.square"), for: .normal)
        cell.addSubview(reqestButton)
        
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
            let item = activeDemotapes[indexPath.row]
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
    
    @objc func didTapRequestButton(_ sender: UIButton) {
        self.selectedIndexPath = sender.tag
        self.performSegue(withIdentifier: "toRequest", sender: self)
    }
    
    @objc func fetchDemotapes() {
        listDemotapes() {[weak self] mayBeList in
            guard let list = mayBeList else { return }
            self?.demotapes = list
            guard let demotapes = self?.demotapes else { return }
            self?.activeDemotapes = demotapes
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.allowsSelection = true
                self?.tableView.refreshControl?.endRefreshing()
                self?.delegate?.updateBadge()
            }
        }
    }
}

extension DemotapesTableViewClass: FilterDelegate {
    func applyFilter(filter:FilterContents) {
        activeFilter = filter
        let activeList = activeFilter.getActiveContents()
        activeDemotapes = demotapes.filter { demotape in
            guard let instrumentList = demotape.instruments
                else { return false }
            var isActiveList = [Bool]()
            activeList.forEach({
                isActiveList.append(instrumentList.contains($0))
            })
            return isActiveList.contains(_:true)
        }
        tableView.reloadData()
    }
}
