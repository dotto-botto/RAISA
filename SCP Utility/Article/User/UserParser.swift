//
//  UserParser.swift
//  SCP Utility
//
//  Created by Maximus Harding on 7/1/23.
//

import Foundation
import SwiftSoup

/// Parses a users home page
func parseUserPage(username: String, completion: @escaping (User) -> Void) {
    let parsedUsername = username.lowercased().replacingOccurrences(of: " ", with: "-")
    guard let stringURL = URL(string: "https://www.wikidot.com/user:info/\(parsedUsername)" ) else { return }
    let task = URLSession.shared.dataTask(with: stringURL) { data, response, error in
        guard let data = data else { return }
        do {
            let doc = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")

            // Wikidot ID
            let element: String = try doc.getElementsByClass("btn btn-default btn-xs").first()?.outerHtml() ?? ""
            guard let wdID = matches(for: #"[0-9]{7}"#, in: element).first else { return }
            
            // Thumbnail
            let thumbnail = URL(string: "https://www.wikidot.com/avatar.php?userid=\(wdID)")
            
            // MARK: Profile box divs
            let profileBox = try doc.getElementsByClass("profile-box").html()
            
            // Realname
            let realname = matches(for: #"(?<=Real name:\n <\/dt> \n <dd>\n  ).*?(?=\n <\/dd>)"#, in: profileBox).first
            
            // From
            let from = matches(for: #"(?<=From:\n <\/dt> \n <dd>\n  ).*?(?=\n <\/dd>)"#, in: profileBox).first

            // Website
            let href = try doc.getElementsByClass("profile-box").select("a").text().replacing(/\s.*/, with: "")
            let website = URL(string: href)
            
            // Creation
            let keyword = matches(for: #"odate.*?ago.{3}"#, in: doc.description).first ?? "÷"
            let dateElement = try doc.getElementsByClass(keyword).text()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let date = dateFormatter.date(from: dateElement)
            
            // Karma
            let karma: Int? = {
                let match = profileBox.slice(from: "Karma level:\n </dt> \n <dd>\n   ", to: " \n  <img")
                switch match {
                case "none": return 0
                case "low": return 1
                case "medium": return 2
                case "high": return 3
                case "very high": return 4
                case "guru": return 5
                default: return nil
                }
            }()
            
            let returnUser = User(
                username: username,
                about: nil,
                wikidotID: wdID,
                thumbnail: thumbnail,
                realname: realname,
                from: from,
                website: website,
                creation: date,
                karma: karma
            )
            
            completion(returnUser)
        } catch {
            print(error)
        }
    }
    task.resume()
}
