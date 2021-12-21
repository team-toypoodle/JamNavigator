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
    @IBOutlet weak var wiwiImage: UIImageView!
    var isPlaying = false

    override func viewDidLoad() {
        
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
