//
//  Livegames.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 25/04/2021.
//

import Foundation

class Livegames {
    
    var index: Int
    var team1: String
    var goals1: Int
    var team2: String
    var goals2: Int

    
    init(index: Int, team1: String, goals1: Int, team2: String, goals2: Int) {
        
        self.index = index
        self.team1 = team1
        self.goals1 = goals1
        self.team2 = team2
        self.goals2 = goals2

    }
    
}
