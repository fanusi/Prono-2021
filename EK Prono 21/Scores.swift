//
//  Scores.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 25/04/2021.
//

import Foundation

class Scores {
    
    var user: String
    var punten: Int
    var index: Int
    var ranking: Int = 0
    //var punten_last: String
    
    init(user: String, punten: Int, index: Int) {
        
        self.user = user
        self.punten = punten
        self.index = index
        
    }
    
}
