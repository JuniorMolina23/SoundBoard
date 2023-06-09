//
//  ViewController.swift
//  SoundBoard
//
//  Created by Junior on 5/24/23.
//  Copyright © 2023 empresa. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
           grabaciones = try
            context.fetch(Grabacion.fetchRequest())
           tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre! + " (tiempo: \(grabacion.tiempo!))"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do{
           reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
           reproducirAudio?.play()
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
           let grabacion = grabaciones[indexPath.row]
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           context.delete(grabacion)
           (UIApplication.shared.delegate as! AppDelegate).saveContext()
           do{
               grabaciones = try
                   context.fetch(Grabacion.fetchRequest())
               tablaGrabaciones.reloadData()
           }catch{}
        }

    }


}

