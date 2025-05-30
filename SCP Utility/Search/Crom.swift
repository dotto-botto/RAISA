//
//  Crom.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/16/23.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwiftSoup

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

func cromInfo(url: URL, completion: @escaping (ArticleInfo) -> Void) {
    let graphQLQuery = try! """
query Search($query: URL! = "\(url.formatted().replacing(Regex("https?"), with: "http"))") {
  page(url: $query) {
    wikidotInfo {
      rating
      tags
      createdAt
      createdBy {
        name
        statistics {
          rank
          totalRating
          meanRating
          pageCount
        }
      }
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

    var responseJSON: JSON = JSON()
    
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            let page = responseJSON["data"]["page"]["wikidotInfo"]
            let user = page["createdBy"]

            let dateElement = page["createdAt"].string ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: dateElement)
            
            completion(ArticleInfo(
                rating: page["rating"].intValue,
                tags: page["tags"].arrayValue.map { $0.stringValue },
                createdAt: date,
                createdBy: user["name"].stringValue,
                userRank: user["statistics"]["rank"].intValue,
                userTotalRating: user["statistics"]["totalRating"].intValue,
                userMeanRating: user["statistics"]["meanRating"].intValue,
                userPageCount: user["statistics"]["pageCount"].intValue
            ))
        }
    }
}

/// Returns an article without its source
func cromRandom(language: RAISALanguage = .english, completion: @escaping (Article) -> Void) {
    let graphQLQuery = """
query Search {
  randomPage(filter: {anyBaseUrl: "\(language.toURL())"}) {
    page {
      url
      wikidotInfo {
        title
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
    
    var article = Article(title: "", pagesource: "", url: placeholderURL)
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
            let pic = page["wikidotInfo"]["thumbnailUrl"]

            article = Article(
                title: title.string ?? "Could not find title",
                pagesource: "",
                url: url ?? placeholderURL,
                thumbnail: pic.url ?? nil
            )
            
            completion(article)
        }
    }
}

func cromAPISearchFromURL(query: URL, completion: @escaping (Article?) -> Void) {
    let formattedURL = try! query
        .formatted()
        .replacing(Regex("https?"), with: "http")
        .lowercased()
        .replacingOccurrences(of: "www.", with: "")
        .replacingOccurrences(of: ".net", with: ".wikidot.com")
        .replacingOccurrences(of: "http:s", with: "http://s")
    
    let graphQLQuery = """
query Search($query: URL! = "\(formattedURL)") {
    page(url: $query) {
    alternateTitles {
      title
    }
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
    
    var article = Article(title: "", pagesource: "", url: placeholderURL)
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            let page = responseJSON["data"]["page"]
            guard let title = page["wikidotInfo"]["title"].string else { completion(nil); return }
            guard let source = page["wikidotInfo"]["source"].string else { completion(nil); return }
            let pic = page["wikidotInfo"]["thumbnailUrl"].url
            let subtitle = page["alternateTitles"].arrayValue.first?["title"].string

            article = Article(
                title: title,
                subtitle: subtitle,
                pagesource: source,
                url: query,
                thumbnail: pic ?? nil
            )
            completion(article)
        }
    }
}

/// Returns a list of articles without source with given query.
func cromAPISearch(query: String, language: RAISALanguage = .english, completion: @escaping ([Article]) -> Void) {
    let graphQLQuery = """
query Search($query: String! = "\(query)") {
  searchPages(query: $query, filter: {anyBaseUrl: "\(language.toURL())"}) {
    url
    alternateTitles {
      title
    }
    wikidotInfo {
      title
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

            for page in responseJSON["data"]["searchPages"].arrayValue {
                articles.append(Article(
                    title: page["wikidotInfo"]["title"].string ?? "Could not find title",
                    subtitle: page["alternateTitles"].arrayValue.first?["title"].string,
                    pagesource: "",
                    url: page["url"].url ?? placeholderURL
                ))
            }
            completion(articles)
        }
    }
}

/// Retruns an article's page source from its URL
func cromGetSourceFromURL(url: URL, completion: @escaping (String) -> Void) {
    let graphQLQuery = """
query Search($query: URL! = "\(url)") {
  page(url: $query) {
    wikidotInfo {
      source
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

    var responseJSON: JSON = JSON()
    
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            let source = responseJSON["data"]["page"]["wikidotInfo"]["source"].string
            completion(source ?? "Could not find source")
        }
    }
}

/// Retruns an article from a title
func cromGetSourceFromTitle(title: String, language: RAISALanguage = .english, completion: @escaping (Article) -> Void) {
    let graphQLQuery = """
query Search($query: String! = "\(title)") {
  searchPages(query: $query, filter: {anyBaseUrl: "\(language.toURL())"}) {
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
    
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }
            
            if let article = responseJSON["data"]["searchPages"].array?.first {
                
                let title = article["wikidotInfo"]["title"].string
                let source = article["wikidotInfo"]["source"].string
                let url = article["url"].url
                let thumbnail = article["wikidotInfo"]["thumbnailUrl"].url
                completion(
                    Article(
                        title: title ?? "Could not find title",
                        pagesource: source ?? "Could not find source",
                        url: url ?? placeholderURL,
                        thumbnail: thumbnail
                    )
                )
            }
        }
    }
}

func cromGetChildren(url: URL, sortByCreation: Bool? = nil, completion: @escaping ([(String,URL)]) -> Void) {
    let graphQLQuery = """
query Search($query: URL! = "\(url)") {
    page(url: $query) {
    wikidotInfo {
      children {
        url
        wikidotInfo {
          title
          createdAt
        }
      }
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

    var responseJSON: JSON = JSON()
    
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            var returnDict: [(String,URL)] = []
            for child in responseJSON["data"]["page"]["wikidotInfo"]["children"].arrayValue {
                guard let url = child["url"].url else { continue }
                returnDict.append((child["wikidotInfo"]["title"].stringValue, url))
            }
            
            completion(returnDict)
        }
    }
}

func cromTranslate(url: URL, from fromLang: RAISALanguage, to toLang: RAISALanguage, completion: @escaping (Article?) -> Void) {
    let baseTitle = url.formatted().replacingOccurrences(of: fromLang.toURL().formatted(), with: "")
    let newURL = URL(string: toLang.toURL().formatted() + baseTitle)!
    
    raisaSearchFromURL(query: newURL) { completion($0) }
}

func cromGetAlternateTitle(url: URL, completion: @escaping (String) -> Void) {
    let graphQLQuery = """
query Search($query: URL! = "\(url)") {
    page(url: $query) {
    alternateTitles {
      title
    }
  }
}
"""
    
    let parameters: [String: String] = [
        "query": (graphQLQuery)
    ]

    var responseJSON: JSON = JSON()
    
    cromRequest(params: parameters) { data, error in
        if let error {
            print(error)
        } else if let myData = data {
            do {
                responseJSON = try JSON(data: myData)
            } catch {
                print(error)
            }

            let source = responseJSON["data"]["page"]["alternateTitles"].arrayValue.first?["title"].string
            completion(source ?? "")
        }
    }
}

// MARK: - Raisa Funcitons
func raisaGetTags(url: URL, completion: @escaping ([String]) -> Void) {
    guard let url = try! URL(string: url.formatted().replacing(Regex(#"https?"#), with: "https")) else { completion([]); return }
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }
        do {
            let articledoc = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
            
            var returnArray: [String] = []

            if let table = try articledoc.getElementsByClass("page-tags").first() {
                for ele in try table.select("a") {
                    returnArray.append(try ele.text())
                }
            }
            completion(returnArray)
        } catch {
            print(error)
        }
    }
    task.resume()
}

/// Search core data for article, fallback using crom
func raisaSearchFromURL(query: URL, completion: @escaping (Article?) -> Void) {
    let con = PersistenceController.shared
    
    if con.isArticleSaved(url: query) {
        guard let item = con.getArticleByURL(url: query) else { completion(nil); return }
        guard let article = Article(fromEntity: item) else { completion(nil); return }
        completion(article)
    } else {
        cromAPISearchFromURL(query: query) { completion($0) }
    }
}

func raisaGetArticleFromTitle(title: String, language: RAISALanguage = .english, completion: @escaping (Article?) -> Void) {
    let con = PersistenceController.shared
    
    if let articleitem = con.getArticleByTitle(title: title),
       let article = Article(fromEntity: articleitem),
       article.findLanguage() == language
    {
        completion(article)
    } else {
        cromGetSourceFromTitle(title: title, language: language) { completion($0) }
    }
}
