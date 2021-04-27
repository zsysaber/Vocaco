//
//  VoicePanel.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/10/12.
//

import UIKit
import RealmSwift
import AVFoundation
import Instructions

private let reuseIdentifier = "voiceCell"

class VoicePanel: UICollectionViewController,AVAudioPlayerDelegate {
 
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var nodataBG: UIImageView!
    
    var toolbar:UIToolbar{
        let tool = UIToolbar()
        let height = tabBarController?.tabBar.frame.height
        tool.frame = CGRect(x: 0, y: view.bounds.height - height!, width: view.bounds.width, height: 50)
        var item = [UIBarButtonItem]()
        let item1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(delAct(_:)))
        let item2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        trash.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        item.append(item1)
        item.append(trash)
        item.append(item2)
        tool.setItems(item, animated: true)
        return tool
    }
    
    let size = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let itemNum:CGFloat = 4
    
    let realm = try! Realm()
    var VoiceList:Results<VoiceRealm>!
    
    var selectedInd:[IndexPath] = []
    //var playerAudio:AVAudioPlayer?
    
    private var haveValue:Bool = false{
        didSet{
            if haveValue == true{
                nodataBG.isHidden = true
            }else{
                nodataBG.isHidden = false
            }
        }
    }
    
    private var imageview:UIImageView{
        let imageview = UIImageView()
        imageview.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        imageview.image = UIImage(named: "1")
        imageview.contentMode = .scaleAspectFill
        return imageview
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceList = realm.objects(VoiceRealm.self)
        getData()
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.title = "削除"
        view.backgroundColor = UIColor.systemGray
        //变成后台停止播放，恢复也不会再播放
        NotificationCenter.default.addObserver(self, selector: #selector(becomeactive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    //当前页面消失的时候停止播放
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playstop()
    }
    @objc func becomeactive(notification:Notification){
        playstop()
    }
    func playstop(){
        if playerAudio != nil{
            playerAudio.stop()
            playerAudio = nil
        }
    }
    func getData(){
        if !VoiceList.isEmpty{
            haveValue = true
            print("have value")
            collectionView.reloadData()
        }else{
            haveValue = false
            print("no value")
            collectionView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.coachMark.start(in: .window(over: self))
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.coachMark.stop(immediately: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if isEditing{
            collectionView.allowsMultipleSelection = true
            addBtn.isEnabled = false
            editButtonItem.title = "キャンセル"
            barhid(tabbarhid: true)
            self.view.addSubview(toolbar)
        }else{
            addBtn.isEnabled = true
            barhid(tabbarhid: false)
            editButtonItem.title = "削除"
            selectedInd.removeAll()
            print(selectedInd)
            collectionView.reloadData()
        }
    }
    func barhid(tabbarhid:Bool){
        tabBarController?.tabBar.isHidden = tabbarhid
    }
    @IBAction func helpAct(_ sender: Any) {
        let help = GuideHelp()
        help.setView()
        
    }
    @IBAction func delAct(_ sender: Any) {
        //如果一个cell针对编辑模式有两个点击动作时，复数选中删除不能用indexPathForSelectedItems这个属性，这个属性编辑和非编辑下的点击动作全包含，如果只是要用编辑下的选择，需要自己创建一个indexPath的合集来统计
        for ind in selectedInd{
            do{
                try realm.write{
                    //通过indexpath把选中的cell在realm中的属性全改成true
                    VoiceList![ind.row].check = true
                }
            }catch{
                print(error)
            }
        }
        //筛选出check是true的数据
        let deleteItems = realm.objects(VoiceRealm.self).filter("check == true")
        //整体删除
        deleteData(items: deleteItems)
        getData()
        selectedInd.removeAll()
        addBtn.isEnabled = true
        barhid(tabbarhid: false)
        editButtonItem.title = "削除"
        self.isEditing = false
        
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voiceAddData"{
            let vc = segue.destination as! DataShow
            vc.delegate = self
        }
    }
}

extension VoicePanel:addData,UICollectionViewDelegateFlowLayout{
    

    private func image(forEmptyDataSet scrollView: UIScrollView) -> UIImageView?{
        let image = imageview
        return image
    }
    func add(addItems: [SourceRealm]) {
        for i in addItems{
            let item = VoiceRealm()
            item.image = i.image
            item.word = i.word
            item.recordName = i.recordName
            saveData(item: item)
        }
        collectionView.reloadData()
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return VoiceList?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VoiceCell
        if !(VoiceList!.isEmpty){
            cell.imageBtn.image = UIImage(data: VoiceList![indexPath.row].image!)
            cell.word.text = VoiceList![indexPath.row].word
            cell.alphaView.isHidden = true
        }else{
            view.addSubview(imageview)
            print("show imageview")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing{
            let cell = collectionView.cellForItem(at: indexPath) as! VoiceCell
            selectedInd.append(indexPath)
            cell.alphaView.isHidden = false
            print(selectedInd)
        }else{
            print(indexPath)
//            let p = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//            let u = URL(fileURLWithPath: p[0]).appendingPathComponent(VoiceList![indexPath.row].recordName!)
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = path[0].appendingPathComponent(VoiceList![indexPath.row].recordName!)
            play(url: fileURL)
            //avPlay(url: u)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    
    func play(url:URL){
        do{
            //playerAudio = nil
            playerAudio = try AVAudioPlayer(contentsOf: url)
            playerAudio!.delegate = self
            print("ready play")
            playerAudio!.play()
            print(url)
            print("play")
        }catch{
            print("this is a error")
        }
    }
   
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing{
            let cell = collectionView.cellForItem(at: indexPath) as! VoiceCell
            cell.alphaView.isHidden = true
            selectedInd = selectedInd.filter{$0 != indexPath}
            print(selectedInd)
        }else{
            print(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return size.bottom
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return size.bottom
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let colSize = (collectionView.bounds.width - (itemNum+1) * size.bottom)/itemNum
        return CGSize(width: colSize, height: colSize*1.3)
    }
    func saveData(item:VoiceRealm){
        do{
            try realm.write{
                realm.add(item)
            }
            getData()
        }catch{
            print(error)
        }
    }
    func deleteData(items:Results<VoiceRealm>){
        do{
            try realm.write{
                realm.delete(items)
            }
        }catch{
            print(error)
        }
    }
}
