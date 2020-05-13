//
//  Data.swift
//  ITunesAPISample
//
//  Created by burak on 25.04.2020.
//  Copyright © 2020 burak. All rights reserved.
//

import Foundation

struct Details:Decodable{
    var resultCount:Int?
    var results:[Results]?
}

struct Results:Decodable {
    var artworkUrl100:String?
    var artistName:String?
    var trackName:String?
    var previewUrl:String?
}


