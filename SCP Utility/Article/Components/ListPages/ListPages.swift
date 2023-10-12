//
//  ListPages.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/13/23.
//

import Foundation

func replaceFragmentsWithSource(article: Article, completion: @escaping (String) -> Void) {
    guard article.pagesource.contains("[[module ListPages") else { completion(article.pagesource); return }
    guard let module = article.pagesource.slice(from: "[[module ListPages", to: "]]") else { completion(article.pagesource); return }
    
    let parent = module.slice(from: "parent=\"", to: "\"") ?? "."
    guard parent == "." else { print("parent parameter \"\(parent)\" unsupported"); completion(article.pagesource); return }
    
    let limit = Int(module.slice(from: "limit=\"", to: "\"") ?? "") ?? -1
    
    let order = module.slice(from: "order=\"", to: "\"") ?? "name"
    
    cromGetChildren(url: article.url) { tuple in
        var dict: [(String,URL)] = []
        
        // Sort
        switch order {
        //case "created_at":
        default: dict = tuple.sorted(by: { $0.0 < $1.0 })
        }
        
        // Filter based on limit
        guard dict.count >= limit && limit != -1 else {
            print("Limit is higher than amount of children, article: \(article.title)")
            completion(article.pagesource)
            return
        }
        dict = limit == -1 ? dict : Array(dict[..<limit])
        
        var newSource: String = ""
        for pair in dict {
            guard let url = URL(string: pair.1.formatted().replacingOccurrences(of: "https", with: "http")) else { continue }

            cromGetSourceFromURL(url: url) { source in
                newSource += source
                
                if pair == dict.last ?? ("", placeholderURL) {                    
                    let module = article.pagesource.slice(with: "[[module ListPages" + module + "]]", and: "[[/module]]")
                                        
                    // If article has multiple fragments
//                    if returnArticle.pagesource.contains("[[module ListPages") {
//                        replaceFragmentsWithSource(article: returnArticle) { newArticle in
//                            returnArticle = newArticle
//                        }
//                    } else {
                        completion(article.pagesource.replacingOccurrences(of: module, with: newSource))
//                    }
                }
            }
        }
    }
}
