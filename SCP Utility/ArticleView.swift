//
//  ArticleView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation
import SwiftSoup

// https://scp-wiki.wikidot.com/scp-999

func erroralert(title: String, message: String) { // https://www.appsdeveloperblog.com/how-to-show-an-alert-in-swift/
    print("An error occured. \(message)")
//    let message = UIAlertController(title: title, message: message, preferredStyle: .alert)
//    let ok = UIAlertAction(title: "OK", style: .default)
//
//    message.addAction(ok)
//    message.present(message, animated: true, completion: nil)
}

func Scraper(url: String) async -> (title: String, body:String) {
    let link = URL(string: url)!
    
    do {
        let html = try String(contentsOf: link)
//        let html = try SwiftSoup.clean(unsafehtml, Whitelist.basic())! doesnt work
        let doc: Document = try SwiftSoup.parse(html)
        let body: String? = try doc.getElementById("page-content")?.text()
        
        let articletitle: String? = try doc.getElementById("page-title")?.text()
        
        var returntuple = ("","")
        if articletitle == nil {
            returntuple.0 = "[Could not detect title]"
        }
        else {
            returntuple.0 = articletitle!
        }
        if body == nil {
            erroralert(title: "Error", message: "Could not detect body")
        }
        else {
            returntuple.1 = body!
        }
        
        return returntuple
        
    } catch Exception.Error(_, let message) {
        erroralert(title: "Error", message: message)
    } catch {
        erroralert(title: "Error", message: "An unknown error occured")

    }
    return ("","")
}

struct ArticleView: View {
    @State var scpquery: String
    var body: some View {
        var document = (body: "Loading...", title: "")
        NavigationView {
            ScrollView {
                VStack {
                    Text(document.body)
                }
            }
            .navigationTitle(document.title)
        }.task {
            var document = await Scraper(url: "https://scp-wiki.wikidot.com/scp-\(scpquery)")
        }
    }
}

//struct ArticleView_Previews: PreviewProvider {
//    struct Preview: View{
//        @State private var query: String??
//        static var previews: some View {
//            ArticleView(scpquery: $query)
//        }
//    }
//    static var previews: some View {
//        Preview()
//    }
//}
