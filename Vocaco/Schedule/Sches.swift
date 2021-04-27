//
//  Sches.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/29.
//

import UIKit
import RealmSwift
import AVFoundation

class Sches: UITableViewController,AVAudioPlayerDelegate {
    
    var naviName:String?
    var ind = 0
    var idKey = ""
    let realm = try! Realm()
    var schesList:List<SchesRealm>?
    var scheList:ScheRealm!
    //let s = List<SchesRealm>()
    //var newS:Results<SchesRealm>?
    var currentSche:ScheRealm!
    
    var player:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = naviName
    
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeactive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopplay()
    }
    // MARK: - Table view data source
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentSche.Ss.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SsCell", for: indexPath) as! SchesCell
        cell.checkMark.isHidden = true
        cell.img.image = UIImage(data: currentSche.Ss[indexPath.row].image!)
        cell.word.text = currentSche.Ss[indexPath.row].word
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SchesCell
        cell.checkMark.isHidden = !cell.checkMark.isHidden
        cell.isSelected = false
        tableView.deselectRow(at: indexPath, animated: true)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let url = URL(fileURLWithPath:path[0]).appendingPathComponent(currentSche.Ss[indexPath.row].recordName!)
        
        play(url: url)
    }
    @objc func becomeactive(notification:Notification){
        stopplay()
    }
    func stopplay(){
        if playerAudio != nil{
            playerAudio.stop()
            playerAudio = nil
        }
    }
    func play(url:URL){
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player!.delegate = self
            player!.play()
        }catch{
            print(error)
        }
        
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do{
            try realm.write{
                realm.delete(currentSche.Ss[indexPath.row])
                //realm.delete(schesList![indexPath.row])
            }
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addData"{
            let vc = segue.destination as! DataShow
            vc.delegate = self
        }
    }
    
    

}
extension Sches:addData{
    
    func add(addItems: [SourceRealm]) {

        //let sche = realm.objects(ScheRealm.self).filter("name == '\(naviName)'").first
        for i in addItems{
            let item = SchesRealm()
            item.image = i.image
            item.word = i.word
            item.recordName = i.recordName
            try! realm.write{
                currentSche.Ss.append(item)
            }
            print(SchesRealm.self)
            saveData(item:item)
        }
        tableView.reloadData()
    }
    
    func saveData(item:SchesRealm){
        do{
            try realm.write{
                realm.add(item)
            }
        }catch{
            print(error)
        }
    }
}
