//
//  Crom.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/16/23.
//

import Foundation
import SwiftyJSON
import Alamofire

func CromQueryFromUrl(query: String) -> String {
return """
query Search($query: URL! = "\(query)") {
    page(url: $query) {
    wikidotInfo {
      title
      source
      thumbnailUrl
    }
  }
}
"""
}

func CromQuery(query: String) -> String {
return """
query Search($query: String! = "\(query)") {
  searchPages(query: $query, filter: {anyBaseUrl: "http://scp-wiki.wikidot.com"}) {
    wikidotInfo {
      title
      source
      thumbnailUrl
    }
  }
}
"""
}



// https://api.crom.avn.sh/graphql
func cromRequest(params: [String:String], completion: @escaping (Data?, Error?) -> Void) {
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    let url = "https://api.crom.avn.sh/graphql"
    

    AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { response in
        switch response.result {
        case .success(let data):
            completion(data, nil)
        case .failure(let error):
            completion(nil, error)
        }
    }
}

func cromURLSearch(query: String) -> Article {
    var dataResponse = Data()

    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    let queryhttp = "http" + query.dropFirst(5) // The query has to be http
    let parameters: [String: String] = [
        "query": (CromQueryFromUrl(query: queryhttp))
    ]

    let url = "https://api.crom.avn.sh/graphql"
    var responseJSON: JSON = JSON()
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
        switch response.result {
        case .success(let data):
            dataResponse = data
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    
    var articles: Article
    do {
        responseJSON = try JSON(data: dataResponse)
    } catch {
        print(error)
    }

    let title = responseJSON["data"]["page"]["wikidotInfo"]["title"]
    let source = responseJSON["data"]["page"]["wikidotInfo"]["source"]
    let pic = responseJSON["data"]["page"]["wikidotInfo"]["thumbnailUrl"]

    articles = Article(
        title: title.string ?? "Could not find title",
        pagesource: source.string ?? "Could not find pagesource",
        thumbnail: pic.url ?? nil
    )
        

    return articles
    
}

var dataResponse = Data()
func cromAPISearch(query: String, completion: @escaping ([Article]) -> Void) {
    let parameters: [String: String] = [
        "query": (CromQuery(query: query))
    ]

    let url = "https://api.crom.avn.sh/graphql"
    var responseJSON: JSON = JSON()
    
    
    var articles: [Article] = []
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            for pages in responseJSON["data"]["searchPages"].arrayValue {
                let title = pages["wikidotInfo"]["title"]
                let source = pages["wikidotInfo"]["source"]
                let pic = pages["wikidotInfo"]["thumbnailUrl"]

                articles.append(Article(
                    title: title.string ?? "Could not find title",
                    pagesource: source.string ?? "Could not find pagesource",
                    thumbnail: pic.url ?? nil
                ))
            }
            completion(articles)
        }
    }
}

