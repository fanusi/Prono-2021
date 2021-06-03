//
//  EuroJSON.swift
//  EK Prono 21
//
//  Created by Stéphane Trouvé on 25/04/2021.
//

import Foundation

struct fixture: Codable {
    var venue: String
    var round: String
    var fixture_id: Int
    var status: String
    var awayTeam: AT
    var homeTeam: HT
    var score: SC
    var statusShort: String
    var goalsAwayTeam: Int
    var goalsHomeTeam: Int
    var event_timestamp: Int
    
    enum CodingKeys: String, CodingKey {
           case venue
           case round
           case fixture_id
           case status
           case awayTeam
           case homeTeam
           case goalsAwayTeam
           case goalsHomeTeam
           case score
           case statusShort
           case event_timestamp
       }
       
       // The Initializer function from Decodable
       init(from decoder: Decoder) throws {
           // 1 - Container
           let values = try decoder.container(keyedBy: CodingKeys.self)
           
           // 2 - Normal Decoding
           awayTeam = try values.decode(AT.self, forKey: .awayTeam)
           homeTeam = try values.decode(HT.self, forKey: .homeTeam)
           score =  try values.decode(SC.self, forKey: .score)
           
           // 3 - Conditional Decoding
        
            if var fixture_id =  try values.decodeIfPresent(Int.self, forKey: .fixture_id) {
                self.fixture_id = fixture_id
            } else {
                self.fixture_id = -999
            }
        
            if var status =  try values.decodeIfPresent(String.self, forKey: .status) {
                self.status = status
            } else {
                self.status = "NS"
            }
            
        
           if var goalsAwayTeam =  try values.decodeIfPresent(Int.self, forKey: .goalsAwayTeam) {
               self.goalsAwayTeam = goalsAwayTeam
           } else {
               self.goalsAwayTeam = -999
           }
        
           if var goalsHomeTeam =  try values.decodeIfPresent(Int.self, forKey: .goalsHomeTeam) {
               self.goalsHomeTeam = goalsHomeTeam
           } else {
               self.goalsHomeTeam = -999
           }
        
           if var round =  try values.decodeIfPresent(String.self, forKey: .round) {
               self.round = round
           } else {
               self.round = "NA"
           }
        
            if var venue =  try values.decodeIfPresent(String.self, forKey: .venue) {
                self.venue = venue
            } else {
                self.venue = "NA"
            }

            if var statusShort =  try values.decodeIfPresent(String.self, forKey: .statusShort) {
                self.statusShort = statusShort
            } else {
                self.statusShort = "NA"
            }
        
            if var event_timestamp =  try values.decodeIfPresent(Int.self, forKey: .event_timestamp) {
                self.event_timestamp = event_timestamp
            } else {
                self.event_timestamp = 0
            }
        
       }
}

struct fixtures: Codable {
    var fixtures: [fixture]
}

struct api1: Codable {
    var api: fixtures
}

struct AT: Codable {
    var team_name: String
    
    enum CodingKeys: String, CodingKey {
           case team_name
       }
    
    init(from decoder: Decoder) throws {
        // 1 - Container
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        
        // 3 - Conditional Decoding
        if var team_name =  try values.decodeIfPresent(String.self, forKey: .team_name) {
            self.team_name = team_name
        } else {
            self.team_name = "-"
        }
        
    }
    
}

struct HT: Codable {
    var team_name: String
    
    enum CodingKeys: String, CodingKey {
           case team_name
       }
    
    init(from decoder: Decoder) throws {
        // 1 - Container
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        
        // 3 - Conditional Decoding
        if var team_name =  try values.decodeIfPresent(String.self, forKey: .team_name) {
            self.team_name = team_name
        } else {
            self.team_name = "-"
        }
        
    }
    
}

struct SC: Codable {
    var fulltime: String
    var penalty: String
    
    enum CodingKeys: String, CodingKey {
           case fulltime
           case penalty
       }
    
    init(from decoder: Decoder) throws {
        // 1 - Container
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        
        // 3 - Conditional Decoding
        if var fulltime =  try values.decodeIfPresent(String.self, forKey: .fulltime) {
            self.fulltime = fulltime
        } else {
            self.fulltime = "-"
        }
 
        if var penalty =  try values.decodeIfPresent(String.self, forKey: .penalty) {
            self.penalty = penalty
        } else {
            self.penalty = "-"
        }
        
    }
    
}

