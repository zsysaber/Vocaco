//
//  ChangeName.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/29.
//

import UIKit


protocol ChangeNameDelegate {
    func change(name:String)
}

class ChangeName: UIViewController {

    @IBOutlet weak var CNView: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var oldName:String!
    var delegate:ChangeNameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNView.text = oldName
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveBtn.layer.cornerRadius = saveBtn.bounds.height/2
    }

    @IBAction func save(_ sender: Any) {
        if let newName = CNView.text,newName != ""{
            delegate?.change(name: CNView.text!)
            self.dismiss(animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "please input", message: "", preferredStyle: .alert)
            let alert1 = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(alert1)
            self.present(alert, animated: true, completion: nil)
        }
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
