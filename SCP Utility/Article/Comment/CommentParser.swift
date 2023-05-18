//
//  CommentParser.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import Foundation
import SwiftSoup

/// Parses the first page of comments of an article from the article's URL
func parseComments(articleURL: URL, completion: @escaping ([Comment]) -> Void) {
    let stringURL = URL(string: "https" + articleURL.formatted().dropFirst(4))!
    let task = URLSession.shared.dataTask(with: stringURL) { data, response, error in
        guard let data = data else { return }
        do {
            let articledoc = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
            var url = try articledoc.getElementById("discuss-button")?.attr("href").asURL()
            if url == nil { return }
            url = URL(string: "https://scp-wiki.wikidot.com" + url!.formatted())!
            
            let doc = try SwiftSoup.parse(String(contentsOf: url!))
            let comments = try doc.getElementsByClass("long").array()
            
            var returnComments: [Comment] = []
            for element in comments {
                let img = try element.getElementsByClass("small").attr("src").asURL()
                var user = ""
                if try element.getElementsByClass("printuser deleted").first() == nil {
                    user = try element.getElementsByClass("printuser avatarhover").select("a").array().last?.text() ?? "unknown user"
                } else { user = "(account deleted)" }
                let date = try element.getElementsByClass("odate time_1388720063 format_%25e%20%25b%20%25Y%2C%20%25H%3A%25M%7Cagohover").toString()
                let content = try element.getElementsByClass("content").first()?.text() ?? ""
                
                returnComments.append(
                    Comment(
                        username: user,
                        content: content,
                        profilepic: img,
                        date: nil
                    )
                    
                )
            }
            
            completion(returnComments)
        } catch {
            print(error)
        }
    }
    task.resume()
}
