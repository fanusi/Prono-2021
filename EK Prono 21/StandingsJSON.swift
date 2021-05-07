//
//  StandingsJSON.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 07/05/2021.
//

import Foundation


struct api2: Codable {
    var api: standings
}

struct standings: Codable {
    var standings: [[group]]
}

struct group: Codable {
    
    var rank: Int
    var teamName: String
    var all: MP

    
    enum CodingKeys: String, CodingKey {
           case rank
           case teamName
           case all

       }
       
       // The Initializer function from Decodable
       init(from decoder: Decoder) throws {
           // 1 - Container
           let values = try decoder.container(keyedBy: CodingKeys.self)
           
           // 2 - Normal Decoding
            all = try values.decode(MP.self, forKey: .all)

           
           // 3 - Conditional Decoding
        
            if var rank =  try values.decodeIfPresent(Int.self, forKey: .rank) {
                self.rank = rank
            } else {
                self.rank = -999
            }
        
            if var teamName =  try values.decodeIfPresent(String.self, forKey: .teamName) {
                self.teamName = teamName
            } else {
                self.teamName = "NA"
            }
        
       }
    
}

struct MP: Codable {
    
    var matchsPlayed: Int
    
    enum CodingKeys: String, CodingKey {
           case matchsPlayed
       }
    
    init(from decoder: Decoder) throws {
        // 1 - Container
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        
        // 3 - Conditional Decoding
        if var matchsPlayed =  try values.decodeIfPresent(Int.self, forKey: .matchsPlayed) {
            self.matchsPlayed = matchsPlayed
        } else {
            self.matchsPlayed = 0
        }
        
    }
    
}
