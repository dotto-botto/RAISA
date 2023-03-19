//
//  ArticleSpider.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/11/23.
//

import Foundation
import SwiftSoup
import SwiftyJSON

// https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-1.json

//func scpSpider(query: String) -> String {
//    do {
//        // MARK: - Series Checks
//        let queryInt = (query as NSString).integerValue
//
//        var linkString: String = ""
//
//        if queryInt > 1 && queryInt < 1000 { // Series 1
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-1.json"
//        } else if queryInt >= 1000 && queryInt < 2000 { // Series 2
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-2.json"
//        } else if queryInt >= 2000 && queryInt < 3000 { // Series 3
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-3.json"
//        } else if queryInt >= 3000 && queryInt < 4000 { // Series 4
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-4.json"
//        } else if queryInt >= 4000 && queryInt < 5000 { // Series 5
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-5.json"
//        } else if queryInt >= 5000 && queryInt < 5501 { // Series 6
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-6.0.json"
//        } else if queryInt >= 5501 && queryInt < 6000 {
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-6.5.json"
//        } else if queryInt >= 6000 && queryInt < 6500 { // Series 7
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-7.0.json"
//        } else if queryInt >= 6501 && queryInt < 7000 {
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-7.5.json"
//        } else if queryInt >= 7000 && queryInt < 7501 {
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-8.0.json"
//        } else if queryInt >= 7501 && queryInt < 8000 {
//            linkString = "https://raw.githubusercontent.com/scp-data/scp-api/main/docs/data/scp/items/content_series-8.5.json"
//        }
//
//        // MARK: - Spider
//        let link = URL(string: linkString)!
//        let html = try String(contentsOf: link)
//        let dataFromString = html.data(using: .utf8, allowLossyConversion: false)!
//        let jsonData = try JSON(data: dataFromString)
//
//        let source = jsonData["SCP-\(query)"]["raw_source"].string
//
//        return source ?? "Data could not be loaded; or there is no data"
//    } catch {}
//
//    return "An error occured"
//}
