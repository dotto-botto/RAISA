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
    guard let stringURL = URL(string: articleURL.formatted().replacingOccurrences(of: "http://", with: "https://")) else { return }
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
                    user = try element.getElementsByClass("printuser avatarhover").first()?.select("a").array().last?.text() ?? "unknown user"
                } else { user = "(account deleted)" }
                
                let keyword = matches(for: #"odate.*?agohover"#, in: element.description).first ?? "÷"
                let dateElement = try element.getElementsByClass(keyword).text()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
                let date = dateFormatter.date(from: dateElement)
                
                let content = try element.getElementsByClass("content").first()?.text() ?? ""
                
                let subject = try element.getElementsByClass("title").first()?.text()
                
                returnComments.append(
                    Comment(
                        username: user,
                        subject: subject,
                        content: content,
                        profilepic: img,
                        date: date
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
