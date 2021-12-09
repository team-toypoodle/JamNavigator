//
//  RecordingViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/09.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playButton.alpha = 0.25
        playButton.isEnabled = false
        stopButton.alpha = 0.25
        stopButton.isEnabled = false
    }

    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var PlayLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    @IBAction func touchUpInsideRecButton(_ sender: Any) {

        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord)
        try! session.setActive(true)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try! AVAudioRecorder(url: getURL(), settings: settings)
        audioRecorder.delegate = self
        audioRecorder.record()

        isRecording = true

        recordingLabel.text = "Recoding..."
        
//        label.text = "録音中"
//        recordingButton.setTitle("STOP", for: .normal)
        playButton.alpha = 0.25
        playButton.isEnabled = false
        stopButton.alpha = 1.0
        stopButton.isEnabled = true
        recordingButton.isEnabled = false
        
    }
    
    @IBAction func touchUpInsideStopButton(_ sender: Any) {
        audioRecorder.stop()
        isRecording = false

//        label.text = "待機中"
//        recordingButton.setTitle("RECORD", for: .normal)
        playButton.alpha = 1.0
        playButton.isEnabled = true
        stopButton.alpha = 0.25
        stopButton.isEnabled = false
        
        recordingLabel.text = "Rec"
    }
    
    func getURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let url = docsDirect.appendingPathComponent("recording.m4a")
        return url
    }
    
    @IBAction func play(_ sender: Any) {
       
        audioPlayer = try! AVAudioPlayer(contentsOf: getURL())
        audioPlayer.delegate = self
        audioPlayer.play()

        isPlaying = true

//                label.text = "再生中"
//            playButton.setTitle("STOP", for: .normal)
        recordingButton.alpha = 0.25
        recordingButton.isEnabled = false
        PlayLabel.text = "Playing..."

    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        isPlaying = false
        PlayLabel.text = "Play"
        recordingButton.alpha = 1.0
        recordingButton.isEnabled = true
    }
    
}
