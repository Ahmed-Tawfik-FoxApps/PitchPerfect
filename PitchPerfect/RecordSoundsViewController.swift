//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Ahmed Tawfik on 8/29/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    let audioSession = AVAudioSession.sharedInstance()
    
    enum RecordingState { case recording, notRecording }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(.notRecording)
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        switch audioSession.recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            startRecording()
        case AVAudioSessionRecordPermission.denied:
            showAlert(Alerts.RecordingDisabledTitle, message: Alerts.RecordingDisabledMessage)
        case AVAudioSessionRecordPermission.undetermined:
            audioSession.requestRecordPermission({ (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.startRecording()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(Alerts.RecordingDisabledTitle, message: Alerts.RecordingDisabledMessage)
                    }
                }
            })
        default:
            break
        }
    }
    
    private func startRecording() {
        configureUI(.recording)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        configureUI(.notRecording)
        
        audioRecorder.stop()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
    
    private func configureUI(_ recordingState: RecordingState) {
        switch(recordingState) {
        case .recording:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            recordingLabel.text = "Recording in Progress"
        case .notRecording:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            recordingLabel.text = "Tap to Record"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}
