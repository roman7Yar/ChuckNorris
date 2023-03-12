//
//  JokeManager.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 01.02.2023.
//

import Foundation

struct JokeData: Codable {
    let total: Int
    let result: [Result]
}

struct Result: Codable {
    let categories: [String]
    let created_at: String
    let id: String
    let value: String
}

struct JokeManager {
    
    var urlStr: String
    
    var searchCallBack: ((_ model: JokeData) -> ())?
    var standartCallBack: ((_ model: Result) -> ())?
    
    enum FetchingType {
        case search, standart
    }
    
    func fetch(type: FetchingType) {
        guard let url = URL(string: urlStr) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                switch type {
                case .search:
                    let jsonResult = try JSONDecoder().decode(JokeData.self, from: data)
                    let model = JokeData(total: jsonResult.total, result: jsonResult.result)
                    searchCallBack?(model)
                case .standart:
                    let jsonResult = try JSONDecoder().decode(Result.self, from: data)
                    let model = Result(categories: jsonResult.categories,
                                       created_at: jsonResult.created_at,
                                       id: jsonResult.id,
                                       value: jsonResult.value)
                    standartCallBack?(model)
                }
                
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
}

