//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Junior on 5/24/23.
//  Copyright © 2023 empresa. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!
    
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer:Timer?
    var cont = 0
    var tiempoFinal: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        volumenSlider.addTarget(self, action: #selector(volumenCambiado(_:)), for: .valueChanged)

    }
    
    @objc func volumenCambiado(_ sender: UISlider){
        reproducirAudio?.volume = sender.value
    }
    
    
    @IBAction func volumenTapped(_ sender: Any) {
    }
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            timer?.invalidate()
            
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actTemp), userInfo: nil, repeats: true)
            
        }
    }
    @objc func actTemp() {
        cont += 1
        let minutos = cont / 60
        let segundos = cont % 60
        
        tiempoFinal = String(format: "%02d:%02d", minutos, segundos)
        
        tiempoLabel.text = tiempoFinal
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
           try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
           reproducirAudio!.play()
            reproducirAudio?.volume = volumenSlider.value
           print("Reproduciendo")
        }catch{}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf:audioURL!)! as Data
        grabacion.tiempo = tiempoFinal
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    func configurarGrabacion(){
       do{
           let session = AVAudioSession.sharedInstance()
           try session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
           try session.overrideOutputAudioPort(.speaker)
           try session.setActive(true)


           let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
           let pathComponents = [basePath,"audio.m4a"]
           audioURL = NSURL.fileURL(withPathComponents: pathComponents)!


           print("*****************")
           print(audioURL!)
           print("*****************")


           var settings:[String:AnyObject] = [:]
           settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
           settings[AVSampleRateKey] = 44100.0 as AnyObject?
           settings[AVNumberOfChannelsKey] = 2 as AnyObject?


           grabarAudio = try AVAudioRecorder(url:audioURL!, settings: settings)
           grabarAudio!.prepareToRecord()
       }catch let error as NSError{
           print(error)
       }
    }


}
