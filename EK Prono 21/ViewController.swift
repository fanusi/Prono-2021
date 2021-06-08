//
//  ViewController.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 25/04/2021.
//

import UIKit
import CoreXLSX

public var dummy = Int()
public var dummy2 = Int()

//Test dummies to be deleted in real version
//public var dummy3 = Int()
//public var d1: Int = 0
//public var d2: Int = 0


public var PronosA = [Pronostiek]()
public var PronosB = [[Pronostiek]]()
// PronosA contains real scores

public var StandingsA = [Standings]()
 
public let b1:CGFloat = 0.12
// Height of upper bar

//public let temp_voortgang = 262 + 10 + Int.random(in: 0..<30)
//public let temp_voortgang = 262 + 10

//Gespeeld in simulatie => Verdwijnt

public let ga:Int = 51
//Number of matches

public let fr:Int = 262
//Match index start tournament

public let sr:Int = 298
//Match index number 2nd round (262 + 36)

public let qf:Int = 306
//start quarter finals (262 + 44)

public let sf:Int = 310
//start semi finals (262 + 48)

public let f:Int = 312
//start finals (262 + 20)

var scores = [Scores]()
// Users and their scores


var livegames = [Livegames]()

public var livedummy: Bool = false
// Test livebar

class ViewController: UIViewController, UIScrollViewDelegate {
    
    //var PronosB = [[Pronostiek]]()
    // PronosB contains guesses of all players
    
    let pr:Int = 10
    //Number of players
    
    var lastgame1: Int = 0
    
    let ind: [Int] = [sr - fr, qf - fr, sf - fr, f - fr, ga - fr]
    //Index second round, quarter finals, semi finals, finals and last game
    
    var groupsPlayed = [Int]()
    //Matrix returning total games played from group 1 to 6
    
    var qual16 = [String]()
    // best 2 from each group that qualify for round of 16
    
    var qual16_3 = [String]()
    // best third from each group that qualify for round of 16
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test dummies to be deleted in real version
//        if dummy3 == 0 {
//            d1 = Int.random(in: 0..<3)
//            d2 = Int.random(in: 0..<3)
//            dummy3 = 1
//        }

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
        
        if dummy == 0 {
            
            //Only parse on app loading
            //fixtureParsing()
            standingParsing()
            fixtureParsing()
            
        }
        
        //Create views and ranking
        initiate()
        
    }
    
    func initiate() {
        
        removeSV(viewsv: view)
        //Add upper bar
        upperbar(text: "Ranking", size: b1)
        
        if PronosA.count > 0 && StandingsA.count > 0 {
            
            //Populate best two teams from each group
            qual16.removeAll()
            qual16_3.removeAll()
            lastgame1 = lastgame()
            
            //temp uncomment qual16 = qualbest2() voor tornooi
//            qual16 = ["Italy", "Switzerland", "Denmark", "Belgium", "Austria", "Netherlands", "England", "Czech Republic", "Sweden", "Poland", "France", "Hungary"]
//
//            qual16_3 = ["Finland", "Wales", "Spain", "N Macedonia"]
            
            qual16 = qualbest2()
            qual16_3 = qualbest3()
            
//            print("Beste derde")
//            print(qual16_3)
            
            //Only load prediction once
            if dummy2 == 0 {
                
                realpronos()
                dummy2 = 1
                
            }
            
            //Set true for testing
            //livebar = true
            
            //Add main view
            let mview = mainview(livebar: livedummy, size: b1)
            view.addSubview(mview)
            
            //Add livebar only when game is ongoing
//            if livedummy {
            let lbar = livebar(size: b1)
            view.addSubview(lbar)
//            }
            
            //Add scrollview to mainview
            let sview = scroller()
            mview.addSubview(sview)
            sview.edgeTo(view: mview)
            
            scoreView(view1: sview)
            
        } else {

            //Add main view
            let mview = mainview(livebar: livedummy, size: b1)
            view.addSubview(mview)
            
            let br = mview.bounds.width
            let ho = mview.bounds.height
            let label1 = UILabel(frame: CGRect(x: br * 0.40, y: ho * 0.35, width: br * 0.40, height: ho * 0.25))
            label1.textAlignment = NSTextAlignment.left
            label1.font.withSize(18)
            label1.text = "Loading..."
            //label1.textColor = .black
            mview.addSubview(label1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
                mview.removeFromSuperview()
                self.initiate()
            
            }
            
        }
        
    }
    
    func lastgame() -> Int {
        
        var fg:Int = 0
        
        for n in 0...PronosA.count-1 {
            
            var dummy:Int = 0
            
            if PronosA[n].status == "FT" && dummy == 0 {
                fg = fg + 1
            } else if PronosA[n].status == "1H" || PronosA[n].status == "2H" || PronosA[n].status == "HT" {
                fg = n
                dummy = 1
            }
            
        }
        
        
        return fg-1
        
    }
    
//    func fixtureParsing_Temp () {
//
//                //Populate PronosA from FootballAPI
//
//                PronosA.removeAll()
//                livegames.removeAll()
//
//                let realtest = Realtest()
//
//                let hteams:[String] = realtest.0
//                let ateams:[String] = realtest.1
//                let hgoals:[Int] = realtest.2
//                let agoals:[Int] = realtest.3
//
//                let headers = [
//                    "x-rapidapi-key": "a08ffc63acmshbed8df93dae1449p15e553jsnb3532d9d0c9b",
//                    "x-rapidapi-host": "api-football-v1.p.rapidapi.com"
//                ]
//
//                //403
//                let request = NSMutableURLRequest(url: NSURL(string: "https://api-football-v1.p.rapidapi.com/v2/fixtures/league/403?timezone=Europe%2FLondon")! as URL,
//                                                    cachePolicy: .useProtocolCachePolicy,
//                                                timeoutInterval: 10.0)
//                request.httpMethod = "GET"
//                request.allHTTPHeaderFields = headers
//
//                let session = URLSession.shared
//
//                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//
//
//                if error == nil && data != nil {
//
//
//                let decoder = JSONDecoder()
//
//                do {
//
//                        let start = 262
//                        let end = 312
//
//                        // The API will only show new entries for second round when games are fully known. Initially it only goes to 297 (36 first round games)
//
//                        let niveau1 = try decoder.decode(api1.self, from: data!)
//                        print("Counterrrr")
//                        print(niveau1.api.fixtures.count)
//
//                        for n in start...end {
//
//                            let newFixture = Pronostiek(context: self.context)
//
//                            if n < sr {
//                                newFixture.round = "First round"
//                            } else if n < qf {
//                                newFixture.round = "Round of 16"
//                            } else if n < sf {
//                                newFixture.round = "Quarter Finals"
//                            } else if n < f {
//                                newFixture.round = "Semi Finals"
//                            } else {
//                                newFixture.round = "Final"
//                            }
//
//                            newFixture.fixture_ID = Int32(n)
//
//                            if n < temp_voortgang {
//
//                                newFixture.home_Goals = Int16(hgoals[n-start])
//                                newFixture.away_Goals = Int16(agoals[n-start])
//                                newFixture.status = "FT"
//                                newFixture.fulltime = String(newFixture.home_Goals) + "-" + String(newFixture.away_Goals)
//                                newFixture.home_Team = hteams[n-start+1]
//                                newFixture.away_Team = ateams[n-start+1]
//
//                            } else {
//
//                                newFixture.home_Goals = -999
//                                newFixture.away_Goals = -999
//                                newFixture.status = "NS"
//                                newFixture.fulltime = "-"
//
//                                if n < sr {
//                                    newFixture.home_Team = hteams[n-start+1]
//                                    newFixture.away_Team = ateams[n-start+1]
//                                } else {
//                                    newFixture.home_Team = "-"
//                                    newFixture.away_Team = "-"
//                                }
//
//                            }
//
//
//                            if newFixture.home_Team == "FYR Macedonia" {
//                                newFixture.home_Team = "N Macedonia"
//                            } else if newFixture.away_Team == "FYR Macedonia"{
//                                newFixture.away_Team = "N Macedonia"
//                            }
//
//                            //Enable Livebar if game is ongoing
//                            if newFixture.status == "1H" || newFixture.status == "HT" || newFixture.status == "2H" || n == temp_voortgang-2+1000*d1 || n == temp_voortgang-1+1000*d2 {
//
//                                livedummy = true
//
//                                let lgame = Livegames(index: n-start, team1: newFixture.home_Team!, goals1: Int(newFixture.home_Goals), team2: newFixture.away_Team!, goals2: Int(newFixture.away_Goals))
//
//                                livegames.append(lgame)
//
//                                print("*******")
//                                print(lgame.index)
//                                print(lgame.team1)
//                                print(lgame.team2)
//                                print(lgame.goals1)
//                                print(lgame.goals2)
//
//                            }
//
//                            PronosA.append(newFixture)
//                            //try self.context.savePronos2()
//
//
//                        }
//
//
//                    } catch {
//
//                        debugPrint(error)
//                    }
//
//                }
//
//                })
//
//                dataTask.resume()
//
//        }
    
    func fixtureParsing () {
            
                PronosA.removeAll()
                livegames.removeAll()
            
                let headers = [
                    "x-rapidapi-key": "a08ffc63acmshbed8df93dae1449p15e553jsnb3532d9d0c9b",
                    "x-rapidapi-host": "api-football-v1.p.rapidapi.com"
                ]

                //403
                let request = NSMutableURLRequest(url: NSURL(string: "https://api-football-v1.p.rapidapi.com/v2/fixtures/league/403?timezone=Europe%2FLondon")! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers

                let session = URLSession.shared
            
                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    
                    
                if error == nil && data != nil {
                    
                        
                let decoder = JSONDecoder()
                        
                do {
                            
                        let start = 262
                        let end = 312
                        
                        // The API will only show new entries for second round when games are fully known. Initially it only goes to 297 (36 first round games)
                    
                        let niveau1 = try decoder.decode(api1.self, from: data!)
                        print("Counter")
                        print(niveau1.api.fixtures.count)
                        
                        for n in start...end {
                            
                            let newFixture = Pronostiek(context: self.context)
                            
                            if n < niveau1.api.fixtures.count {
                            //API entry existing
                            
                                newFixture.fixture_ID = Int32(niveau1.api.fixtures[n].fixture_id)
                                newFixture.round = niveau1.api.fixtures[n].round
                                newFixture.home_Goals = Int16(niveau1.api.fixtures[n].goalsHomeTeam)
                                newFixture.away_Goals = Int16(niveau1.api.fixtures[n].goalsAwayTeam)
                                newFixture.status = niveau1.api.fixtures[n].statusShort
                                
                                let timeStamp = Double(niveau1.api.fixtures[n].event_timestamp)
                                let unixTimeStamp: Double = Double(timeStamp) / 1.0
                                let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
                                let dateFormatt = DateFormatter();
                                dateFormatt.dateFormat = "dd/MM  h:mm"
                                newFixture.time = dateFormatt.string(from: exactDate as Date)
                                
                                //If penalties, we do not allow equal FT scores, so we add 1 goal to team that qualifies
                                if n >= sr && newFixture.status == "PEN" {
                                    
                                    
                                    print("penalties: " + String(n) + " /// " + niveau1.api.fixtures[n].score.penalty)
                                    
                                    if self.penalties(pscore: niveau1.api.fixtures[n].score.penalty) {

                                        newFixture.home_Goals = newFixture.home_Goals + 1

                                    } else {

                                        newFixture.away_Goals = newFixture.away_Goals + 1

                                    }
                                    
                                }
                                
                                newFixture.home_Team = niveau1.api.fixtures[n].homeTeam.team_name
                                newFixture.away_Team = niveau1.api.fixtures[n].awayTeam.team_name
                                newFixture.fulltime = niveau1.api.fixtures[n].score.fulltime
                                
                                //Enable Livebar if game is ongoing
                                if newFixture.status == "1H" || newFixture.status == "HT" || newFixture.status == "2H" {
                                        
                                    livedummy = true
                                    
                                    let lgame = Livegames(index: n-start, team1: newFixture.home_Team!, goals1: Int(newFixture.home_Goals), team2: newFixture.away_Team!, goals2: Int(newFixture.away_Goals))
                                    
                                    livegames.append(lgame)
                                    
                                    print("*******")
                                    print(lgame.team1)
                                    print(lgame.team2)
                                    print(lgame.goals1)
                                    print(lgame.goals2)
                                            
                                }
                            
                            } else {
                                
                                newFixture.fixture_ID = -999
                                
                                if n < qf {
                                    newFixture.round = "Round of 16"
                                } else if n < sf {
                                    newFixture.round = "Quarter Finals"
                                } else if n < f {
                                    newFixture.round = "Semi Finals"
                                } else {
                                    newFixture.round = "Final"
                                }

                                newFixture.home_Goals = -999
                                newFixture.away_Goals = -999
                                newFixture.status = "NS"
                                newFixture.home_Team = "-"
                                newFixture.away_Team = "-"
                                newFixture.fulltime = "-"
                                newFixture.time = ""
                                                                
                            }
                                
                            PronosA.append(newFixture)
                            //try self.context.savePronos2()
                

                        }
                    
                            
                    } catch {
                        
                        debugPrint(error)
                    }
                        
                }
                                
                })
                    
                dataTask.resume()

        }
    
    func standingParsing () {
                
                //Populate standings from FootballAPI
        
                StandingsA.removeAll()
                groupsPlayed.removeAll()
        
                let headers = [
                    "x-rapidapi-key": "a08ffc63acmshbed8df93dae1449p15e553jsnb3532d9d0c9b",
                    "x-rapidapi-host": "api-football-v1.p.rapidapi.com"
                ]

                let request = NSMutableURLRequest(url: NSURL(string: "https://api-football-v1.p.rapidapi.com/v2/leagueTable/403")! as URL,
                                                        cachePolicy: .useProtocolCachePolicy,
                                                    timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers

                let session = URLSession.shared
            
                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    
                    
                if error == nil && data != nil {
                    
                        
                let decoder = JSONDecoder()
                        
                do {
                    
                        let poules: Int = 6
                        let ploegen: Int = 4
                    
                        let niveau2 = try decoder.decode(api2.self, from: data!)
                        
                        for i in 0...poules-1 {
                            
                            
                            var m1: Int = 0
                            
                            
                            for j in 0...ploegen-1 {
                                
                                let newStanding = Standings(group: i+1, rank: niveau2.api.standings[i][j].rank, team: niveau2.api.standings[i][j].teamName, gamesPlayed: niveau2.api.standings[i][j].all.matchsPlayed)
                                
                                if newStanding.team == "FYR Macedonia" {
                                    newStanding.team = "N Macedonia"
                                }
                                
                                StandingsA.append(newStanding)
                            
                                m1 = m1 + newStanding.gamesPlayed
                                //temp
                                //m1 = m1 + Int.random(in: 0..<4)
                                    
                            }
                            
                            self.groupsPlayed.append(m1)

                        }
                    
                        //Populate Third place group (six teams from six groups), which we call Group 7
                        for j in 0...5 {
                        
                            
                            let newStanding = Standings(group: poules+1, rank: niveau2.api.standings[poules][j].rank, team: niveau2.api.standings[poules][j].teamName, gamesPlayed: niveau2.api.standings[poules][j].all.matchsPlayed)
                            
                            if newStanding.team == "FYR Macedonia" {
                                newStanding.team = "N Macedonia"
                            }
                            
                            StandingsA.append(newStanding)
                                
                            
                        }
                    
                            
                    } catch {
                        
                        debugPrint(error)
                    }
                        
                }
                                
                })
                    
                dataTask.resume()
            

        }
    
    func qualbest2 () -> [String] {
    // Populates best two teams from each group
        
        var qbest: [String] = []
        
        for i in 0...StandingsA.count-1 {
            
            if StandingsA[i].rank == 1 || StandingsA[i].rank == 2 {
                
                let qteam: String = StandingsA[i].team
                qbest.append(qteam)
                
            }
            
        }
        
        return qbest
        
        
    }
    
    func qualbest3 () -> [String] {
    // Populates best thirds
        
        var qbest: [String] = []
        
        for i in 0...StandingsA.count-1 {
            
            if StandingsA[i].group == 7 {
                
                let qteam: String = StandingsA[i].team
                qbest.append(qteam)
                
            }
            
        }
        
        return qbest
        
        
    }
    
    func scoreView (view1: UIScrollView) {
        
            
        if dummy == 0 {
  
            routine()
            
        }
        
        createlabels(view1: view1)
        view1.contentSize = CGSize(width: view1.frame.width, height: view1.frame.height * CGFloat(Double(PronosB.count + 3) * 0.05))
        
        dummy = 1
        
    }
    
    
    func createlabels(view1: UIScrollView) {
    
        
        let br = view1.bounds.width
        let ho = view1.bounds.height
        
        // decal1 voor stand, decal2 voor prono/last
        var decal1:CGFloat = 0.0
        var decal2:CGFloat = 0.0
        var decal3:CGFloat = 0.0
        
        if livegames.count == 2 {
        //Two games ongoing
            decal1 = 0.50
            decal2 = 0.70
            decal3 = 0.28
        } else {
        //No games or just 1
           decal1 = 0.65
           decal2 = 0.85
           decal3 = 0.40
        }
        
        let label0 = UILabel(frame: CGRect(x: br * 0.05, y: ho * 0, width: br * 0.10, height: ho * 0.05))
        let label1 = UILabel(frame: CGRect(x: br * 0.20, y: ho * 0, width: br * decal3, height: ho * 0.05))
        let label2 = UILabel(frame: CGRect(x: br * decal1, y: ho * 0, width: br * 0.20, height: ho * 0.05))
        let label3 = UILabel(frame: CGRect(x: br * decal2, y: ho * 0, width: br * 0.12, height: ho * 0.05))
        let label4 = UILabel(frame: CGRect(x: br * 0.85, y: ho * 0, width: br * 0.12, height: ho * 0.05))
  
        label0.textAlignment = NSTextAlignment.center
        label0.text = "Rank"
        label0.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        //label0.textColor = .black
        label0.adjustsFontSizeToFitWidth = true

        view1.addSubview(label0)
        
        label1.textAlignment = NSTextAlignment.left
        label1.text = "Naam"
        label1.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        //label1.textColor = .black
        label1.adjustsFontSizeToFitWidth = true
        view1.addSubview(label1)
                            
        label2.textAlignment = NSTextAlignment.center
        label2.text = "Stand"
        label2.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        //label2.textColor = .black
        label2.adjustsFontSizeToFitWidth = true
        view1.addSubview(label2)
        
        label3.textAlignment = NSTextAlignment.center
        
        if livegames.count == 0 {
            label3.text = "Recent"
        } else if livegames.count == 1  {
            label3.text = "Prono"
        } else if livegames.count == 2 {
            label3.text = "P1"
        }
        
        label3.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label3.textColor = .black
        label3.adjustsFontSizeToFitWidth = true
        
        view1.addSubview(label3)
        
        label4.textAlignment = NSTextAlignment.center
        label4.text = "P2"
        label4.font = UIFont.boldSystemFont(ofSize: 15.0)
        label4.adjustsFontSizeToFitWidth = true
        //label4.textColor = .black
        
        if livegames.count == 2 {
            view1.addSubview(label4)
        }
        
        
        for i in 0...pr-1 {
            
            let label0 = UILabel(frame: CGRect(x: br * 0.05, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.10, height: ho * 0.05))
            
            let label1 = UILabel(frame: CGRect(x: br * 0.20, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * decal3, height: ho * 0.05))
            
            let label2 = UILabel(frame: CGRect(x: br * decal1, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.20, height: ho * 0.05))
            
            let label3 = UILabel(frame: CGRect(x: br * decal2, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.12, height: ho * 0.05))
            
            let label4 = UILabel(frame: CGRect(x: br * 0.85, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.12, height: ho * 0.05))
            
            label0.textAlignment = NSTextAlignment.center
            //label1.text = PronosB[i][0].user
            label0.text = String(i + 1)
            label0.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            //label0.textColor = .black
            view1.addSubview(label0)
  
            label1.textAlignment = NSTextAlignment.left
            //label1.text = PronosB[i][0].user
            label1.text = scores[i].user
            label1.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            //label1.textColor = .black
            view1.addSubview(label1)
                                
            label2.textAlignment = NSTextAlignment.center
            label2.text = String(scores[i].punten)
            label2.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            //label2.textColor = .black
            view1.addSubview(label2)
            
            label3.textAlignment = NSTextAlignment.center
            label4.textAlignment = NSTextAlignment.center

            if livegames.count == 1 {
                
                if livegames[0].index < ind[0] {
                // 1st round games
                
                    let temp1: String = String(PronosB[scores[i].index][livegames[0].index].home_Goals)
                    let temp2: String = String(PronosB[scores[i].index][livegames[0].index].away_Goals)
                    let temp3: String = temp1 + "-" + temp2
                    label3.text = temp3
                    
                    let temp4: String = String(PronosA[livegames[0].index].home_Goals)
                    let temp5: String = String(PronosA[livegames[0].index].away_Goals)
                    let temp6: String = temp4 + "-" + temp5
                    
                    let burn1:Bool = burn(hgp: Int(temp1)!, agp: Int(temp2)!, hgr: Int(temp4)!, agr: Int(temp5)!)
                    
                    if temp3 == temp6 {
                        label3.textColor = .green
                        label3.backgroundColor = .black
                    } else if burn1 {
                        label3.textColor = .gray
                    } else {
                        //label3.textColor = .black
                    }
                    
                    
                } else {
                // 2nd round
                    
                    let VC2 = ViewController2()
                    let QualText:[String] = VC2.secondround(game: livegames[0].index, user: scores[i].index, rteam1: PronosA[livegames[0].index].home_Team!, rteam2: PronosA[livegames[0].index].away_Team!)
    
                    if QualText[0] == livegames[0].team1 {
                    // Perfect guess
                        
                        let temp3 = QualText[1] + "-" + QualText[2]
                        label3.text = temp3
                        
                        let temp4: String = String(PronosA[livegames[0].index].home_Goals)
                        let temp5: String = String(PronosA[livegames[0].index].away_Goals)
                        let temp6: String = temp4 + "-" + temp5
                        
                        if temp3 == temp6 {
                            label3.textColor = .green
                            label3.backgroundColor = .black
                        } else {
                            label3.textColor = .white
                            label3.backgroundColor = .darkGray
                            label3.font = UIFont.boldSystemFont(ofSize: 15)
                        }
                        
                    } else {
                        
                        label3.text = transferString(Astrings: QualText)
                        
                        if label3.text == "X2" {
                            
                            label3.backgroundColor = .black
                            label3.textColor = .white
                            
                        }
                        
                    }

                    
                }
            
                
            } else if livegames.count == 2 {
                
                if livegames[0].index < ind[0] {
                // 1st round games
                
                    let temp1: String = String(PronosB[scores[i].index][livegames[0].index].home_Goals)
                    let temp2: String = String(PronosB[scores[i].index][livegames[0].index].away_Goals)
                    let temp3: String = temp1 + "-" + temp2
                    label3.text = temp3
                    
                    let temp7: String = String(PronosB[scores[i].index][livegames[1].index].home_Goals)
                    let temp8: String = String(PronosB[scores[i].index][livegames[1].index].away_Goals)
                    let temp9: String = temp7 + "-" + temp8
                    label4.text = temp9
                    
                    let temp4: String = String(PronosA[livegames[0].index].home_Goals)
                    let temp5: String = String(PronosA[livegames[0].index].away_Goals)
                    let temp6: String = temp4 + "-" + temp5
                    
                    let temp10: String = String(PronosA[livegames[1].index].home_Goals)
                    let temp11: String = String(PronosA[livegames[1].index].away_Goals)
                    let temp12: String = temp10 + "-" + temp11
                    
                    let burn1:Bool = burn(hgp: Int(temp1)!, agp: Int(temp2)!, hgr: Int(temp4)!, agr: Int(temp5)!)
                    
                    let burn2:Bool = burn(hgp: Int(temp7)!, agp: Int(temp8)!, hgr: Int(temp10)!, agr: Int(temp11)!)
                    
                    if temp3 == temp6 {
                        label3.textColor = .green
                        label3.backgroundColor = .black
                    } else if burn1 {
                        label3.textColor = .gray
                    } else {
                        //label3.textColor = .black
                    }
                    
                    if temp9 == temp12 {
                        label4.textColor = .green
                        label4.backgroundColor = .black
                    } else if burn2 {
                        label4.textColor = .gray
                    } else {
                        //label4.textColor = .black
                    }
                    
                } else {
                // 2nd round
                    
                    let VC2 = ViewController2()
                    let QualText:[String] = VC2.secondround(game: livegames[0].index, user: scores[i].index, rteam1: PronosA[livegames[0].index].home_Team!, rteam2: PronosA[livegames[0].index].away_Team!)
                    
                    let QualText2:[String] = VC2.secondround(game: livegames[1].index, user: scores[i].index, rteam1: PronosA[livegames[1].index].home_Team!, rteam2: PronosA[livegames[1].index].away_Team!)
    
                    if QualText[0] == livegames[0].team1 {
                    // Perfect guess
                        
                        let temp3 = QualText[1] + "-" + QualText[2]
                        label3.text = temp3
                        
                        let temp4: String = String(PronosA[livegames[0].index].home_Goals)
                        let temp5: String = String(PronosA[livegames[0].index].away_Goals)
                        let temp6: String = temp4 + "-" + temp5
                        
                        if temp3 == temp6 {
                            label3.textColor = .green
                            label3.backgroundColor = .black
                        } else {
                            label3.textColor = .white
                            label3.backgroundColor = .darkGray
                            label3.font = UIFont.boldSystemFont(ofSize: 15)
                        }
                        
                    } else {
                        
                        label3.text = transferString(Astrings: QualText)
                        
                        if label3.text == "X2" {
                            
                            label3.backgroundColor = .black
                            label3.textColor = .white
                            
                        }
                        
                    }

                    if QualText2[0] == livegames[1].team1 {
                    // Perfect guess
                        
                        let temp9 = QualText2[1] + "-" + QualText2[2]
                        label4.text = temp9
                        
                        let temp10: String = String(PronosA[livegames[1].index].home_Goals)
                        let temp11: String = String(PronosA[livegames[1].index].away_Goals)
                        let temp12: String = temp10 + "-" + temp11
                        
                        if temp9 == temp12 {
                            label4.textColor = .green
                            label4.backgroundColor = .black
                        } else {
                            label4.textColor = .white
                            label4.backgroundColor = .darkGray
                            label4.font = UIFont.boldSystemFont(ofSize: 15)
                        }
                        
                    } else {
                        
                        label4.text = transferString(Astrings: QualText2)
                        
                        if label4.text == "X2" {
                            
                            label4.backgroundColor = .black
                            label4.textColor = .white
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                if lastgame1 == -1 {
                    label3.text = "-"
                } else {
                    label3.text = laatstepunten(speler: PronosB[scores[i].index], game: lastgame1)
                }
                
            }

            //label3.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            
            view1.addSubview(label3)
            
            if livegames.count == 2 {
                
                view1.addSubview(label4)
                
            }
            
        }
        
    }
    
    func burn(hgp: Int, agp: Int, hgr: Int, agr: Int) -> Bool {
        
        var dummy:Bool = false
        
        if hgr > agr {
            
            if hgp < agp || hgp == agp {
                
                dummy = true
                
            }
            
        } else if hgr < agr {
            
            if hgp > agp || hgp == agp {
                
                dummy = true
                
            }
            
        } else if hgr == agr {
            
            if hgp > agp || hgp < agp {
                
                dummy = true
                
            }
            
        }
        
        return dummy
        
    }
    
    func transferString(Astrings: [String]) -> String {
        
        var Svalue:String = ""
        
        if Astrings[0] != "" {
            
            Svalue = "Q1"
            
            if Astrings[3] != "" {
             
                Svalue = "X2"
            
            }
                
        } else if Astrings[3] != "" {
            
            Svalue = "Q2"
            
            if Astrings[0] != "" {
             
                Svalue = "X2"
            
            }
                
        }
        
        return Svalue
        
    }
    
    func puntenSommatie (z: Int, speler: [Pronostiek]) -> Int {
        
        var som:Int = 0
        
        for l in 0...z {
            
            som = som + Int(speler[l].statistiek?.punten ?? 0)
            
        }
        
        return som
        
    }
    
    func laatstepunten (speler: [Pronostiek], game: Int) -> String {
        
        var str:String
        
        str = String(speler[game].statistiek?.punten ?? 0)
        
        if str == "0" {
            
            str = ""
            
        } else {
            
            str = "+ " + str
        }
        
        return str
        
    }

    
    func calc_simple (hg_p: Int, ag_p: Int, hg_r: Int, ag_r: Int) -> Int {
        
        var punten: Int = 0
        
        if hg_r >= 0 {
        
            if hg_r > ag_r && hg_p > ag_p {
                
                punten = punten + 1
                
                if hg_r == hg_p {
                    
                    punten = punten + 1
                    
                }
                
                if ag_r == ag_p {
                    
                    punten = punten + 1
                    
                }
                
            }

            if hg_r < ag_r && hg_p < ag_p {
                
                punten = punten + 1
                
                if hg_r == hg_p {
                    
                    punten = punten + 1
                    
                }
                
                if ag_r == ag_p {
                    
                    punten = punten + 1
                    
                }
                     
            }

            if hg_r == ag_r && hg_p == ag_p {
                
                punten = punten + 1
                
                if hg_r == hg_p {
                    
                    punten = punten + 2
                    
                }
                     
            }
        
        }
        
        return punten
        
        
    }
    
    func calc_ext (round: Int, game: Int, speler: [Pronostiek], start: Int, end: Int ) -> Int {
        
        var punten: Int = 0
        var dcheck: Int = 0
        
        let homegoals_real: Int = Int(PronosA[game].home_Goals)
        let awaygoals_real: Int = Int(PronosA[game].away_Goals)
        let hometeam_real: String = PronosA[game].home_Team!
        let awayteam_real: String = PronosA[game].away_Team!
        
        var homegoals_prono: Int = 0
        var awaygoals_prono: Int = 0
        var hometeam_prono: String = ""
        var awayteam_prono: String = ""
        
        //Points for guessing right teams in round
        for i in start...end {
        
            dcheck = 0
            
            if hometeam_real == speler[i].home_Team {
                
                punten = punten + round
                homegoals_prono = Int(speler[i].home_Goals)
                hometeam_prono = speler[i].home_Team!
                dcheck = 1
                
            } else if hometeam_real == speler[i].away_Team {
                
                punten = punten + round
                homegoals_prono = Int(speler[i].away_Goals)
                hometeam_prono = speler[i].away_Team!
                dcheck = 1
            
            }
            
            if awayteam_real == speler[i].away_Team {
                
                punten = punten + round
                awaygoals_prono = Int(speler[i].away_Goals)
                awayteam_prono = speler[i].away_Team!
                dcheck = dcheck + 1
                
            } else if awayteam_real == speler[i].home_Team {
                
                punten = punten + round
                awaygoals_prono = Int(speler[i].home_Goals)
                awayteam_prono = speler[i].home_Team!
                dcheck = dcheck + 1
            
            }
            
            if dcheck == 2 {
                
                punten = punten + calc_simple(hg_p: homegoals_prono, ag_p: awaygoals_prono, hg_r: homegoals_real, ag_r: awaygoals_real)
                
            }
            
            if round == 6 {
                
                if homegoals_real > awaygoals_real && homegoals_prono > awaygoals_prono {
                    
                    punten = punten + 10
                    
                } else if homegoals_real < awaygoals_real && homegoals_prono < awaygoals_prono {
                    
                    punten = punten + 10
                    
                }
                
            }
            
        }
        
//        if speler[0].user == "Player 2" {
//
//            print(hometeam_real + " - " + awayteam_real + "    " + String(homegoals_real) + "-" + String(awaygoals_real))
//
//            print(hometeam_prono + " - " + awayteam_prono + "    " + String(homegoals_prono) + "-" + String(awaygoals_prono))
//
//            print("round " + String(round) + " punten " + String(punten))
//
//            print("//")
//
//        }
        
        return punten
        
        
    }
    
    func kwalificatieR (speler: [Pronostiek], start: Int, end: Int) -> [String] {
    
        //Create a string matrix with all qualifiers from prediction
        
        var qualifiers = [String]()
        
        for i in start...end {
        
            if speler[i].home_Goals > speler[i].away_Goals {
                
                let kf: String = speler[i].home_Team!
                qualifiers.append(kf)
                
            } else if speler[i].home_Goals < speler[i].away_Goals {
                
                let kf: String = speler[i].away_Team!
                qualifiers.append(kf)
            
            } else {

                let kf: String = "Unknown"
                qualifiers.append(kf)
                
            }
            
        }
        
        return qualifiers
        
    }
    
    func kwalificatie16 (speler: [Pronostiek], start: Int, end: Int) -> [String] {
    
        //Create a string matrix with all qualifiers from prediction (case round of 16)
        
        var qualifiers = [String]()
        
        for i in start...end {
        
            let kf1: String = speler[i].home_Team!
            let kf2: String = speler[i].away_Team!
            
            qualifiers.append(kf1)
            qualifiers.append(kf2)
            
        }
        
        return qualifiers
        
    }
    
    
    func calc_ext2 (round: Int, game: Int, speler: [Pronostiek], start: Int, end: Int) -> Int {
            
        
        var punten: Int = 0
        var dcheck: Int = 0
        
        let homegoals_real: Int = Int(PronosA[game].home_Goals)
        let awaygoals_real: Int = Int(PronosA[game].away_Goals)
        let hometeam_real: String = PronosA[game].home_Team!
        let awayteam_real: String = PronosA[game].away_Team!
        
        var homegoals_prono: Int = 0
        var awaygoals_prono: Int = 0
        var hometeam_prono: String = ""
        var awayteam_prono: String = ""
        
        let kwalnextround: [String] = kwalificatieR(speler: speler, start: start, end: end)
        //Populate matrix with qualifying teams in prediction next round
        
        var qualProno: String = ""
        //Qualifying team in tournament
        
        if homegoals_real > awaygoals_real {
            
            qualProno = hometeam_real
            
        } else if homegoals_real < awaygoals_real {
            
            qualProno = awayteam_real
            
        }
        
        //Check if game has been exactly predicted
        for i in start...end {
        
            dcheck = 0
            
            if hometeam_real == speler[i].home_Team {
                
                homegoals_prono = Int(speler[i].home_Goals)
                hometeam_prono = speler[i].home_Team!
                dcheck = 1
                
            } else if hometeam_real == speler[i].away_Team {
                
                homegoals_prono = Int(speler[i].away_Goals)
                hometeam_prono = speler[i].away_Team!
                dcheck = 1
            
            }
            
            if awayteam_real == speler[i].away_Team {
                
                awaygoals_prono = Int(speler[i].away_Goals)
                awayteam_prono = speler[i].away_Team!
                dcheck = dcheck + 1
                
            } else if awayteam_real == speler[i].home_Team {
                
                awaygoals_prono = Int(speler[i].home_Goals)
                awayteam_prono = speler[i].home_Team!
                dcheck = dcheck + 1
            
            }
            
            if dcheck == 2 {
                
                punten = punten + calc_simple(hg_p: homegoals_prono, ag_p: awaygoals_prono, hg_r: homegoals_real, ag_r: awaygoals_real)
                
            }
            
        }
        
        print("Test----")
        print(kwalnextround.count)
        
        // Give points for qualifying next round
        for i in 0...end-start {
            
            print(kwalnextround[i])
            if qualProno == kwalnextround[i] {
                punten = punten + round
            }
            
        }
        
        return punten
        
    }
    
    func calc_ext3 (round: Int, game: Int, speler: [Pronostiek], start: Int, end: Int) -> Int {
    
        // Third Group
        // Last third group games for all groups
        let aa: Int = 25
        let bb: Int = 29
        let cc: Int = 27
        let dd: Int = 31
        let ee: Int = 33
        let ff: Int = 35
        
        let lastgames: [Int] = [aa, bb, cc, dd, ee, ff]
        
        var punten: Int = 0
        
        let homegoals_real: Int = Int(PronosA[game].home_Goals)
        let awaygoals_real: Int = Int(PronosA[game].away_Goals)
        let hometeam_real: String = PronosA[game].home_Team!
        let awayteam_real: String = PronosA[game].away_Team!
        
        let homegoals_prono: Int = Int(speler[game].home_Goals)
        let awaygoals_prono: Int = Int(speler[game].away_Goals)
        let hometeam_prono: String = speler[game].home_Team!
        let awayteam_prono: String = speler[game].away_Team!
        
        
        if lastgames.contains(game) && PronosA[game].status != "NS" {
        // Last group game, then check for qualifiers
            
            let group: [String] = [PronosA[game].home_Team!, PronosA[game].away_Team!, PronosA[game-1].home_Team!, PronosA[game-1].away_Team!]
            
            for i in start...end {
                
                if qual16.contains(speler[i].home_Team!) && group.contains(speler[i].home_Team!) {
                    
                    punten = punten + round
                    
                }

                if qual16.contains(speler[i].away_Team!) && group.contains(speler[i].away_Team!) {
                    
                    punten = punten + round
                    
                }
                
            }
            
            if game == ff {
            //Last first round game best four thirds qualification is allocated
                
                for i in start...end {
                    
                    if qual16_3.contains(speler[i].home_Team!) {
                        
                        punten = punten + round
                        
                    }

                    if qual16_3.contains(speler[i].away_Team!) {
                        
                        punten = punten + round
                        
                    }
                    
                }
                
                
            }
            
        }

        
        punten = punten + calc_simple(hg_p: homegoals_prono, ag_p: awaygoals_prono, hg_r: homegoals_real, ag_r: awaygoals_real)
                
        return punten
        
    }
    
    func calculator (speler: [Pronostiek]) {
        
        let teller3:Int = 24
        // Index start of third group game
        
        let tellerA:Int = 36
        // Index start of round best of 16
        
        let tellerQ:Int = 44
        // Index start of round quarter finals

        let tellerS:Int = 48
        // Index start of round semi finals
   
        let tellerF:Int = 50
        // Index start of round final
        
        for j in 0...ga-1 {
            
            //reset punten voor elke match
            var punten:Int = 0
            
            let homegoals_real: Int = Int(PronosA[j].home_Goals)
            let awaygoals_real: Int = Int(PronosA[j].away_Goals)
            let homegoals_prono: Int = Int(speler[j].home_Goals)
            let awaygoals_prono: Int = Int(speler[j].away_Goals)
    
            if j < teller3 {
                
                //First 2 group matches
                punten = punten + calc_simple(hg_p: homegoals_prono, ag_p: awaygoals_prono, hg_r: homegoals_real, ag_r: awaygoals_real)
                
//                if speler[0].user == "Player 2" {
//
//                    print(PronosA[j].home_Team! + " - " + PronosA[j].away_Team!)
//                    print(String(homegoals_real) + "-" + String(awaygoals_real))
//
//                    print(speler[j].home_Team! + " - " + speler[j].away_Team!)
//                    print(String(homegoals_prono) + "-" + String(awaygoals_prono))
//
//                    print(" punten " + String(punten))
//
//                    print("//")
//
//                }

            } else if j < tellerA {
                
                //Third group game
                punten = punten + calc_ext3(round: 3,game: j, speler: speler, start: tellerA, end: tellerQ-1)
                
            } else if j < tellerQ {
                
                //Best of 16
                punten = punten + calc_ext2(round: 4,game: j, speler: speler, start: tellerA, end: tellerQ-1)
                
            } else if j < tellerS {
                
                //Quarter finals
                punten = punten + calc_ext2(round: 5,game: j, speler: speler, start: tellerQ, end: tellerS-1)
               
            } else if j < tellerF {
                
                //semi finals
                punten = punten + calc_ext2(round: 6,game: j, speler: speler, start: tellerS, end: tellerF-1)
                
            } else if j == ga-1 {
                
                //Final
                punten = punten + calc_ext2(round: 10,game: j, speler: speler, start: tellerF, end: ga-1)
               
            }
            
            //toewijzen van punten
            let stat = Statistiek(context: context)
            stat.punten = Int16(punten)
            stat.user = speler[j].user
            
            speler[j].statistiek = stat
            
        }
        
    }
    
    func routine () {
               
        scores.removeAll()
        
        for i in 0...pr-1 {
            
            calculator(speler: PronosB[i])
            
            let newscore = Scores(user: (PronosB[i].first?.user)! , punten: puntenSommatie(z: ga-1, speler: PronosB[i]), index: i)

            scores.append(newscore)
            
        }
        
        scores = scores.sorted(by: { ($0.punten) > ($1.punten) })
        //PronosB = PronosB.sorted(by: { ($0.last?.statistiek!.punten)! > ($1.last?.statistiek!.punten)! })
        
        for i in 0...pr-1 {
            
            scores[i].ranking = i
            print(scores[i].ranking)
            print(scores[i].index)
            
        }
        
        
    }
    
    func realpronos () {
        
        var gebruikers: [String] = []
        var homeTeams: [String] = []
        var awayTeams: [String] = []
        
        guard let filepath = Bundle.main.path(forResource: "EK 2021 xcode1", ofType: "xlsx") else {

            fatalError("Error n1")
        }

        guard let file = XLSXFile(filepath: filepath) else {
          fatalError("XLSX file at \(filepath) is corrupted or does not exist")
        }

        for wbk in try! file.parseWorkbooks() {
            for (name, path) in try! file.parseWorksheetPathsAndNames(workbook: wbk) {
            if let worksheetName = name {
              print("This worksheet has a name: \(worksheetName)")
            }

            let worksheet = try! file.parseWorksheet(at: path)
                
            if let sharedStrings = try! file.parseSharedStrings() {
              let columnAStrings = worksheet.cells(atColumns: [ColumnReference("A")!])
                .compactMap { $0.stringValue(sharedStrings) }
            
                gebruikers = columnAStrings
    
            }
                
            if let sharedStrings = try! file.parseSharedStrings() {
              let columnCStrings = worksheet.cells(atColumns: [ColumnReference("C")!])
                .compactMap { $0.stringValue(sharedStrings) }
            
                homeTeams = columnCStrings
    
            }
            
            if let sharedStrings = try! file.parseSharedStrings() {
              let columnDStrings = worksheet.cells(atColumns: [ColumnReference("D")!])
                .compactMap { $0.stringValue(sharedStrings) }
            
                awayTeams = columnDStrings
    
            }
            
            print(gebruikers[0])
            print(gebruikers[1])
            
            PronosB.removeAll()
                    
            for i in 0...pr-1 {
                
                // Loop players
                
                let newArrayFixtures = [Pronostiek(context: self.context)]
                PronosB.append(newArrayFixtures)
                
                PronosB[i][0].user = gebruikers[1 + ga*i]
                PronosB[i][0].fixture_ID = PronosA[0].fixture_ID
                PronosB[i][0].round = PronosA[0].round
                PronosB[i][0].home_Goals = Int16((worksheet.data?.rows[1 + ga*i].cells[4].value)!)!
                PronosB[i][0].away_Goals = Int16((worksheet.data?.rows[1 + ga*i].cells[5].value)!)!
                PronosB[i][0].home_Team = homeTeams[1 + ga*i]
                PronosB[i][0].away_Team = awayTeams[1 + ga*i]
                
                for n in 1...ga-1 {
                    
                    // Loop games
                    let newFixture = Pronostiek(context: self.context)
                    newFixture.user = gebruikers[(n+1) + ga*i]
                    newFixture.fixture_ID = PronosA[n].fixture_ID
                    newFixture.round = PronosA[n].round
                    newFixture.home_Goals = Int16((worksheet.data?.rows[(n+1) + ga*i].cells[4].value)!)!
                    newFixture.away_Goals = Int16((worksheet.data?.rows[(n+1) + ga*i].cells[5].value)!)!
                    newFixture.home_Team = homeTeams[(n+1) + ga*i]
                    newFixture.away_Team = awayTeams[(n+1) + ga*i]
                    PronosB[i].append(newFixture)
                    
                }
                
            }
            
          }
        }
    }
    
//    func Realtest () -> ([String], [String], [Int], [Int]) {
//
//        //Populate PronosB with Excel data
//
//
//        var homeTeams: [String] = []
//        var awayTeams: [String] = []
//        var homeGoals: [Int] = []
//        var awayGoals: [Int] = []
//
//
//        guard let filepath = Bundle.main.path(forResource: "EK 2021 xcode - simul", ofType: "xlsx") else {
//
//            fatalError("Error n1")
//        }
//
//        guard let file = XLSXFile(filepath: filepath) else {
//          fatalError("XLSX file at \(filepath) is corrupted or does not exist")
//        }
//
//        for wbk in try! file.parseWorkbooks() {
//            for (name, path) in try! file.parseWorksheetPathsAndNames(workbook: wbk) {
//            if let worksheetName = name {
//              print("This worksheet has a name: \(worksheetName)")
//            }
//
//            let worksheet = try! file.parseWorksheet(at: path)
//
//            if let sharedStrings = try! file.parseSharedStrings() {
//              let columnCStrings = worksheet.cells(atColumns: [ColumnReference("C")!])
//                .compactMap { $0.stringValue(sharedStrings) }
//
//                homeTeams = columnCStrings
//
//            }
//
//            if let sharedStrings = try! file.parseSharedStrings() {
//              let columnDStrings = worksheet.cells(atColumns: [ColumnReference("D")!])
//                .compactMap { $0.stringValue(sharedStrings) }
//
//                awayTeams = columnDStrings
//
//            }
//
//                for i in 0...ga-1 {
//
//                    homeGoals.append(Int((worksheet.data?.rows[i+1].cells[4].value)!)!)
//                    awayGoals.append(Int((worksheet.data?.rows[i+1].cells[5].value)!)!)
//
//                }
//
//          }
//        }
//
//        return (homeTeams, awayTeams, homeGoals, awayGoals)
//
//    }
    
    func penalties (pscore: String) -> Bool {
        
        let delim: String = "-"
        let token =  pscore.components(separatedBy: delim)

        let phg: Int = Int(token[0])!
        let pag: Int = Int(token[1])!
        
        return phg > pag
        
    }
    
    func upperbar(text: String, size: CGFloat) {
        
        
        let bar1 = UIView()
        bar1.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * size)
        bar1.backgroundColor = .systemRed
        //bar1.backgroundColor = UIColor.init(red: 0, green: 209/255, blue: 255/255, alpha: 0.75)
        view.addSubview(bar1)
        
        let chevronLeft = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        let chevronRight = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .heavy))
        
        let title = UILabel(frame: CGRect(x: bar1.frame.width * 0.3, y: bar1.frame.height * 0.45, width: bar1.frame.width * 0.4, height: bar1.frame.height * 0.35))
        
        title.text = text
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
        
    }
    
    func mainview (livebar: Bool, size: CGFloat) -> UIView {
        
        let mainview = UIView()
        
//        if livebar {
            
        let lbview = UIView()
        lbview.frame = CGRect(x: 0, y: view.frame.height * size, width: view.frame.width, height: view.frame.height * size * 0.7)
        //lbview.backgroundColor = .black
        view.addSubview(lbview)
        
        mainview.frame = CGRect(x: 0, y: view.frame.height * size * 1.7, width: view.frame.width, height: view.frame.height * (1 - size * 1.7))
            

//
//
//        } else {
//
//            mainview.frame = CGRect(x: 0, y: view.frame.height * size, width: view.frame.width, height: view.frame.height * (1 - size))
//
//        }
        
        //view.addSubview(mainview)
    
        return mainview
        
    }

    func livebar (size: CGFloat) -> UIView {
        
        let livebar = UIView()

        livebar.frame = CGRect(x: 0, y: view.frame.height * size, width: view.frame.width, height: view.frame.height * size * 0.7)
        
        var updateimg = UIImage(named: "Record")
        
        var w1: CGFloat = livebar.frame.width * 0.08
        var h1: CGFloat = min(w1, livebar.frame.height * 0.90)
        var x1: CGFloat = livebar.frame.width * 0.85
        
        if livegames.count > 0 {
            livebar.backgroundColor = .black
        } else {
            livebar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 80/255, alpha: 1)
            updateimg = UIImage(named: "bluebutton3")
            h1 = min(w1, livebar.frame.height * 0.98)
            w1 = livebar.frame.width * 0.08
            x1 = livebar.frame.width * 0.85
        }
        
        //let updateimg = UIImage(systemName: "arrow.triangle.2.circlepath.circle")
        
        let updatebtn = UIButton(type: .custom)
    
        updatebtn.frame = CGRect(x: x1, y: (livebar.frame.height - h1) * 0.5, width: w1, height: h1)

        updatebtn.setImage(updateimg, for: UIControl.State.normal)
        updatebtn.tintColor = .white
        //updatebtn.addTarget(self, action: #selector(arrowleft), for: .touchUpInside)
        
        updatebtn.addTarget(self, action: #selector(btnclicked), for: .touchUpInside)
        print("Live")
        print(livegames.count)
        
        if livegames.count == 1 {
        // A single game is being played
            
            newlabel(view1: livebar, x: 0.02, y: 0.4, width: 0.35, height: 0.3, text: livegames[0].team1 + " - " + livegames[0].team2, fontsize: 16.0, center: false, textwhite: true)
            newlabel(view1: livebar, x: 0.50, y: 0.4, width: 0.20, height: 0.3, text: String(livegames[0].goals1) + " - " + String(livegames[0].goals2), fontsize: 16.0, center: true, textwhite: true)
            
            
        } else if livegames.count == 2 {
        // Two games are being played
            
            newlabel(view1: livebar, x: 0.02, y: 0.15, width: 0.35, height: 0.3, text: livegames[0].team1 + " - " + livegames[0].team2, fontsize: 14.0, center: false, textwhite: true)
            newlabel(view1: livebar, x: 0.50, y: 0.15, width: 0.20, height: 0.3, text: String(livegames[0].goals1) + " - " + String(livegames[0].goals2), fontsize: 14.0, center: true, textwhite: true)
            
            newlabel(view1: livebar, x: 0.02, y: 0.5, width: 0.35, height: 0.3, text: livegames[1].team1 + " - " + livegames[1].team2, fontsize: 14.0, center: false, textwhite: true)
            newlabel(view1: livebar, x: 0.50, y: 0.5, width: 0.20, height: 0.3, text: String(livegames[1].goals1) + " - " + String(livegames[1].goals2), fontsize: 14.0, center: true, textwhite: true)
            
        } else {
        // No games ongoing
                        
            let thirdGames: [Int] = [24, 26, 28, 30, 33, 34]
            
            if thirdGames.contains(lastgame1+1) {
            // If next game is third Group gfame then there will be two games played at same time
                newlabel(view1: livebar, x: 0.02, y: 0.15, width: 0.20, height: 0.3, text: PronosA[lastgame1+1].round!, fontsize: 14.0, center: false, textwhite: true)
                newlabel(view1: livebar, x: 0.02, y: 0.50, width: 0.20, height: 0.3, text: PronosA[lastgame1+1].time!, fontsize: 14.0, center: false, textwhite: true)
                newlabel(view1: livebar, x: 0.30, y: 0.15, width: 0.35, height: 0.3, text: PronosA[lastgame1+1].home_Team! + " - " + PronosA[lastgame1+1].away_Team!, fontsize: 14.0, center: false, textwhite: true)
                newlabel(view1: livebar, x: 0.30, y: 0.50, width: 0.35, height: 0.3, text: PronosA[lastgame1+2].home_Team! + " - " + PronosA[lastgame1+2].away_Team!, fontsize: 14.0, center: false, textwhite: true)
                
            } else {
      
                newlabel(view1: livebar, x: 0.02, y: 0.15, width: 0.20, height: 0.3, text: PronosA[lastgame1+1].round!, fontsize: 14.0, center: false, textwhite: true)
                newlabel(view1: livebar, x: 0.02, y: 0.50, width: 0.20, height: 0.3, text: PronosA[lastgame1+1].time!, fontsize: 14.0, center: false, textwhite: true)
                
                newlabel(view1: livebar, x: 0.30, y: 0.4, width: 0.35, height: 0.3, text: PronosA[lastgame1+1].home_Team! + " - " + PronosA[lastgame1+1].away_Team!, fontsize: 16.0, center: false, textwhite: true)
                
            }
        
        }
        
        livebar.addSubview(updatebtn)
    
        return livebar
        
    }
    
    func newlabel (view1: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String, fontsize: CGFloat, center: Bool, textwhite: Bool) {
        
        let label = UILabel(frame: CGRect(x: view1.frame.width * x, y: view1.frame.height * y, width: view1.frame.width * width, height: view1.frame.height * height))
        if center {
            label.textAlignment = NSTextAlignment.center
        } else {
            label.textAlignment = NSTextAlignment.left
        }
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: fontsize)
        if textwhite {
            label.textColor = .white
        }
        if text == "Next" {
            //label.font = UIFont(name: "Arizonia", size: fontsize)
            label.textColor = .systemGray4
        }
        label.adjustsFontSizeToFitWidth = true
        view1.addSubview(label)
        
    }
    
    func scroller () -> UIScrollView {
        
        let mainscroll = UIScrollView()
        
        mainscroll.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)

        mainscroll.showsVerticalScrollIndicator = false
        
        mainscroll.delegate = self
        mainscroll.scrollsToTop = true
        
        return mainscroll
        
    }
    
    func removeSV (viewsv: UIView) {
     
        viewsv.subviews.forEach { (item) in
        item.removeFromSuperview()
        }
        
    }
    
    @objc func btnclicked() {
        
        dummy = 0
        //fixtureParsing_Temp()
        fixtureParsing()
        standingParsing()
        initiate()

    }
    


}

extension UIViewController {
    
    @objc func swipeAction(swipe:UISwipeGestureRecognizer) {
        
        switch swipe.direction.rawValue {
        case 1:
            performSegue(withIdentifier: "goLeft", sender: self)
        case 2:
            performSegue(withIdentifier: "goRight", sender: self)
        default:
            break
        }
        
    }
 
    @objc func arrowleft() {
    
            performSegue(withIdentifier: "goLeft", sender: self)

    }
    
    @objc func arrowright() {
    
            performSegue(withIdentifier: "goRight", sender: self)

    }
    
}


