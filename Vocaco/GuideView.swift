//
//  GuideView.swift
//  Vocaco
//
//  Created by cho Sigyo on 2021/01/20.
//

import UIKit

class GuideView: UIViewController,UIScrollViewDelegate {
    let numOfPages = 4
    private var frame:CGSize{
        let f = self.view.frame.size
        return f
    }
    lazy var pagecontrol:UIPageControl = {
        let pagecont = UIPageControl()
        pagecont.frame = CGRect(x: 0, y: Double(view.frame.height-80), width: Double(view.frame.width), height: 20)
        pagecont.backgroundColor = UIColor.clear
        pagecont.numberOfPages = numOfPages
        //设置不是当前页的小点颜色
        pagecont.pageIndicatorTintColor = UIColor.white
        //设置当前页的小点颜色
        pagecont.currentPageIndicatorTintColor = UIColor.red
        pagecont.addTarget(self, action: #selector(changePage(sender:)), for: .valueChanged)
        return pagecont
    }()
    
    lazy var scrollView: UIScrollView = {
        //let sc = UIScrollView.init(frame: self.view.frame)
        let sc = UIScrollView()
        sc.frame = self.view.frame
        //为了能让内容横向滚动，设置横向内容宽度为4个页面的宽度总和
        sc.contentSize = CGSize.init(width: self.view.frame.size.width * CGFloat(numOfPages), height:self.view.frame.size.height)
        sc.showsHorizontalScrollIndicator = false
        //滚动时只能停留在某一页
        sc.isPagingEnabled = true
        sc.delegate = self
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        print(scrollView.contentSize,view.bounds.size)
    }
    func setView(){
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.pagecontrol)
        for i in 0 ..< numOfPages{
            let imgfile = "\(i+1)"
            print(imgfile)
            let image = UIImage(named:"\(imgfile)")
            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFill
            imgView.frame = CGRect(x:frame.width*CGFloat(i), y:CGFloat(0), width:frame.width, height:frame.height)
            scrollView.addSubview(imgView)
        }
        scrollView.contentOffset = CGPoint.zero
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        //print("scrolled:\(scrollView.contentOffset)")
        let twidth = CGFloat(numOfPages-1) * self.view.bounds.size.width
        pageNum()
        //如果在最后一个页面继续滑动的话就会跳转到主页面
        if(scrollView.contentOffset.x > twidth){
            let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let viewController = mainStoryboard.instantiateInitialViewController()
            self.present(viewController!, animated: true, completion:nil)
        }
    }
    func pageNum(){
        //通过scrollView内容的偏移计算当前显示的是第几页
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        //设置pageController的当前页
        pagecontrol.currentPage = page
    }
    @objc func changePage(sender:UIPageControl){
        //根据点击的页数，计算scrollView需要显示的偏移量
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        //展现当前页面内容
        scrollView.scrollRectToVisible(frame, animated:true)
    } 
}
