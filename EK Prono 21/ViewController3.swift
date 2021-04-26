//
//  ViewController3.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 25/04/2021.
//

import UIKit
import CoreXLSX

class ViewController3: UIViewController {

    let size1:Int = 15
    // Size of each subview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dummy = 1
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let bar1 = UIView()
        bar1.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * b1)
        
        bar1.backgroundColor = .systemRed
        //bar1.backgroundColor = UIColor.init(red: 0, green: 209/255, blue: 255/255, alpha: 0.75)
        view.addSubview(bar1)
        
        let chevronLeft = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        let chevronRight = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        
        let title = UILabel(frame: CGRect(x: bar1.frame.width * 0.3, y: bar1.frame.height * 0.45, width: bar1.frame.width * 0.4, height: bar1.frame.height * 0.35))
        
        title.text = "Uitslagen"
        title.textAlignment = NSTextAlignment.center
        title.font = UIFont.boldSystemFont(ofSize: 25.0)
        title.textColor = .white
        
        let cleft = UIButton(type: .custom)
        cleft.frame = CGRect(x: bar1.frame.width * 0.0, y: bar1.frame.height * 0.5, width: bar1.frame.width * 0.15, height: bar1.frame.height * 0.30)
        let cright = UIButton(type: .custom)
        cright.frame = CGRect(x: bar1.frame.width * 0.85, y: bar1.frame.height * 0.5, width: bar1.frame.width * 0.15, height: bar1.frame.height * 0.30)
        
        cleft.setImage(chevronLeft, for: UIControl.State.normal)
        cright.setImage(chevronRight, for: UIControl.State.normal)
        
        cleft.tintColor = .white
        cright.tintColor = .white
        
        cleft.addTarget(self, action: #selector(arrowleft), for: .touchUpInside)
        cright.addTarget(self, action: #selector(arrowright), for: .touchUpInside)
        
        bar1.addSubview(title)
        bar1.addSubview(cleft)
        bar1.addSubview(cright)
        
        let mainview = UIView()
        mainview.frame = CGRect(x: 0, y: view.frame.height * b1, width: view.frame.width, height: view.frame.height * (1-b1))
        view.addSubview(mainview)
        
        let sview = UIScrollView()
        sview.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)

        sview.showsVerticalScrollIndicator = false
        sview.translatesAutoresizingMaskIntoConstraints = false
        
        mainview.addSubview(sview)
        sview.edgeTo(view: mainview)
        
        playedgames(uview: sview)

    }
    
    func playedgames(uview: UIScrollView) {
        
            if PronosA.count > 0 {
            
            
                let br: CGFloat = uview.bounds.width
                let ho: CGFloat = uview.bounds.height
                
                var array = [UIView]()
                array.removeAll()
                
                let n = temp_voortgang
                
                for _ in 0 ..< n {
                    array.append(UIView())
                }
                
                for i in 0...n-1 {
                    
                    createviews(index1: i, actualview: array[i], superviewer: uview, numberviews: n)
                
                }
                
                uview.contentSize = CGSize(width: br, height: CGFloat(n + 1) * ho / CGFloat(size1))
            
            } else {
                
                let br = view.bounds.width
                let ho = view.bounds.height
                let label1 = UILabel(frame: CGRect(x: br * 0.40, y: ho * 0.35, width: br * 0.40, height: ho * 0.25))
                label1.textAlignment = NSTextAlignment.left
                label1.font.withSize(18)
                label1.text = "Fetching..."
                label1.textColor = .black
                view.addSubview(label1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                    self.view.subviews.forEach { (item) in
                    item.removeFromSuperview()
                    }
                    self.playedgames(uview: uview)
                
                }
                
            }
        
        }
        
        func createviews (index1: Int, actualview: UIView, superviewer: UIScrollView, numberviews: Int) {
                
                superviewer.addSubview(actualview)
            actualview.frame = CGRect(x: 0, y: 0.05 + view.bounds.height / CGFloat(size1) * CGFloat(index1), width: superviewer.bounds.width, height: view.bounds.height / CGFloat(size1))
                actualview.backgroundColor = .white
                
                createlabels(type: 1, superviewer: actualview, teller: index1)
                createlabels(type: 2, superviewer: actualview, teller: index1)
                
            }

        
        func createlabels (type: Int, superviewer: UIView, teller: Int) {
            
            let x0 = superviewer.bounds.width
            let y0 = superviewer.bounds.height
            
            var x1:CGFloat = 0
            let y1 = y0 * 0
            let h1 = y0
            var w1:CGFloat = 0
            
            
            let temp1:String = PronosA[teller].home_Team! + " - " + PronosA[teller].away_Team!
            //let temp2:String = PronosA[teller].fulltime!
            let temp2:String = String(PronosA[teller].home_Goals) + " - " + String(PronosA[teller].away_Goals)
            
            var temp3:String = ""
            
            
            if type == 1 {
            
                x1 = 0.05 * x0
                w1 = 0.75 * x0
                
                temp3 = temp1
                
            }
            
            if type == 2 {
            
                x1 = 0.85 * x0
                w1 = 0.10 * x0
                temp3 = temp2
                
            }
            
                
            let label = UILabel(frame: CGRect(x: x1, y: y1, width: w1, height: h1))
            label.textAlignment = NSTextAlignment.center
            label.text = temp3
            label.font.withSize(6)
            if type == 1 {
                label.textAlignment = NSTextAlignment.left}
            superviewer.addSubview(label)

            
        }
        

}
