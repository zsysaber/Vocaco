//
//  Message.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/10/13.
//

import UIKit
import RealmSwift
import AVFoundation


class Message: UIViewController,AVAudioPlayerDelegate {

    let cellID1 = "dataCell"
    let cellID2 = "messageCell"
    var selectInd:[IndexPath] = []
    var playItem:AVPlayerItem?
    var queuePlayer:AVQueuePlayer?
    
    @IBOutlet weak var messages: UICollectionView!
    @IBOutlet weak var message: UICollectionView!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var backView: UIImageView!
    //var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    
    let realm = try! Realm()
    var messagesList:Results<MessageAllRealm>?
    var messageList:Results<MessageRealm>?
    
    let inset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    let itemMNum:CGFloat = 4
    
    private var haveValue:Bool = false{
        didSet{
            if haveValue == true{
                backView.isHidden = true
            }else{
                backView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesList = realm.objects(MessageAllRealm.self)
        messageList = realm.objects(MessageRealm.self)
        let nib = UINib(nibName: "DataCell", bundle: nil)
        messages.register(nib, forCellWithReuseIdentifier: cellID1)
        showBV()
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.title = "削除"
        deleteBtn.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(endPlay(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playstop()
    }
    func showBV(){
        if !messagesList!.isEmpty{
            haveValue = true
            messages.reloadData()
        }else{
            haveValue = false
            messages.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if isEditing{
            deleteBtn.isEnabled = true
            addBtn.isEnabled = false
            editButtonItem.title = "キャンセル"
            messages.allowsMultipleSelection = true
        }else{
            deleteBtn.isEnabled = false
            addBtn.isEnabled = true
            editButtonItem.title = "削除"
            messages.allowsMultipleSelection = false
            messages.reloadData()
        }
    }

    @IBAction func delAct(_ sender: Any) {
        for ind in selectInd{
            do{
                try realm.write{
                    //通过indexpath把选中的cell在realm中的属性全改成true
                    messagesList![ind.row].check = true
                }
            }catch{
                print(error)
            }
        }
        //筛选出check是true的数据
        let deleteItems = realm.objects(MessageAllRealm.self).filter("check == true")
        //整体删除
        deleteData1(items: deleteItems)
        showBV()
        deleteBtn.isEnabled = false
        addBtn.isEnabled = true
        editButtonItem.title = "削除"
        messages.reloadData()
        selectInd.removeAll()
        self.isEditing = false
    }
//    var playArray:[URL] = []
//    var playNum = 0
    var array:[AVPlayerItem] = []
    var playstate = "stop"
    @IBAction func playAct(_ sender: Any) {
        if playstate == "stop"{
            array.removeAll()
            if let message = messageList{
                //let composition = AVMutableComposition()
                for i in message{
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let url =  path[0].appendingPathComponent(i.recordName!)
                    playItem = AVPlayerItem(url: url)
                    array.append(playItem!)
                }
            }
            playBtn.setImage(UIImage(systemName: "pause"), for: .normal)
            queuePlayer = AVQueuePlayer(items: array)
            queuePlayer?.play()
            playstate = "play"
        }else{
            playstop()
        }
    }
    @objc func endPlay(notification:Notification){
        playstop()
    }
    func playstop(){
        playstate = "stop"
        playBtn.setImage(UIImage(systemName: "play"), for: .normal)
        queuePlayer?.pause()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMessage"{
            let vc = segue.destination as! DataShow
            vc.delegate = self
        }
    }
}

extension Message:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,addData{
    func add(addItems: [SourceRealm]) {
        for i in addItems{
            let item = MessageAllRealm()
            item.image = i.image
            item.word = i.word
            item.recordName = i.recordName
            saveData(item: item)
        }
        messages.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return messagesList?.count ?? 0
        }else{
            return messageList?.count ?? 0
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID1, for: indexPath) as! DataCell
            selectInd.removeAll()
            if let messageslist = messagesList{
                cell.imageBtn.image = UIImage(data: messageslist[indexPath.row].image!)
                cell.word.text = messageslist[indexPath.row].word
                cell.alphaView.isHidden = true
                cell.checkBtn.isHidden = true
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID2, for: indexPath) as! MessageCell
            if let messagelist = messageList{
                cell.imageBtn.image = UIImage(data: messagelist[indexPath.row].image!)
            }

            return cell
        }
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing{
            if collectionView.tag == 1{
                let cell = collectionView.cellForItem(at: indexPath) as! DataCell
                selectInd.append(indexPath)
                cell.alphaView.isHidden = false
                cell.checkBtn.isHidden = false
            }
        }else{
            if collectionView.tag == 1{
                let newMessage = MessageRealm()
                newMessage.image = messagesList![indexPath.row].image
                newMessage.word = messagesList![indexPath.row].word
                newMessage.recordName = messagesList![indexPath.row].recordName
                saveData2(item: newMessage)
                message.reloadData()
            }else{
                let deleteItem = messageList![indexPath.row]
                deleteData2(item: deleteItem)
                message.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing{
            if collectionView.tag == 1{
                let cell = collectionView.cellForItem(at: indexPath) as! DataCell
                selectInd = selectInd.filter{$0 != indexPath}
                cell.alphaView.isHidden = true
                cell.checkBtn.isHidden = true
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return inset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return inset.bottom
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return inset.left
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1{
            let size = (collectionView.bounds.width - inset.left * (itemMNum+1))/itemMNum
            return CGSize(width: size, height: size*1.3)
        }else{
            let size = collectionView.bounds.height - (inset.left * 2)
            return CGSize(width: size, height: size)
        }
        
    }
    
    func saveData(item:MessageAllRealm){
        do{
            try realm.write{
                realm.add(item)
            }
            showBV()
        }catch{
            print(error)
        }
    }
    
    func saveData2(item:MessageRealm){
        do{
            try realm.write{
                realm.add(item)
            }
        }catch{
            print(error)
        }
    }
    func deleteData2(item:MessageRealm){
        do{
            try realm.write{
                realm.delete(item)
            }
        }catch{
            print(error)
        }
    }
    func deleteData1(items:Results<MessageAllRealm>){
        do{
            try realm.write{
                realm.delete(items)
            }
        }catch{
            print(error)
        }
    }
}
