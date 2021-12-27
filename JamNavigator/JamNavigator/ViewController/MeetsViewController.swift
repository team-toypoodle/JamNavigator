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

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var player: AVAudioPlayer? = nil
    var isPlaying = false
    var meetsItem: Demotape? = nil
    
    @IBOutlet weak var dateTimeText: UILabel!
    @IBOutlet weak var locationNameText: UILabel!
    @IBOutlet weak var numberOfPeopleText: UILabel!
    @IBOutlet weak var wiwiImage: UIImageView!
    @IBOutlet weak var locationAddressTextView: UITextView!
    
    override func viewDidLoad() {
        let item = meetsItem!
        dateTimeText.text = "\(item.getValue(key: "DATEFT")!) \(item.getValue(key: "TIMEBOXF")!)〜 \(item.getValue(key: "TIMEBOXS")!) minutes"
        numberOfPeopleText.text = "\(item.getValue(key: "#PEOPLE")!) persons"
        let adid = item.getValue(key: "LOCID")!
        let address = addresses.filter{ $0.id == adid }.first!
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
