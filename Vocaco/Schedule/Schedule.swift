//
//  Schedule.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/29.
//

import UIKit
import RealmSwift

class Schedule: UITableViewController {

    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    let realm = try! Realm()
    var scheList:Results<ScheRealm>?
    
    private var haveValue:Bool = false{
        didSet{
            if haveValue == true{
                backview.isHidden = true
            }else{
                backview.isHidden = false
            }
        }
    }
    
    lazy var backview:UIView = {
        let bv = UIImageView(image: UIImage(named: "3"))
        bv.contentMode = .scaleAspectFill
        tableView.backgroundView = bv
        return tableView.backgroundView!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
        showBV()
        
    }
    func showBV(){
        if !scheList!.isEmpty{
            haveValue = true
        }else{
            haveValue = false
        }
    }
    
    func readData(){
        //按照sortID的大小排序
        scheList = realm.objects(ScheRealm.self).sorted(byKeyPath: "sortID")
    }

    // MARK: - Table view data source

  
   
    var text:String = ""
    @IBAction func addTitle(_ sender: Any) {
        let alert = UIAlertController(title: "add title", message: "", preferredStyle: .alert)
        
        alert.addTextField{(textField) in
            textField.becomeFirstResponder()
            textField.placeholder = "input title"
        }
        let alert1 = UIAlertAction(title: "OK", style: .default){(action) in
            let title = alert.textFields?.first?.text
            self.text = title!
            self.addName()
            self.showBV()
        }
        let alert2 = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(alert1)
        alert.addAction(alert2)
        self.present(alert,animated: true)
    }
    var sortIDArray: [Int] = []
    var maxNum = 0
    func addName(){
        let NewName = ScheRealm()
        NewName.name = text
        let dateFormatter = DateFormatter()
//        dateFormatter.calendar = Calendar(identifier: .gregorian)
//        dateFormatter.locale = Locale(identifier: "en_US")
//        dateFormatter.timeZone = TimeZone(identifier: "JST")
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:SS"
        let date = dateFormatter.string(from: Date())
        NewName.id = date
        NewName.sortID = (scheList?.last?.sortID ?? 0) + 1
        saveData(source: NewName)
        tableView.reloadData()
       
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sCell", for: indexPath) as! ScheduleCell
        if let scheList = scheList{
            cell.nameView.text = scheList[indexPath.row].name
            
        }
        return cell
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do{
            try realm.write{
                realm.delete(scheList![indexPath.row])
            }
            self.showBV()
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    

    
    // MARK: - Navigation
    var selectedRow = 0
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! ScheduleCell
        let row = tableView.indexPath(for: cell)!.row
        selectedRow = row
        if segue.identifier == "changeName"{
            let vc = segue.destination as! ChangeName
            vc.delegate = self
            vc.oldName = cell.nameView.text
        }else if segue.identifier == "addList"{
            let vc = segue.destination as! Sches
            let key = scheList![row].id
            vc.currentSche = realm.object(ofType: ScheRealm.self, forPrimaryKey: key)
            vc.scheList = sender as? ScheRealm
            vc.naviName = scheList![row].name
            vc.idKey = scheList![row].id!
            vc.ind = row
        }
    }
}

extension Schedule:ChangeNameDelegate{
    func change(name: String) {
        do{
            try realm.write{
                scheList![selectedRow].name = name
            }
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    func saveData(source:ScheRealm){
        do{
            try realm.write{
                realm.add(source)
                readData()
            }
        }catch{
            print(error)
        }
    }
}
