//
//  GuideHelp.swift
//  Vocaco
//
//  Created by cho Sigyo on 2021/01/20.
//

import UIKit

class GuideHelp: UIViewController,UIScrollViewDelegate {
    let picNum = 4
    private var frame:CGSize{
        let f = self.view.frame.size
        return f
    }
    lazy var guideView:UIScrollView = {
        let gv = UIScrollView()
        gv.delegate = self
        gv.frame = self.view.frame
        gv.contentSize = CGSize(width: frame.width, height: frame.height * CGFloat(picNum))
        return gv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        // Do any additional setup after loading the view.
    }
    func setView(){
        self.view.addSubview(guideView)
        for i in 1...4{
            let image = UIImage(named: "\(i)")
            print(i)
            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFill
            imgView.frame = CGRect(x: CGFloat(0), y: frame.height * CGFloat(i-1), width: frame.width, height: frame.height)
            guideView.addSubview(imgView)
        }
    }

   

}
