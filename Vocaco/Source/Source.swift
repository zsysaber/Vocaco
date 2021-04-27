//
//  Source.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/25.
//

import UIKit
import RealmSwift
import SSZipArchive
import StoreKit

private let reuseIdentifier = "dataCell"

class Source: UICollectionViewController,UIToolbarDelegate,SSZipArchiveDelegate {
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var buyBtn: UIBarButtonItem!
    @IBOutlet weak var backView: UIImageView!
    
    private var tool:UIToolbar{
        let toolbar = UIToolbar()
        let height = tabBarController?.tabBar.frame.height
        toolbar.frame = CGRect(x: 0, y: view.bounds.height - height!, width: view.bounds.width, height: 50)
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(shareAct(_:)) ))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(delAct(_:))))
        toolbar.setItems(items, animated: true)
        return toolbar
    }
    let size = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let itemNum:CGFloat = 4
    
    var selectedArray:[IndexPath] = []
    
    var sourceList:Results<SourceRealm>?
    var selectedList:Results<SourceRealm>?
    
    let realm = try! Realm()
    
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
        
        let nib = UINib(nibName: "DataCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "dataCell")
        
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.title = "編集"
        //从realm取数据的固定写法
        sourceList = realm.objects(SourceRealm.self)
        showBV()
        //apple把收银员（观察员）这个任务（delegate）委托给app
        SKPaymentQueue.default().add(self)
        isPay()
    }
    
    func showBV(){
        if !sourceList!.isEmpty{
            haveValue = true
            collectionView.reloadData()
        }else{
            haveValue = false
            collectionView.reloadData()
        }
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if isEditing{
            addBtn.isEnabled = false
            
            barHid(tabbarHid: true)
            self.view.addSubview(tool)
 
            editButtonItem.image = nil
            editButtonItem.title = "キャンセル"
            collectionView.allowsMultipleSelection = true
        }else{
            collectionView.allowsMultipleSelection = false
            barHid(tabbarHid: false)
            addBtn.isEnabled = true
            editButtonItem.title = "編集"
            diddeselect()
        }
    }
    func barHid(tabbarHid:Bool){
        tabBarController?.tabBar.isHidden = tabbarHid
    }
    
    @objc func del(){
        if selectedArray.isEmpty {
            let alert = UIAlertController(title: "Please select picture", message: "", preferredStyle: .alert)
            self.present(alert,animated: true)
            tapCancel(alert: alert)
        }else{
            let alert = UIAlertController(title: "Are you sure", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "yes", style: .default){(action:UIAlertAction) in self.realDelete()}
            let cancel = UIAlertAction(title: "cancel", style: .cancel){(action:UIAlertAction) in self.tapCancel(alert: alert)}
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert,animated: true)
        }
    }
    
    @IBAction func delAct(_ sender: Any) {
        if selectedArray.isEmpty {
            let alert = UIAlertController(title: "Please select picture", message: "", preferredStyle: .alert)
            self.present(alert,animated: true)
            tapCancel(alert: alert)
        }else{
            let alert = UIAlertController(title: "Are you sure", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "yes", style: .default){(action:UIAlertAction) in self.realDelete()}
            let cancel = UIAlertAction(title: "cancel", style: .cancel){(action:UIAlertAction) in self.tapCancel(alert: alert)}
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert,animated: true)
        }
        
    }
    func tapCancel(alert:UIAlertController){
        alert.dismiss(animated: true, completion: nil)
        diddeselect()
        urlZIP.removeAll()
        //collectionView.reloadData()
    }
    func realDelete(){
        for ind in selectedArray{
            do{
                try realm.write{
                    //通过indexpath把选中的cell在realm中的属性全改成true
                    sourceList![ind.row].check = true
                }
            }catch{
                print(error)
            }
        }
        //筛选出check是true的数据
        selectedList = realm.objects(SourceRealm.self).filter("check == true")
        //整体删除
        deleteData(items: selectedList!)
        addBtn.isEnabled = true
        editButtonItem.title = "編集"
        barHid(tabbarHid: false)
        selectedArray.removeAll()
        collectionView.reloadData()
    }
    //取消选中
    func diddeselect(){
        for ind in selectedArray{
            do{
                try realm.write{
                    sourceList![ind.row].check = false
                }
            }catch{
                print(error)
            }
        }
        selectedArray.removeAll()
        print(selectedArray)
        collectionView.reloadData()
    }
    
    
    //MARK:airdrop
    //airdrop相关
    var activity:UIActivityViewController?
    var urlZIP:[URL] = []
    var activityitems:[URL] = []
    //airdrop预定
    @IBAction func shareAct(_ sender: Any) {
        if !selectedArray.isEmpty{

            for item in selectedArray{
                let recordName = sourceList![item.row].recordName
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let fileURL = path[0].appendingPathComponent(recordName!)
                activityitems.append(fileURL)
            }
            print(activityitems)
            activity = UIActivityViewController(activityItems: activityitems, applicationActivities: nil)
            //activity?.excludedActivityTypes = [.airDrop]
            if let popC = activity?.popoverPresentationController{
                popC.sourceRect = CGRect(x: 0, y: view.bounds.height*2/3, width: 0, height: 0)
                popC.sourceView = self.view
            }
            //activity?.popoverPresentationController?.barButtonItem = self.share
            self.present(activity!, animated: true, completion: nil)
            activityitems.removeAll()
        }else{
            let alert = UIAlertController(title: "写真と音声を設定してない", message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false){_ in
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sourceList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dataCell", for: indexPath) as! DataCell
        cell.imageBtn.layer.cornerRadius = cell.imageBtn.bounds.width/30
        if let sourceList = sourceList{
            cell.imageBtn.image = UIImage(data: sourceList[indexPath.row].image!)
            cell.word.text = sourceList[indexPath.row].word
            //collectionView.reloadData()会自动调用此方法，添加这两行可以把cell恢复原状
            cell.checkBtn.isHidden = true
            cell.alphaView.isHidden = true
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DataCell
        if isEditing{
            cell.alphaView.isHidden = false
            cell.checkBtn.isHidden = false
            selectedArray.append(indexPath)
            print(selectedArray)
        }else{
            cell.alphaView.isHidden = true
            cell.checkBtn.isHidden = true
            collectionView.deselectItem(at: indexPath, animated: true)
            //不在修改模式点击cell就进入detail页面
            performSegue(withIdentifier: "editSource", sender: cell)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DataCell
        if isEditing{
            selectedArray = selectedArray.filter{$0 != indexPath}
            cell.alphaView.isHidden = true
            cell.checkBtn.isHidden = true
            print(selectedArray)
        }
    }
    var selectRow = 0
    let vipID = "VocacoVIP"
    fileprivate var vipLine:Int = 5
    @IBAction func adddORvip(_ sender: UIBarButtonItem) {
        if sourceList!.count >= vipLine{
            let pay = SKMutablePayment()
            pay.productIdentifier = vipID
            SKPaymentQueue.default().add(pay)
        }else{
            performSegue(withIdentifier: "addSource", sender: addBtn)
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSource"{
            let vc = segue.destination as! CreateSource
            vc.delegate = self
            vc.isEdit = false
        }else if segue.identifier == "editSource"{
            let vc = segue.destination as! CreateSource
            vc.delegate = self
            vc.isEdit = true
            let cell = sender as! DataCell
            let row = collectionView.indexPath(for: cell)!.row
            selectRow = row
            vc.img = UIImage(data:sourceList![row].image!)
            vc.text = sourceList![row].word
            vc.urlPath = sourceList![row].recordName
        }
    }
    
    func savePayment(){
        UserDefaults.standard.setValue(true, forKey: vipID)
    }
    func isPay(){
        let ispay = UserDefaults.standard.bool(forKey: vipID)
        if ispay{
            vipLine = Int.max
            deleteBuy()
        }
    }
    func deleteBuy(){
        if (navigationItem.rightBarButtonItems?[1]) != nil{
            navigationItem.rightBarButtonItems?.remove(at: 1)
        }else{
            return
        }
    }
    @IBAction func didBuyVIP(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}
extension Source:UICollectionViewDelegateFlowLayout,transDelegate,SKPaymentTransactionObserver{
    //MARK:pay
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            if transaction.transactionState == .purchased{
                print("购买成功")
                savePayment()
                isPay()
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .failed{
                if let error = transaction.error{
                    print("购买失败，原因是：\(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .restored{
                savePayment()
                isPay()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func didAdd(word: String, img: UIImage, recordName: String) {
        let item = SourceRealm()
        item.image = img.jpegData(compressionQuality: 0.8)
        item.word = word
        item.recordName = recordName
        saveData(source: item)
        //调用reloadData（）会执行cellForRowAt
        collectionView.reloadData()
    }
    
    func didEdit(word: String, img: UIImage, recordName: String) {
        do{
            try realm.write{
                sourceList![selectRow].image = img.jpegData(compressionQuality: 0.8)
                sourceList![selectRow].word = word
                sourceList![selectRow].recordName = recordName
            }
        }catch{
            print(error)
        }
        collectionView.reloadData()
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
    func saveData(source:SourceRealm){
        do{
            try realm.write{
                realm.add(source)
            }
            showBV()
        }catch{
            print(error)
        }
    }
    func deleteData(items:Results<SourceRealm>){
        do{
            try realm.write{
                realm.delete(items)
            }
            showBV()
        }catch{
            print(error)
        }
    }
}
