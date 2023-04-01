//
//  Crom.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/16/23.
//

import Foundation
import SwiftyJSON
import Alamofire

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

func cromRandom(completion: @escaping (Article) -> Void) {
    let graphQLQuery = """
query Search {
  randomPage(filter: {anyBaseUrl: "http://scp-wiki.wikidot.com"}) {
    page {
      url
      wikidotInfo {
      title
      source
      thumbnailUrl
    }
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

    var responseJSON: JSON = JSON()
    
    var article = Article(title: "", pagesource: "")
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            let page = responseJSON["data"]["randomPage"]["page"]
            let url = page["url"].url
            let title = page["wikidotInfo"]["title"]
            let source = page["wikidotInfo"]["source"]
            let pic = page["wikidotInfo"]["thumbnailUrl"]

            article = Article(
                title: title.string ?? "Could not find title",
                pagesource: source.string ?? "Could not find pagesource",
                url: url,
                thumbnail: pic.url ?? nil
            )
            
            completion(article)
        }
    }
}

func cromAPISearchFromURL(query: URL, completion: @escaping (Article) -> Void) {
    let graphQLQuery = """
query Search($query: URL! = "\(query)") {
    page(url: $query) {
    url
    wikidotInfo {
      title
      source
      thumbnailUrl
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

    var responseJSON: JSON = JSON()
    
    var article = Article(title: "", pagesource: "")
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

                article = Article(
                    title: title.string ?? "Could not find title",
                    pagesource: source.string ?? "Could not find pagesource",
                    url: query,
                    thumbnail: pic.url ?? nil
                )
            }
            completion(article)
        }
    }
}

func cromAPISearch(query: String, completion: @escaping ([Article]) -> Void) {
    let graphQLQuery = """
query Search($query: String! = "\(query)") {
  searchPages(query: $query, filter: {anyBaseUrl: "http://scp-wiki.wikidot.com"}) {
    url
    wikidotInfo {
      title
      source
      thumbnailUrl
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

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
                let url = pages["url"].url
                let pic = pages["wikidotInfo"]["thumbnailUrl"]

                articles.append(Article(
                    title: title.string ?? "Could not find title",
                    pagesource: source.string ?? "Could not find pagesource",
                    url: url,
                    thumbnail: pic.url ?? nil
                ))
            }
            completion(articles)
        }
    }
}

