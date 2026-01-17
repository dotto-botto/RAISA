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
import Security

class RaisaReq {
    private static let baseHeaders: HTTPHeaders = [
        "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
        "User-Agent" : "RAISAmobileapp",
        "Referer" : "https://www.wikidot.com/",
        "Cookie" : "wikidot_token7=888888",
    ]
    
    // MARK: - Login Requests
    /// Log in to wikidot
    static func login(username: String, password: String, saveInKeychain keychain: Bool = false, completion: @escaping (Error?) -> Void) {
        let loginURL = URL(string: "https://www.wikidot.com/default--flow/login__LoginPopupScreen")!
        let body = [
            "login" : username,
            "password" : password,
            "action" : "Login2Action",
            "event" : "login"
        ]
        AF.request(
            loginURL,
            method: .post,
            parameters: body,
            encoding: URLEncoding.default,
            headers: baseHeaders
        ).responseString { response in
            guard let data = response.value else { completion(RRError.invalidAuthenticationError); return }
            if data.contains("The login and password do not match") {
                completion(RRError.invalidAuthenticationError)
            } else {
                if keychain {
                    do {
                        try Keychain.saveLogin(username: username, password: password)
                    } catch {
                        completion(error)
                    }
                }
                
                completion(nil)
            }
        }
    }
    
    /// Log out of wikidot
    static func logout() {
        let loginURL = URL(string: "https://www.wikidot.com/default--flow/login__LoginPopupScreen")!
        let body = [
            "action" : "Login2Action",
            "event" : "logout",
            "moduleName" : "Empty"
        ]
        _ = AF.request(
            loginURL,
            method: .post,
            parameters: body,
            encoding: URLEncoding.default,
            headers: baseHeaders
        )
    }
    
    static func ratePage(url: URL, vote: RRVote, completion: @escaping (Error?) -> Void) {
        findPageID(url: url) { id, _ in
            let body = [
                "action" : "RateAction",
                "event" : "ratePage",
                "points" : "\(vote.rawValue)",
                "pageId" : id,
                "force" : "yes"
            ]
            AF.request(
                ajaxModuleURL(),
                method: .post,
                parameters: body,
                encoding: URLEncoding.default,
                headers: baseHeaders
            ).responseString { response in
                guard let data = response.value else { return }
                print(data)
            }
        }
    }
    
    // MARK: - Article Requests
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
    
    static func getAlternateTitle(url: URL, store: SubtitlesStore) -> String? {
        var subtitle = store.seriesSubtitles[url.lastPathComponent]
        if subtitle == nil {
            self.scrapeSubtitles(store: store)
            store.loadsubtitles()
            subtitle = store.seriesSubtitles[url.lastPathComponent]
        }
        return subtitle
    }
    
    /// Scrape all subtitles from the wiki from series 1 to LATEST_SERIES as well as EX and J articles
    static func scrapeSubtitles(language lang: RAISALanguage = .english, store: SubtitlesStore, series: Int? = nil) {
        var baseurlcomponents = [
            "scp-series",
            "scp-series-2",
            "scp-series-3",
            "scp-series-4",
            "scp-series-5",
            "scp-series-6",
            "scp-series-7",
            "scp-series-8",
            "scp-series-9",
            "scp-series-10",
            "scp-ex",
            "joke-scps"
        ]
        
        #if DEBUG
        if baseurlcomponents.count != LATEST_SERIES + 2 {
            fatalError("Update scrapeSubtitles urls")
        }
        #endif
        
        if series != nil {
            baseurlcomponents = [baseurlcomponents[series!]]
        }
        
        for baseurlcomp in baseurlcomponents {
            let baseurl = lang
                .toURL()
                .appending(component: baseurlcomp)
            var subtitles: [String:String] = [:]
            
            let task = URLSession.shared.dataTask(with: baseurl) { data, _, error in
                guard let data = data else { return }
                do {
                    let document = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
                    guard let panel = try document.getElementsByClass("content-panel standalone series").first() else { return }
                    var uls = try panel.select("ul").array()
                    
                    // Remove unrelated ul tags
                    uls = try uls.filter {
                        try $0.html().contains(Regex(#"<li><a href="\/.*?">SCP-.*?<\/a>.*?<\/li>"#))
                    }
                    
                    for hundredscps in uls {
                        let scps = try hundredscps.select("li").array()
                        for scp in scps {
                            /*
                             List of unsupported scps as of 11/7/25 (can be found by printing scp.html):
                             No dash: 5309
                             No scp number: 7498 6219 3183 4736
                             */
                            guard let endurlcomp = try scp.html().slice(from: "href=\"/", to: "\">") else { continue }
                            guard let subtitle = try scp.text().slice(from: " - ") else { continue }
                            
                            subtitles[endurlcomp] = subtitle
                        }
                    }
                    
                    // turn subtitles into comma separated values
                    let writestr = subtitles
                        .sorted { $0.key < $1.key }
                        .map { "\($0), \"\($1)\"" }
                        .joined(separator: "\n")
                    
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    
                    let subtitledir = documentsDirectory
                        .appendingPathComponent("Subtitles")
                        .appendingPathComponent(lang.toAbbr())
                    try FileManager.default.createDirectory(at: subtitledir, withIntermediateDirectories: true)
                    
                    let fileURL = subtitledir.appendingPathComponent("\(baseurlcomp).csv")
                    try writestr.write(to: fileURL, atomically: true, encoding: .utf8) // Deletes quotes in subtitles
                } catch {
                    print("Error saving subtitles: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    // https://d3g0gp89917ko0.cloudfront.net/v--7690939296dc/common--modules/js/forum/ForumViewThreadPostsModule.js
    static func getComments(url: URL, page: Int, language lang: RAISALanguage = .english, completion: @escaping ([Comment]?, Int?, Error?) -> Void) {
        guard let stringURL = URL(string: url.formatted().replacingOccurrences(of: "http://", with: "https://")) else { return }
        let task = URLSession.shared.dataTask(with: stringURL) { data, response, error in
            guard let data = data else { return }
            do {
                // Find forum url id
                let articledoc = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
                let forumurlid = try articledoc
                    .getElementById("discuss-button")?
                    .attr("href")
                    .asURL()
                    .formatted()
                    .slice(from: "/t-", to: "/")
                
                if forumurlid == nil { return }
                
                // Request
                var reqbody = [
                    "moduleName" : "forum/ForumViewThreadPostsModule",
                    "page_id" : "",
                    "pageNo" : page,
                    "t" : forumurlid ?? "",
                    "wikidot_token7" : "888888"
                ]
                findPageID(url: url) { id, _ in
                    reqbody["page_id"] = id
                    AF.request(
                        ajaxModuleURL(language: lang),
                        method: .post,
                        parameters: reqbody,
                        encoding: URLEncoding.default,
                        headers: baseHeaders
                    ).responseString { response in
                        guard let data = response.data else { return }
                        do {
                            let json = try JSON(data: data)
                            guard let body = json["body"].string else {
                                completion(nil, nil, RRError.textParsingError)
                                return
                            }
                            
                            // Parse comments
                            let doc = try SwiftSoup.parse(body)
                            
                            let maxpage = try Int(doc.html().slice(from: "page \(page) of ", to: "</span>") ?? "err") ?? 1
                            
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
                            
                            completion(returnComments, maxpage, nil)
                        } catch {
                            print(error)
                        }
                    }
                }
                
            } catch {
                print(error)
            }
        }
        task.resume()
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
    case invalidAuthenticationError
}

enum RRVote: String {
    case up = "+"
    case down = "-"
    case clear = "x"
}

//#Preview {
//    LoginView()
//}

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
