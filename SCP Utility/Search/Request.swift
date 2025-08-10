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
    private static let baseHeaders: HTTPHeaders = [
        "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
        "User-Agent" : "RAISAmobileapp",
        "Referer" : "https://www.wikidot.com/",
        "Cookie" : "wikidot_token7=888888",
    ]
    
    static private func ajaxModuleURL(language lang: RAISALanguage = .english) -> URL {
        return try! URL(string: lang.toURL()
            .formatted()
            .replacing(Regex(#"https?"#), with: lang.allowsHTTPS() ? "https" : "http")
            .appending("/ajax-module-connector.php"))!
    }
    
    static private func htmlToMarkup(_ html: String) -> String {
        var finalString: String = "error while parsing HTML"
        do {
            let parsed = try SwiftSoup.parse(html, "page-source", Parser.xmlParser())
            guard let psource = try parsed.getElementsByClass("page-source").first()
            else { return finalString }
            finalString = try psource
                .html()
                .components(separatedBy: .newlines)
                .map { try SwiftSoup.parse($0).text() }
                .joined(separator: "\n")
                .replacingOccurrences(of: "Page source ", with: "")
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
    
    /// Search ajax for an article's title or fullname
    /// - Parameters:
    ///   - param: title or fullname
    static func paramReqStrings(url passedURL: URL, param modulebody: String, completion: @escaping (String?, Error?) -> Void) {
        guard let finalURLSegment = passedURL.absoluteString.slice(from: ".com/") ?? passedURL.absoluteString.slice(from: ".net/")
        else { completion(nil, RRError.finalSegmentNotFound); return }
        
        var body: [String:Any] = [
            "pagetype" : "*",
            "category" : "*",
            "fullname" : finalURLSegment,
            "order" : "created_at desc",
            "offset" : 0,
            "perPage" : 5,
            "separate" : "no",
            "wrapper" : "no",
            "moduleName" : "list/ListPagesModule",
            "page_id" : "",
            "module_body" : "%%\(modulebody)%%",
            "wikidot_token7" : "888888"
        ]
        
        findPageID(url: passedURL) { id, _ in
            body["page_id"] = id
            AF.request(
                ajaxModuleURL(),
                method: .post,
                parameters: body,
                encoding: URLEncoding.default,
                headers: baseHeaders
            ).responseString { response in
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    guard let pagesource = json["body"].string else {
                        completion(nil, RRError.textParsingError)
                        return
                    }
                    let title = pagesource.slice(from: "<p>", to: "</p>")
                    completion(title, nil)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // Search for page source using ajax
    static func pageSourceFromURL(url passedURL: URL, language lang: RAISALanguage = .english, completion: @escaping (String?, Error?) -> Void) {
        var body = [
            "moduleName" : "viewsource/ViewSourceModule",
            "page_id" : "",
            "wikidot_token7" : "888888"
        ]
        
        findPageID(url: passedURL) { id, _ in
            body["page_id"] = id
            AF.request(
                ajaxModuleURL(language: lang),
                method: .post,
                parameters: body,
                encoding: URLEncoding.default,
                headers: baseHeaders
            ).responseString { response in
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    print(json)
                    guard var pagesource = json["body"].string else {
                        completion(nil, RRError.textParsingError)
                        return
                    }
                    
                    pagesource = htmlToMarkup(pagesource)
                    completion(pagesource, nil)
                } catch {
                    print(error)
                    completion(nil, error)
                }
            }
        }
    }
    
    static func articlefromURL(url passedURL: URL, language lang: RAISALanguage = .english, completion: @escaping (Article?, Error?) -> Void) {
        let con = PersistenceController.shared
        if con.isArticleSaved(url: passedURL) {
            guard let item = con.getArticleByURL(url: passedURL) else { completion(nil, RRError.coreDataError); return }
            guard let article = Article(fromEntity: item) else { completion(nil, RRError.coreDataError); return }
            completion(article, nil)
        }
        
        RaisaReq.paramReqStrings(url: passedURL, param: "title") { title, error in
            if let error { completion(nil, error); return }
            RaisaReq.pageSourceFromURL(url: passedURL, language: lang) { source, error in
                if let error { completion(nil, error); return }
                
                if let title, let source {
                    let article = Article(title: title, pagesource: source, url: passedURL)
                    completion(article, nil)
                } else {
                    completion(nil, RRError.articleRequestError)
                    return
                }
            }
        }
    }
    
    static func translate(url: URL, from baseLang: RAISALanguage, to targetLang: RAISALanguage, completion: @escaping (Article?, Error?) -> Void) {
        let baseTitle = try! url
            .formatted()
            .replacing(Regex("https?"), with: "http")
            .replacingOccurrences(of: baseLang.toURL().formatted(), with: "")
        let newURL = URL(string: targetLang.toURL().formatted() + baseTitle)!
        
        RaisaReq.articlefromURL(url: newURL, language: targetLang) { data, error in
            print(error as Any)
            completion(data, error)
        }
    }
    
    // MARK: Article info
    
    /// Search ajax for tags
    static func tags(url passedURL: URL, completion: @escaping ([String]?, Error?) -> Void) {
        guard let finalURLSegment = passedURL.absoluteString.slice(from: ".com/") else { completion(nil, RRError.finalSegmentNotFound); return }
        
        var body: [String:Any] = [
            "pagetype" : "*",
            "category" : "*",
            "fullname" : finalURLSegment,
            "order" : "created_at desc",
            "offset" : 0,
            "perPage" : 5,
            "separate" : "no",
            "wrapper" : "no",
            "moduleName" : "list/ListPagesModule",
            "page_id" : "",
            "module_body" : "%%tags%%",
            "wikidot_token7" : "888888"
        ]
        
        findPageID(url: passedURL) { id, _ in
            body["page_id"] = id
            AF.request(
                ajaxModuleURL(),
                method: .post,
                parameters: body,
                encoding: URLEncoding.default,
                headers: baseHeaders
            ).responseString { response in
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    guard let pagesource = json["body"].string else {
                        completion(nil, RRError.textParsingError)
                        return
                    }
                    let title = pagesource.slice(from: "<p>", to: "</p>")
                    completion(title?.components(separatedBy: " "), nil)
                } catch {
                    print(error)
                }
            }
        }
    }
}

enum RRError: Error {
    case test
    case ajaxModuleURLError
    case finalSegmentNotFound
    case pageIDNotFound
    case badlyFormattedURL
    case textParsingError
    case articleRequestError
    case coreDataError
}

#Preview {
    Text("Text")
        .onAppear {
            RaisaReq.articlefromURL(url: URL(string: "https://scpfoundation.net/scp-173")!) { data , error in
                print(data ?? "no data")
                print(error ?? "no error")
            }
        }
}

// MARK: Headers for data requests
/*
 fullname, name - The same name in the url
 category - ??
 title - The title of the article
 created_at - Date and time created (time zone?)
 created_by_linked - User data (URL, profile pic, username, and karma) of author
 updated_at - Date and time of last update (time zone?)
 updated_by_linked - User data of the last editor
 commented_at - Time of the last comment??
 commented_by_linked - User data of the last commenter??
 parent_fullname - Likely fullname of the parent
 comments - Number of comments
 size - ??
 children - Number of children
 rating_votes - Number of votes total
 rating - Rating
 rating_percent - error (divide rating by rating_votes instead)
 revisions - Number of revisions
 tags - Tags
 _tags - Hidden tags??
 */


/*
 [
     "pagetype" : "*",
     "category" : "*",
     "fullname" : finalURLSegment, // The last part of the url after ".com/", EX: scp-173
     "order" : "created_at desc",
     "offset" : 0,
     "perPage" : 5,
     "separate" : "no",
     "wrapper" : "no",
     "moduleName" : "list/ListPagesModule",
     "module_body" :
        """
        [[div class="page"]]
            [[span class="set fullname"]]
                [[span class="name"]] fullname [[/span]]
                [[span class="value"]] %%fullname%% [[/span]]
            [[/span]]
            [[span class="set category"]]
                [[span class="name"]] category [[/span]]
                [[span class="value"]] %%category%% [[/span]]
            [[/span]]
            [[span class="set name"]]
                [[span class="name"]] name [[/span]]
                [[span class="value"]] %%name%% [[/span]]
            [[/span]]
            [[span class="set title"]]
                [[span class="name"]] title [[/span]]
                [[span class="value"]] %%title%% [[/span]]
            [[/span]]
            [[span class="set created_at"]]
                [[span class="name"]] created_at [[/span]]
                [[span class="value"]] %%created_at%% [[/span]]
            [[/span]]
            [[span class="set created_by_linked"]]
                [[span class="name"]] created_by_linked [[/span]]
                [[span class="value"]] %%created_by_linked%% [[/span]]
            [[/span]]
            [[span class="set updated_at"]]
                [[span class="name"]] updated_at [[/span]]
                [[span class="value"]] %%updated_at%% [[/span]]
            [[/span]]
            [[span class="set updated_by_linked"]]
                [[span class="name"]] updated_by_linked [[/span]]
                [[span class="value"]] %%updated_by_linked%% [[/span]]
            [[/span]]
            [[span class="set commented_at"]]
                [[span class="name"]] commented_at [[/span]]
                [[span class="value"]] %%commented_at%% [[/span]]
            [[/span]]
            [[span class="set commented_by_linked"]]
                [[span class="name"]] commented_by_linked [[/span]]
                [[span class="value"]] %%commented_by_linked%% [[/span]]
            [[/span]]
            [[span class="set parent_fullname"]]
                [[span class="name"]] parent_fullname [[/span]]
                [[span class="value"]] %%parent_fullname%% [[/span]]
            [[/span]]
            [[span class="set comments"]]
                [[span class="name"]] comments [[/span]]
                [[span class="value"]] %%comments%% [[/span]]
            [[/span]]
            [[span class="set size"]]
                [[span class="name"]] size [[/span]]
                [[span class="value"]] %%size%% [[/span]]
            [[/span]]
            [[span class="set children"]]
                [[span class="name"]] children [[/span]]
                [[span class="value"]] %%children%% [[/span]]
            [[/span]]
            [[span class="set rating_votes"]]
                [[span class="name"]] rating_votes [[/span]]
                [[span class="value"]] %%rating_votes%% [[/span]]
            [[/span]]
            [[span class="set rating"]]
                [[span class="name"]] rating [[/span]]
                [[span class="value"]] %%rating%% [[/span]]
            [[/span]]
            [[span class="set rating_percent"]]
                [[span class="name"]] rating_percent [[/span]]
                [[span class="value"]] %%rating_percent%% [[/span]]
            [[/span]]
            [[span class="set revisions"]]
                [[span class="name"]] revisions [[/span]]
                [[span class="value"]] %%revisions%% [[/span]]
            [[/span]]
            [[span class="set tags"]]
                [[span class="name"]] tags [[/span]]
                [[span class="value"]] %%tags%% [[/span]]
            [[/span]]
            [[span class="set _tags"]]
                [[span class="name"]] _tags [[/span]]
                [[span class="value"]] %%_tags%% [[/span]]
            [[/span]]
        [[/div]]
        """,
     "wikidot_token7" : "888888",
 ]
 */
