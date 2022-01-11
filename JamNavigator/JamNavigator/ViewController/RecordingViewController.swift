import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID

    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var PlayLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        applyEnableDisableDesign(control: playButton, sw: false)
        applyEnableDisableDesign(control: stopButton, sw: false)
        applyEnableDisableDesign(control: uploadButton, sw: false)
    }

    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "segueRecToUpload":
            print("Navi: Rec --> Upload")
            let uploadView = segue.destination as! UploadViewController
            uploadView.userSub = userSub

        default:
            print("Warning: missing segue identifire = \(segue.identifier ?? "nil")")
            break
        }
    }
    
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

        audioRecorder = try! AVAudioRecorder(url: getLocalAudioUrl(), settings: settings)
        audioRecorder.delegate = self
        audioRecorder.record()

        isRecording = true
        recordingLabel.text = "Recoding..."
        applyEnableDisableDesign(control: playButton, sw: false)
        applyEnableDisableDesign(control: stopButton, sw: true)
        applyEnableDisableDesign(control: recordingButton, sw: false)
        applyEnableDisableDesign(control: uploadButton, sw: false)
    }
    
    @IBAction func touchUpInsideStopButton(_ sender: Any) {
        audioRecorder.stop()
        audioPlayer = try! AVAudioPlayer(contentsOf: getLocalAudioUrl())
        audioPlayer.delegate = self
        audioPlayer.stop()
        PlayLabel.text = "Play"
        isPlaying = false
        isRecording = false

//        label.text = "待機中"
//        recordingButton.setTitle("RECORD", for: .normal)
        applyEnableDisableDesign(control: playButton, sw: true)
        applyEnableDisableDesign(control: stopButton, sw: false)
        applyEnableDisableDesign(control: recordingButton, sw: true)
        applyEnableDisableDesign(control: uploadButton, sw: true)
        recordingLabel.text = "Rec"
    }
    
    @IBAction func play(_ sender: Any) {
       
        audioPlayer = try! AVAudioPlayer(contentsOf: getLocalAudioUrl())
        audioPlayer.delegate = self
        audioPlayer.play()

        isPlaying = true

        applyEnableDisableDesign(control: playButton, sw: false)
        applyEnableDisableDesign(control: stopButton, sw: true)
        applyEnableDisableDesign(control: recordingButton, sw: false)
        PlayLabel.text = "Playing..."
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        isPlaying = false
        PlayLabel.text = "Play"
        applyEnableDisableDesign(control: playButton, sw: true)
        applyEnableDisableDesign(control: stopButton, sw: false)
        applyEnableDisableDesign(control: recordingButton, sw: true)

    }
    
}
