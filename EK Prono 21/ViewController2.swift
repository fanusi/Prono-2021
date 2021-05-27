//
//  ViewController2.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 25/04/2021.
//

import UIKit

class ViewController2: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var Bar1: UIView!
    
    let u1:Int = 7
    //Number of subviews on screen
    
    let ind: [Int] = [sr - fr, qf - fr, sf - fr, f - fr, ga - fr]
    //Index second round, quarter finals, semi finals, finals and last game
    
    var fg:Int = 0
    
    var pg:Int = 0
    //Perfect guess dummy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dummy = 1
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        if PronosA.count > 0 {
        
            for n in 0...PronosA.count-1 {
                
                var dummy:Int = 0
                    
                if PronosA[n].status == "FT" && dummy == 0 {
                    fg = fg + 1
                } else if PronosA[n].status == "1H" || PronosA[n].status == "2H" || PronosA[n].status == "HT" {
                    fg = n
                    dummy = 1
                }
                
            }
            
        } else {
            
            fg = -1
            
        }
        
        print("fg = " + String(fg))
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let x:Int = min(fg + 1, ga)

        self.pickerView.selectRow(x, inComponent: 0, animated: false)
        self.pickerView(pickerView, didSelectRow: x, inComponent: 0)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //self.pickerView.selectRow(fg + 1, inComponent: 0, animated: false)
        //self.pickerView(pickerView, didSelectRow: fg + 1, inComponent: 0)
        barcontent()
    }
    
    
    func barcontent() {
        
        let chevronLeft = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        let chevronRight = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        
        let title = UILabel(frame: CGRect(x: Bar1.frame.width * 0.3, y: Bar1.frame.height * 0.45, width: Bar1.frame.width * 0.4, height: Bar1.frame.height * 0.35))
        
        title.text = "Pronos"
        title.textAlignment = NSTextAlignment.center
        title.font = UIFont.boldSystemFont(ofSize: 25.0)
        title.textColor = .white
        //title.textColor = .black
        
        let cleft = UIButton(type: .custom)
        cleft.frame = CGRect(x: Bar1.frame.width * 0.0, y: Bar1.frame.height * 0.5, width: Bar1.frame.width * 0.15, height: Bar1.frame.height * 0.30)
        let cright = UIButton(type: .custom)
        cright.frame = CGRect(x: Bar1.frame.width * 0.85, y: Bar1.frame.height * 0.5, width: Bar1.frame.width * 0.15, height: Bar1.frame.height * 0.30)
        
        cleft.setImage(chevronLeft, for: UIControl.State.normal)
        cright.setImage(chevronRight, for: UIControl.State.normal)
        
        cleft.tintColor = .white
        cright.tintColor = .white
        
        cleft.addTarget(self, action: #selector(arrowleft), for: .touchUpInside)
        cright.addTarget(self, action: #selector(arrowright), for: .touchUpInside)
        
        Bar1.addSubview(title)
        Bar1.addSubview(cleft)
        Bar1.addSubview(cright)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                
        var teller:Int = 1
        
        if PronosB.count > 0 {
        
            teller = ga + 1
        
        }
        
        return teller
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                
        var game: String = "No data"
        
        if PronosA.count > 0 {
            
            if row == 0 {
                
                game = "Select game"
                
            } else {
                
                if PronosA[row-1].home_Team! == "-" {
                    
                    game = PronosA[row-1].round!
                    
                } else {
                
                game = PronosA[row-1].home_Team! + " - " + PronosA[row-1].away_Team!
                
                }
                
            }
    
        }
        
        return game
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        removeSV(viewsv: View1)
        //Remove subviews
        
        if row == 0 {
            
            let sview = UIScrollView()
            sview.showsVerticalScrollIndicator = false
            sview.frame = CGRect(x: 0, y: 0, width: View1.frame.width, height: View1.frame.height)
            View1.addSubview(sview)
            sview.edgeTo(view: View1)
            
            let label1 = UILabel(frame: CGRect(x: View1.frame.width * 0.4, y: View1.frame.height * 0.4, width: View1.frame.width * 0.3, height: View1.frame.height * 0.2))
            
            label1.textAlignment = NSTextAlignment.left
            label1.text = "Select game"
            label1.font.withSize(12)
            //label.backgroundColor = .red
            label1.textColor = .black
            sview.addSubview(label1)
            
            
        } else {
            
            let sview = UIScrollView()
            sview.showsVerticalScrollIndicator = false
            sview.frame = CGRect(x: 0, y: 0, width: View1.frame.width, height: View1.frame.height)
            View1.addSubview(sview)
            sview.edgeTo(view: View1)
            
            visualizer(choice1: row-1, team1: PronosA[row-1].home_Team!, team2: PronosA[row-1].away_Team!, viewP: sview)
            
        }
        
    }
    
    func visualizer(choice1: Int, team1: String, team2: String, viewP: UIScrollView) {
            
            let exampleview = UIScrollView()
            
            //exampleview.backgroundColor = .black
            exampleview.translatesAutoresizingMaskIntoConstraints = false
            exampleview.showsVerticalScrollIndicator = false
            viewP.addSubview(exampleview)
            
            
            let br: CGFloat = viewP.bounds.width
            let ho: CGFloat = viewP.bounds.height

            exampleview.frame = CGRect(x: 0, y: 0, width: br, height: ho)
            
            var array = [UIView]()
            array.removeAll()
            
            
            let n = scores.count
            
            for _ in 0 ..< n {
                array.append(UIView())
            }
        
            for i in 0...n-1 {
                
                createviews(index1: i, actualview: array[i], superviewer: exampleview, numberviews: n, choice1: choice1, team1: team1, team2: team2)
            
            }
            
            exampleview.contentSize = CGSize(width: br, height: CGFloat(n + 1) * ho / CGFloat(u1))
            
        }
        
        func createviews (index1: Int, actualview: UIView, superviewer: UIScrollView, numberviews: Int, choice1: Int, team1: String, team2: String) {
                
                let gebr: Int = scores[index1].index
            
                superviewer.addSubview(actualview)
                actualview.frame = CGRect(x: 0, y: 0.0 + superviewer.bounds.height / CGFloat(u1) * CGFloat(index1), width: superviewer.bounds.width, height: superviewer.bounds.height / CGFloat(u1))

                //actualview.backgroundColor = .white
            
                actualview.layer.masksToBounds = true
                actualview.layer.borderColor = UIColor.systemGray.cgColor
                actualview.layer.borderWidth = 1.0
            
                createlabels(type: 1, superviewer: actualview, teller: index1, choice1: choice1, team1: team1, team2: team2)
                createlabels(type: 2, superviewer: actualview, teller: index1, choice1: choice1, team1: team1, team2: team2)
                createlabels(type: 3, superviewer: actualview, teller: index1, choice1: choice1, team1: team1, team2: team2)
                createlabels(type: 4, superviewer: actualview, teller: index1, choice1: choice1, team1: team1, team2: team2)
                
            let label2 = UILabel(frame: CGRect(x: actualview.bounds.width * 0.01, y: actualview.bounds.height * 0.35, width: actualview.bounds.width * 0.3, height: actualview.bounds.height * 0.3))
                label2.text = PronosB[gebr][0].user
                label2.font = UIFont.boldSystemFont(ofSize: 14.0)
                label2.lineBreakMode = .byClipping
                label2.adjustsFontSizeToFitWidth = true
                label2.minimumScaleFactor = 0.5
                actualview.addSubview(label2)
                
            }

        
        func createlabels (type: Int, superviewer: UIView, teller: Int, choice1: Int, team1: String, team2: String ) {
            
            let gebr: Int = scores[teller].index
            
            let x0 = superviewer.bounds.width
            let y0 = superviewer.bounds.height
            
            var x1:CGFloat = 0
            var y1:CGFloat = 0
            let h1 = y0 * 0.3
            var w1:CGFloat = 0
            
            var Astrings:[String] = []
            var Svalue: String = ""
            
            Astrings.removeAll()
            
            pg = 0
            // Reset perfect guess dummy
            
            if choice1 < ind[0] {
                
                // First round
                Astrings.append(PronosB[gebr][choice1].home_Team!)
                Astrings.append(String(PronosB[gebr][choice1].home_Goals))
                Astrings.append(String(PronosB[gebr][choice1].away_Goals))
                Astrings.append(PronosB[gebr][choice1].away_Team!)
                
                pg = 1
                
            } else {
                
                // Second round
                
                if PronosA[choice1].home_Team! != "-" && PronosA[choice1].away_Team! != "-" {
                //If teams are known, then we project the actual game, else the initial user predictions
                
                    Astrings = secondround(game: choice1, user: gebr, rteam1: team1, rteam2: team2)
                    
                    print("TEST")
                    print(Astrings)
                    
                } else {
                    
                    Astrings.append(PronosB[gebr][choice1].home_Team!)
                    Astrings.append(String(PronosB[gebr][choice1].home_Goals))
                    Astrings.append(String(PronosB[gebr][choice1].away_Goals))
                    Astrings.append(PronosB[gebr][choice1].away_Team!)
                    
                    pg = 1
                    
                }
                
            }
            
            if pg == 1 {
            //Perfect guess
            
                if type == 1 {
                
                    x1 = 0.35 * x0
                    w1 = 0.40 * x0
                    y1 = 0.20 * y0
                    
                    Svalue = Astrings[0]
                    
                }
                
                if type == 2 {
                
                    x1 = 0.80 * x0
                    w1 = 0.10 * x0
                    y1 = 0.20 * y0
                    
                    Svalue = Astrings[1]
                    
                }
                
                if type == 3 {
                
                    x1 = 0.80 * x0
                    w1 = 0.10 * x0
                    y1 = 0.50 * y0
                    
                    Svalue = Astrings[2]
                }
                
                if type == 4 {
                
                    x1 = 0.35 * x0
                    w1 = 0.40 * x0
                    y1 = 0.50 * y0
                    Svalue = Astrings[3]
                    
                }
            
            } else {
            // no perfect guess
                
                if Astrings[0] != "" {
                    
                    Svalue = Astrings[0]
                    
                    if Astrings[3] != "" {
                     
                        Svalue = "Both teams qualified"
                    
                    }
                        
                } else if Astrings[3] != "" {
                    
                    Svalue = Astrings[3]
                    
                    if Astrings[0] != "" {
                     
                        Svalue = "Both teams qualified"
                    
                    }
                        
                }
                
                x1 = 0.35 * x0
                w1 = 0.40 * x0
                y1 = 0.35 * y0
                
            }
                
            let label = UILabel(frame: CGRect(x: x1, y: y1, width: w1, height: h1))
            label.textAlignment = NSTextAlignment.left
            label.text = Svalue
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.adjustsFontSizeToFitWidth = true
            superviewer.addSubview(label)

            
        }
    
    func subsecond (a1: String, a2: String, a3: String, a4: String, rteam1: String, rteam2: String, i: Int, user: Int, round: Int) -> [String] {
        
        var arr:[String] = []
        var a1: String = a1
        var a2: String = a2
        var a3: String = a3
        var a4: String = a4
        
        var dummy: Int = 0
        var d2: Int = 0
        
        if round == 3 {
            
            d2 = 1
            
        }
        
        if PronosB[user][i].home_Team! == rteam1 {
            
            if PronosB[user][i].away_Team! == rteam2 {
                
                //Perfect guess
                a1 = PronosB[user][i].home_Team!
                a2 = String(PronosB[user][i].home_Goals)
                a3 = String(PronosB[user][i].away_Goals)
                a4 = PronosB[user][i].away_Team!
                
                dummy = 1
                pg = 1
            
            } else {
                
                // Check if team is in next round
                    
                if round != 4 {
                // All rounds except finals
                    
                    for j in ind[round] + d2...ind[round+1]-1 {
                        
                        if rteam1 == PronosB[user][j].home_Team! || rteam1 == PronosB[user][j].away_Team! {
                            
                            a1 = "Qualification " + rteam1
                            
                        }
                        
                    }
                    
                    
                } else {
                // Finals
                    
                    if PronosB[user][i].home_Goals > PronosB[user][i].away_Goals {
                        
                        a1 = "Winner " + rteam1
                        
                    }
                    
                    
                }
                

                
            }

        }
        
        if PronosB[user][i].away_Team! == rteam1 {
            
            if PronosB[user][i].home_Team! == rteam2  {
                
                //Perfect guess
                a1 = PronosB[user][i].away_Team!
                a2 = String(PronosB[user][i].away_Goals)
                a3 = String(PronosB[user][i].home_Goals)
                a4 = PronosB[user][i].home_Team!
                
                dummy = 1
                pg = 1
            
            } else {
                
                if round != 4 {
                // All rounds except finals
                
                    // Check if team is in next round
                    for j in ind[round] + d2...ind[round+1]-1 {
                        
                        if rteam1 == PronosB[user][j].home_Team! || rteam1 == PronosB[user][j].away_Team! {
                            
                            a1 = "Qualification " + rteam1
                            
                        }
                        
                    }
                
                } else {
                // Finals
                    
                    if PronosB[user][i].away_Goals > PronosB[user][i].home_Goals {
                        
                        a1 = "Winner " + rteam1
                        
                    }
                    
                    
                }
                
            }

        }
 
        if PronosB[user][i].away_Team! == rteam2 {
            
            if dummy == 0 {
                
                if round != 4 {
                // All rounds except finals
                
                    // In case of no perfect guess we check if team is in next round
                    for j in ind[round] + d2...ind[round+1]-1 {
                        
                        if rteam2 == PronosB[user][j].home_Team! || rteam2 == PronosB[user][j].away_Team! {
                            
                            a4 = "Qualification " + rteam2
                            
                        }
                        
                    }
                    
                } else {
                // Finals
                    
                    if PronosB[user][i].away_Goals > PronosB[user][i].home_Goals {
                        
                        a4 = "Winner " + rteam2
                        
                    }
                    
                    
                }
                
            }

        }
        
        if PronosB[user][i].home_Team! == rteam2 {
            
            if dummy == 0 {
                
                if round != 4 {
                // All rounds except finals
                
                    // In case of no perfect guess we check if team is in next round
                    for j in ind[round] + d2...ind[round+1]-1 {
                        
                        if rteam2 == PronosB[user][j].home_Team! || rteam2 == PronosB[user][j].away_Team! {
                            
                            a4 = "Qualification " + rteam2
                            
                        }
                        
                    }
                    
                } else {
                // Finals
                    
                    if PronosB[user][i].home_Goals > PronosB[user][i].away_Goals {
                        
                        a4 = "Winner " + rteam2
                        
                    }
                    
                    
                }
                
            }

        }
        
        arr.append(a1)
        arr.append(a2)
        arr.append(a3)
        arr.append(a4)
        
        return arr
        
    }
    
    func secondround (game: Int, user: Int, rteam1: String, rteam2: String) -> [String] {
        
        var arr:[String] = ["","","",""]
        var pteam1: String = ""
        var pteam2: String = ""
        var pgoals1: String = ""
        var pgoals2: String = ""
        
        if game < ind[1] {
        // Round of 16
            
            for i in ind[0]...ind[1]-1 {
                
                arr = subsecond(a1: arr[0], a2: arr[1], a3: arr[2], a4: arr[3], rteam1: rteam1, rteam2: rteam2, i: i, user: user, round: 1)
                
            }
        
        } else if game < ind[2] {
            // Quarter finals
                
            for i in ind[1]...ind[2]-1 {
                
                arr = subsecond(a1: arr[0], a2: arr[1], a3: arr[2], a4: arr[3], rteam1: rteam1, rteam2: rteam2, i: i, user: user, round: 2)
                
            }
            
        } else if game < ind[3] {
            // semi finals
                
            for i in ind[2]...ind[3]-1 {
                
                arr = subsecond(a1: arr[0], a2: arr[1], a3: arr[2], a4: arr[3], rteam1: rteam1, rteam2: rteam2, i: i, user: user, round: 3)
                
            }
            
        } else if game == ind[3] {

            // Losers Final
            
            arr = subsecond(a1: arr[0], a2: arr[1], a3: arr[2], a4: arr[3], rteam1: rteam1, rteam2: rteam2, i: game, user: user, round: 4)
            
        } else if game == ind[3] + 1 {
            
            // Final
            
            arr = subsecond(a1: arr[0], a2: arr[1], a3: arr[2], a4: arr[3], rteam1: rteam1, rteam2: rteam2, i: game, user: user, round: 4)
            
        }
        
        arr.append(pteam1)
        arr.append(String(pgoals1))
        arr.append(String(pgoals2))
        arr.append(pteam2)
        
        return arr
        
    }
    
    func removeSV (viewsv: UIView) {
     
        viewsv.subviews.forEach { (item) in
        item.removeFromSuperview()
        }
        
    }


}
