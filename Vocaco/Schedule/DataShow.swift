//
//  DataShow.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/10/02.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "dataCell"
protocol addData{
    func add(addItems:[SourceRealm])
}
class DataShow: UICollectionViewController {
    
    let size = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let itemNum:CGFloat = 4
    
    var dataList:Results<SourceRealm>?
    let realm = try! Realm()
    
    var selectInd:[IndexPath] = []
    var selectItem:[SourceRealm] = []
    
    var delegate:addData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        dataList = realm.objects(SourceRealm.self)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func saveAct(_ sender: Any) {
        for ind in selectInd{
            selectItem.append(dataList![ind.row])
        }
        print(selectItem)
        if selectItem.isEmpty{
            let alert = UIAlertController(title: "Please select", message: "", preferredStyle: .alert)
            let alert1 = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(alert1)
            self.present(alert,animated: true)
        }else{
            delegate?.add(addItems: selectItem)
        }
        selectInd.removeAll()
        selectItem.removeAll()
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataList?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DataShowCell
        cell.checkMark.isHidden = true
        if let dataList = dataList{
            cell.imageBtn.image = UIImage(data: dataList[indexPath.row].image!)
            cell.word.text = dataList[indexPath.row].word
        }
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DataShowCell
        cell.checkMark.isHidden = false
        selectInd.append(indexPath)
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DataShowCell
        cell.checkMark.isHidden = true
        selectInd = selectInd.filter{$0 != indexPath}
    }

}

extension DataShow:UICollectionViewDelegateFlowLayout{
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
}
