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

public var PronosA = [Pronostiek]()
public var PronosB = [[Pronostiek]]()
// PronosA contains real scores

public var StandingsA = [Standings]()
 
public let b1:CGFloat = 0.12
// Height of upper bar

public let temp_voortgang = 282
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
    
    let pr:Int = 15
    //Number of players
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            fixtureParsing_Temp()
            
        }
        
        //Create views and ranking
        initiate()
        
    }
    
    func initiate() {
        
        removeSV(viewsv: view)
        
        //Add upper bar
        upperbar(text: "Ranking", size: b1)
        
        if PronosA.count > 0 && StandingsA.count > 0 {
            
            // Only load prediction once
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
            if livedummy {
                let lbar = livebar(size: b1)
                view.addSubview(lbar)
            }
            
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
            label1.textColor = .black
            mview.addSubview(label1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
                mview.removeFromSuperview()
                self.initiate()
            
            }
            
        }
        
    }
    
    func fixtureParsing_Temp () {
                
                //Populate PronosA from FootballAPI
            
                PronosA.removeAll()
                livegames.removeAll()
        
                let realtest = Realtest()
        
                let hteams:[String] = realtest.0
                let ateams:[String] = realtest.1
                let hgoals:[Int] = realtest.2
                let agoals:[Int] = realtest.3
            
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
                        print("Counterrrr")
                        print(niveau1.api.fixtures.count)
                        
                        for n in start...end {
                            
                            let newFixture = Pronostiek(context: self.context)
                            
                            if n < niveau1.api.fixtures.count {
                            
                                newFixture.fixture_ID = Int32(niveau1.api.fixtures[n].fixture_id)
                                newFixture.round = niveau1.api.fixtures[n].round
                                
                                //For testing games are simulated
                                if n < temp_voortgang {
                                
                                    newFixture.home_Goals = Int16(hgoals[n-start])
                                    newFixture.away_Goals = Int16(agoals[n-start])
                                    newFixture.status = "FT"
                                    newFixture.fulltime = String(newFixture.home_Goals) + "-" + String(newFixture.away_Goals)
                                
                                } else {
                                
                                    newFixture.home_Goals = -999
                                    newFixture.away_Goals = -999
                                    newFixture.status = "NS"
                                    newFixture.fulltime = "-"
                                    
                                }
                                
                                newFixture.home_Team = hteams[n-start+1]
                                newFixture.away_Team = ateams[n-start+1]
                                
                                if newFixture.home_Team == "FYR Macedonia" {
                                    newFixture.home_Team = "N Macedonia"
                                } else if newFixture.away_Team == "FYR Macedonia"{
                                    newFixture.away_Team = "N Macedonia"
                                }
                                
                                //Enable Livebar if game is ongoing
                                if newFixture.status == "1H" || newFixture.status == "HT" || newFixture.status == "2H" || n == 280 {
                                        
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
    func fixtureParsing () {
                
                //Just for testing via Excel
            
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
                        print("Counterrrr")
                        print(niveau1.api.fixtures.count)
                        
                        for n in start...end {
                            
                            let newFixture = Pronostiek(context: self.context)
                            
                            if n < niveau1.api.fixtures.count {
                            
                                newFixture.fixture_ID = Int32(niveau1.api.fixtures[n].fixture_id)
                                newFixture.round = niveau1.api.fixtures[n].round
                                
                                //For testing games are simulated
                                if n < temp_voortgang {
                                
                                    newFixture.home_Goals = Int16.random(in: 0..<3)
                                    newFixture.away_Goals = Int16.random(in: 0..<3)
                                
                                } else {
                                
                                    newFixture.home_Goals = Int16(niveau1.api.fixtures[n].goalsHomeTeam)
                                    newFixture.away_Goals = Int16(niveau1.api.fixtures[n].goalsAwayTeam)
                                    
                                }
                                
                                newFixture.status = niveau1.api.fixtures[n].statusShort
                                
                                
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
                                if newFixture.status == "1H" || newFixture.status == "HT" || newFixture.status == "2H" || n == 262 {
                                        
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
                            
                            print("")
                            print("Poule " + String(i+1))
                            
                            for j in 0...ploegen-1 {
                                
                                let newStanding = Standings(group: i+1, rank: niveau2.api.standings[i][j].rank, team: niveau2.api.standings[i][j].teamName, gamesPlayed: niveau2.api.standings[i][j].all.matchsPlayed)
                                
                                StandingsA.append(newStanding)
                                
                                
                            }

                        }
                    
                        //Populate Third place group (six teams from six groups), which we call Group 7
                        for j in 0...5 {
                        
                            
                            let newStanding = Standings(group: poules+1, rank: niveau2.api.standings[poules][j].rank, team: niveau2.api.standings[poules][j].teamName, gamesPlayed: niveau2.api.standings[poules][j].all.matchsPlayed)
                            
                            StandingsA.append(newStanding)
                                
                            
                        }
                    
                            
                    } catch {
                        
                        debugPrint(error)
                    }
                        
                }
                                
                })
                    
                dataTask.resume()
            

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
        
        var decal:CGFloat = 0.0
        
        if livedummy {
            decal = 0.65
        } else {
            decal = 0.75
        }
        
        let label0 = UILabel(frame: CGRect(x: br * 0.05, y: ho * 0, width: br * 0.10, height: ho * 0.05))
        let label1 = UILabel(frame: CGRect(x: br * 0.20, y: ho * 0, width: br * 0.40, height: ho * 0.05))
        let label2 = UILabel(frame: CGRect(x: br * decal, y: ho * 0, width: br * 0.20, height: ho * 0.05))
        let label3 = UILabel(frame: CGRect(x: br * 0.85, y: ho * 0, width: br * 0.12, height: ho * 0.05))
  
        label0.textAlignment = NSTextAlignment.center
        label0.text = "Rank"
        label0.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        label0.textColor = .black
        view1.addSubview(label0)
        
        label1.textAlignment = NSTextAlignment.left
        label1.text = "Player"
        label1.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        label1.textColor = .black
        view1.addSubview(label1)
                            
        label2.textAlignment = NSTextAlignment.center
        label2.text = "Stand"
        label2.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        label2.textColor = .black
        view1.addSubview(label2)
        
        label3.textAlignment = NSTextAlignment.center
        label3.text = "Prono"
        label3.font = UIFont.boldSystemFont(ofSize: 15.0)
        //label.backgroundColor = .red
        label3.textColor = .black
        
        if livedummy {
            view1.addSubview(label3)
        }
        
        for i in 0...pr-1 {
            
            let label0 = UILabel(frame: CGRect(x: br * 0.05, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.10, height: ho * 0.05))
            
            let label1 = UILabel(frame: CGRect(x: br * 0.20, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.40, height: ho * 0.05))
            
            let label2 = UILabel(frame: CGRect(x: br * decal, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.20, height: ho * 0.05))
            
            let label3 = UILabel(frame: CGRect(x: br * 0.85, y: ho * 0.05 + ho * 0.05 * CGFloat(i), width: br * 0.12, height: ho * 0.05))
            
            
            label0.textAlignment = NSTextAlignment.center
            //label1.text = PronosB[i][0].user
            label0.text = String(i + 1)
            label0.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            label0.textColor = .black
            view1.addSubview(label0)
  
            label1.textAlignment = NSTextAlignment.left
            //label1.text = PronosB[i][0].user
            label1.text = scores[i].user
            label1.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            label1.textColor = .black
            view1.addSubview(label1)
                                
            label2.textAlignment = NSTextAlignment.center
            label2.text = String(scores[i].punten)
            label2.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            label2.textColor = .black
            view1.addSubview(label2)
            
            label3.textAlignment = NSTextAlignment.center

            if livegames.count > 0 {
                
                let temp1: String = String(PronosB[scores[i].index][livegames[0].index].home_Goals)
                let temp2: String = String(PronosB[scores[i].index][livegames[0].index].away_Goals)
                let temp3: String = temp1 + "-" + temp2
                label3.text = temp3
                
                let temp4: String = String(PronosA[livegames[0].index].home_Goals)
                let temp5: String = String(PronosA[livegames[0].index].away_Goals)
                let temp6: String = temp4 + "-" + temp5
                
                if temp3 == temp6 {
                    label3.textColor = .green
                    label3.backgroundColor = .black
                } else {
                    label3.textColor = .black
                }
                
            } else {
                
                label3.text = ""
                
            }

            label3.font = UIFont.systemFont(ofSize: 15.0)
            //label.backgroundColor = .red
            
            view1.addSubview(label3)
            
        }
        
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
        
        var homegoals_real: Int = 0
        var awaygoals_real: Int = 0
        var hometeam_real: String = ""
        var awayteam_real: String = ""
        
        let homegoals_prono: Int = Int(speler[game].home_Goals)
        let awaygoals_prono: Int = Int(speler[game].away_Goals)
        let hometeam_prono: String = speler[game].home_Team!
        let awayteam_prono: String = speler[game].away_Team!
        
        //Points for guessing right teams in round
        for i in start...end {
        
            dcheck = 0
            
            if hometeam_prono == PronosA[i].home_Team {
                
                punten = punten + round
                homegoals_real = Int(PronosA[i].home_Goals)
                hometeam_real = PronosA[i].home_Team!
                dcheck = 1
                
            } else if hometeam_prono == PronosA[i].away_Team {
                
                punten = punten + round
                homegoals_real = Int(PronosA[i].away_Goals)
                hometeam_real = PronosA[i].away_Team!
                dcheck = 1
            
            }
            
            if awayteam_prono == PronosA[i].away_Team {
                
                punten = punten + round
                awaygoals_real = Int(PronosA[i].away_Goals)
                awayteam_real = PronosA[i].away_Team!
                dcheck = dcheck + 1
                
            } else if awayteam_prono == PronosA[i].home_Team {
                
                punten = punten + round
                awaygoals_real = Int(PronosA[i].home_Goals)
                awayteam_real = PronosA[i].home_Team!
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
        
        if speler[0].user == "Jacob" {
        
            print(hometeam_real + " - " + awayteam_real + "    " + String(homegoals_real) + "-" + String(awaygoals_real))
            
            print(hometeam_prono + " - " + awayteam_prono + "    " + String(homegoals_prono) + "-" + String(awaygoals_prono))
            
            print("round " + String(round) + " punten " + String(punten))
            
            print("//")
            
        }
        
        return punten
        
        
    }
    
    func calculator (speler: [Pronostiek]) {
        
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
    
            if j < tellerA {
                
                //First round
                punten = punten + calc_simple(hg_p: homegoals_prono, ag_p: awaygoals_prono, hg_r: homegoals_real, ag_r: awaygoals_real)
                
                if speler[0].user == "Jacob" {
                
                    print(PronosA[j].home_Team! + " - " + PronosA[j].away_Team!)
                    print(String(homegoals_real) + "-" + String(awaygoals_real))
                    
                    print(speler[j].home_Team! + " - " + speler[j].away_Team!)
                    print(String(homegoals_prono) + "-" + String(awaygoals_prono))
                    
                    print(" punten " + String(punten))
                    
                    print("//")
                    
                }
    
            } else if j < tellerQ {
                
                //Best of 16
                punten = punten + calc_ext(round: 3,game: j, speler: speler, start: tellerA, end: tellerQ-1)
                
            } else if j < tellerS {
                
                //Quarter finals
                punten = punten + calc_ext(round: 4,game: j, speler: speler, start: tellerQ, end: tellerS-1)
               
            } else if j < tellerF {
                
                //semi finals
                punten = punten + calc_ext(round: 5,game: j, speler: speler, start: tellerS, end: tellerF-1)
                
            } else if j == ga-1 {
                
                //Final
                punten = punten + calc_ext(round: 6,game: j, speler: speler, start: tellerF, end: ga-1)
               
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
        
        guard let filepath = Bundle.main.path(forResource: "EK 2021 xcode", ofType: "xlsx") else {

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
    
    func Realtest () -> ([String], [String], [Int], [Int]) {
        
        //Populate PronosB with Excel data
            
        
        var homeTeams: [String] = []
        var awayTeams: [String] = []
        var homeGoals: [Int] = []
        var awayGoals: [Int] = []
        
        
        guard let filepath = Bundle.main.path(forResource: "EK 2021 xcode - simul", ofType: "xlsx") else {

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
              let columnCStrings = worksheet.cells(atColumns: [ColumnReference("C")!])
                .compactMap { $0.stringValue(sharedStrings) }
            
                homeTeams = columnCStrings
    
            }
            
            if let sharedStrings = try! file.parseSharedStrings() {
              let columnDStrings = worksheet.cells(atColumns: [ColumnReference("D")!])
                .compactMap { $0.stringValue(sharedStrings) }
            
                awayTeams = columnDStrings
    
            }
    
                for i in 0...ga-1 {
                    
                    homeGoals.append(Int((worksheet.data?.rows[i+1].cells[4].value)!)!)
                    awayGoals.append(Int((worksheet.data?.rows[i+1].cells[5].value)!)!)
                    
                }
            
          }
        }
        
        return (homeTeams, awayTeams, homeGoals, awayGoals)
        
    }
    
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
        
        if livebar {
            
            let lbview = UIView()
            lbview.frame = CGRect(x: 0, y: view.frame.height * size, width: view.frame.width, height: view.frame.height * size * 0.7)
            lbview.backgroundColor = .black
            view.addSubview(lbview)
            
            mainview.frame = CGRect(x: 0, y: view.frame.height * size * 1.7, width: view.frame.width, height: view.frame.height * (1 - size * 1.7))
            

            
            
        } else {
            
            mainview.frame = CGRect(x: 0, y: view.frame.height * size, width: view.frame.width, height: view.frame.height * (1 - size))
            
        }
        
        //view.addSubview(mainview)
    
        return mainview
        
    }

    func livebar (size: CGFloat) -> UIView {
        
        let livebar = UIView()

        livebar.frame = CGRect(x: 0, y: view.frame.height * size, width: view.frame.width, height: view.frame.height * size * 0.7)
        livebar.backgroundColor = .black
        
        //let updateimg = UIImage(systemName: "arrow.triangle.2.circlepath.circle")
        let updateimg = UIImage(named: "Record")
        let updatebtn = UIButton(type: .custom)
        
        let w1: CGFloat = livebar.frame.width * 0.08
        let h1: CGFloat = min(w1, livebar.frame.height * 0.90)
        
        updatebtn.frame = CGRect(x: livebar.frame.width * 0.85, y: (livebar.frame.height - h1) * 0.5, width: w1, height: h1)

        updatebtn.setImage(updateimg, for: UIControl.State.normal)
        updatebtn.tintColor = .white
        //updatebtn.addTarget(self, action: #selector(arrowleft), for: .touchUpInside)
        
        updatebtn.addTarget(self, action: #selector(btnclicked), for: .touchUpInside)
        print("Live")
        print(livegames.count)
        
        if livegames.count == 1 {
        // A single game is being played
            
            newlabel(view1: livebar, x: 0.02, y: 0.4, width: 0.35, height: 0.3, text: livegames[0].team1 + " - " + livegames[0].team2, fontsize: 16.0, center: false)
            newlabel(view1: livebar, x: 0.50, y: 0.4, width: 0.20, height: 0.3, text: String(livegames[0].goals1) + " - " + String(livegames[0].goals2), fontsize: 16.0, center: true)
            
            
        } else if livegames.count == 2 {
        // Two games are being played
            
            newlabel(view1: livebar, x: 0.02, y: 0.15, width: 0.35, height: 0.3, text: livegames[0].team1 + " - " + livegames[0].team2, fontsize: 14.0, center: false)
            newlabel(view1: livebar, x: 0.50, y: 0.15, width: 0.20, height: 0.3, text: String(livegames[0].goals1) + " - " + String(livegames[0].goals2), fontsize: 14.0, center: true)
            
            newlabel(view1: livebar, x: 0.02, y: 0.5, width: 0.35, height: 0.3, text: livegames[1].team1 + " - " + livegames[1].team2, fontsize: 14.0, center: false)
            newlabel(view1: livebar, x: 0.50, y: 0.5, width: 0.20, height: 0.3, text: String(livegames[1].goals1) + " - " + String(livegames[1].goals2), fontsize: 14.0, center: true)
            
        }
        
        livebar.addSubview(updatebtn)
    
        return livebar
        
    }
    
    func newlabel (view1: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String, fontsize: CGFloat, center: Bool) {
        
        let label = UILabel(frame: CGRect(x: view1.frame.width * x, y: view1.frame.height * y, width: view1.frame.width * width, height: view1.frame.height * height))
        if center {
            label.textAlignment = NSTextAlignment.center
        } else {
            label.textAlignment = NSTextAlignment.left
        }
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: fontsize)
        label.textColor = .white
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
        fixtureParsing_Temp()
        //fixtureParsing()
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


