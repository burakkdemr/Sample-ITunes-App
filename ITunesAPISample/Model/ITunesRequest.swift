//
//  ITunesRequest.swift
//  ITunesAPISample
//
//  Created by burak on 5.05.2020.
//  Copyright © 2020 burak. All rights reserved.
//

import Foundation

enum ResultError:Error{
    case noDataAvailable
    case canNotProcessData
}

struct ItunesRequest {
    let resourceURL:URL
    let limit:Int = 100
    
    init(term:String){
        let resourceString = "https://itunes.apple.com/search?term=\(term)&limit=\(limit)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    func getITunesData(completion: @escaping(Result<[Results], ResultError>) -> Void){
        
        URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do{
                let resultResponse = try JSONDecoder().decode(Details.self, from: jsonData)
                let resultDetails = resultResponse.results
                completion(.success(resultDetails!))
                
            }catch{
                completion(.failure(.canNotProcessData))
            }
        }.resume()
    }
}
