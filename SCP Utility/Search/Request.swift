//
//  Request.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/16/25.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI
import SwiftSoup

class RaisaReq {
    private static let ajaxModuleURL: URL? = URL(string: "https://scp-wiki.wikidot.com/ajax-module-connector.php")
    private static let baseHeaders: HTTPHeaders = [
        "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
        "User-Agent" : "RAISAmobileapp",
        "Referer" : "https://www.wikidot.com/",
        "Cookie" : "wikidot_token7=888888",
    ]
    
    static private func htmlToMarkup(_ html: String) -> String {
        var finalString: String = ""
        do {
            let document = try SwiftSoup.parse(html)
            finalString = try document.text()
            finalString = finalString.replacingOccurrences(of: "Page source ", with: "")
        } catch {
            print(error)
        }
        
        return finalString
    }
    
    /// Returns a wikidot page's ID from it's url, as a string
    static func findPageID(url passedURL: URL, completion: @escaping (String?, Error?) -> Void) {
        let formattedURL = try! passedURL
            .formatted()
            .replacing(Regex(#"https?"#), with: "https")
            .appending("/norender/true/noredirect/true")
        guard let url: URL = URL(string: formattedURL) else { completion(nil, RRError.badlyFormattedURL); return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else { completion(nil, error); return }
            do {
                let document = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
                if let match = try matches(for: #"WIKIREQUEST\.info\.pageId = (\d+);"#, in: document.html()).first {
                    if let slice = match.slice(from: "WIKIREQUEST.info.pageId = ", to: ";") {
                        completion(slice, nil)
                    } else {
                        completion(nil, RRError.textParsingError)
                    }
                } else {
                    completion(nil, RRError.textParsingError)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    static func rrPageSource(url passedURL: URL, completion: @escaping (String?, Error?) -> Void) {
        guard let ajaxModuleURL else { completion(nil, RRError.ajaxModuleURLError); return }
        
        var body = [
            "moduleName" : "viewsource/ViewSourceModule",
            "page_id" : "",
            "wikidot_token7" : "888888"
        ]
        
        findPageID(url: passedURL) { id, _ in
            body["page_id"] = id
            AF.request(
                ajaxModuleURL,
                method: .post,
                parameters: body,
                encoding: URLEncoding.default,
                headers: baseHeaders
            ).responseString { response in
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    guard var pagesource = json["body"].string else {
                        completion(nil, RRError.textParsingError)
                        return
                    }
                    
                    pagesource = htmlToMarkup(pagesource)
                    completion(pagesource, nil)
                } catch {
                    print(error)
                }
            }
        }
    }
}

enum RRError: Error {
    case ajaxModuleURLError
    case finalSegmentNotFound
    case pageIDNotFound
    case badlyFormattedURL
    case textParsingError
}

// MARK: Headers for meta data requests
/*
 [
     "pagetype" : "*",
     "category" : "*",
     "fullname" : finalURLSegment,
     "order" : "created_at desc",
     "offset" : 0,
     "perPage" : 5,
     "separate" : "no",
     "wrapper" : "no",
     "moduleName" : "list/ListPagesModule",
     "module_body" : #"[[div class="page"]]\n[[span class="set fullname"]][[span class="name"]] fullname [[/span]][[span class="value"]] %%fullname%% [[/span]][[/span]][[span class="set category"]][[span class="name"]] category [[/span]][[span class="value"]] %%category%% [[/span]][[/span]][[span class="set name"]][[span class="name"]] name [[/span]][[span class="value"]] %%name%% [[/span]][[/span]][[span class="set title"]][[span class="name"]] title [[/span]][[span class="value"]] %%title%% [[/span]][[/span]][[span class="set created_at"]][[span class="name"]] created_at [[/span]][[span class="value"]] %%created_at%% [[/span]][[/span]][[span class="set created_by_linked"]][[span class="name"]] created_by_linked [[/span]][[span class="value"]] %%created_by_linked%% [[/span]][[/span]][[span class="set updated_at"]][[span class="name"]] updated_at [[/span]][[span class="value"]] %%updated_at%% [[/span]][[/span]][[span class="set updated_by_linked"]][[span class="name"]] updated_by_linked [[/span]][[span class="value"]] %%updated_by_linked%% [[/span]][[/span]][[span class="set commented_at"]][[span class="name"]] commented_at [[/span]][[span class="value"]] %%commented_at%% [[/span]][[/span]][[span class="set commented_by_linked"]][[span class="name"]] commented_by_linked [[/span]][[span class="value"]] %%commented_by_linked%% [[/span]][[/span]][[span class="set parent_fullname"]][[span class="name"]] parent_fullname [[/span]][[span class="value"]] %%parent_fullname%% [[/span]][[/span]][[span class="set comments"]][[span class="name"]] comments [[/span]][[span class="value"]] %%comments%% [[/span]][[/span]][[span class="set size"]][[span class="name"]] size [[/span]][[span class="value"]] %%size%% [[/span]][[/span]][[span class="set children"]][[span class="name"]] children [[/span]][[span class="value"]] %%children%% [[/span]][[/span]][[span class="set rating_votes"]][[span class="name"]] rating_votes [[/span]][[span class="value"]] %%rating_votes%% [[/span]][[/span]][[span class="set rating"]][[span class="name"]] rating [[/span]][[span class="value"]] %%rating%% [[/span]][[/span]][[span class="set rating_percent"]][[span class="name"]] rating_percent [[/span]][[span class="value"]] %%rating_percent%% [[/span]][[/span]][[span class="set revisions"]][[span class="name"]] revisions [[/span]][[span class="value"]] %%revisions%% [[/span]][[/span]][[span class="set tags"]][[span class="name"]] tags [[/span]][[span class="value"]] %%tags%% [[/span]][[/span]][[span class="set _tags"]][[span class="name"]] _tags [[/span]][[span class="value"]] %%_tags%% [[/span]][[/span]]\n[[/div]]"#,
     "wikidot_token7" : "888888",
 ]
 */

#Preview {
    Text("Text")
        .onAppear {
            RaisaReq.rrPageSource(url: URL(string: "https://scp-wiki.wikidot.com/scp-173")!) { data ,_ in
                print(data ?? "error")
            }
        }
}
