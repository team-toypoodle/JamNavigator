//
//  MeetsViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/21.
//

import Foundation
import UIKit
import AVFAudio

class MeetsViewController : UIViewController, AVAudioPlayerDelegate {

    var player: AVAudioPlayer? = nil
    var isPlaying = false
    var meetsItem: Demotape?
    var shareItem = [Any]()
    
    @IBOutlet weak var dateTimeText: UILabel!
    @IBOutlet weak var locationNameText: UILabel!
    @IBOutlet weak var wiwiImage: UIImageView!
    @IBOutlet weak var locationAddressTextView: UITextView!
    
    @IBAction func didTapActionButton(_ sender: Any) {
        let VC = UIActivityViewController(activityItems: shareItem, applicationActivities: [CalenderActivity()])
        present(VC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        guard let item = meetsItem else { return }
        let dateString = item.getValue(key: "DATEFT")! + "-" + item.getValue(key: "TIMEBOXF")!
        let date = DateUtils.dateFromString(string: dateString, format: "yyyy-MM-dd-hh:mm")
        let adid = item.getValue(key: "LOCID")!
        let address = addresses.filter{ $0.id == adid }.first!
        shareItem = ["JamNaviMeeting", date - (9 * 60 * 60), date - (9 * 60 * 60) + (60 * 30), address.address]
        dateTimeText.text = "\(item.getValue(key: "DATEFT")!) \(item.getValue(key: "TIMEBOXF")!)〜 \(item.getValue(key: "TIMEBOXS")!) minutes"
        locationNameText.text = address.name
        locationAddressTextView.text = address.address
    }
    
    @IBAction func didTapPlayMatchingSoundButton(_ sender: Any) {
        if isPlaying {
            wiwiImage.isHidden = true
            isPlaying = false
            player?.stop()
            return
        }
        
        if let sound = NSDataAsset(name: "call01") {
            let data = sound.data
            player = try? AVAudioPlayer(data: data)
            player?.delegate = self
            player?.play() // → これで音が鳴る
            wiwiImage.isHidden = false
            isPlaying = true
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        wiwiImage.isHidden = true
        isPlaying = false
    }
}
