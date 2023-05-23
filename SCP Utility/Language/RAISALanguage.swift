//
//  RAISALanguage.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/21/23.
//

import Foundation

// https://scp-wiki.wikidot.com/scp-international

/// Enum for the international translations of scp articles.
/// This is NOT the same as localization for app text.
enum RAISALanguage {
    case english
    case russian
    case korean
    case chinese
    case french
    case polish
    case spanish
    case thai
    case japanese
    case german
    case italian
    case ukranian
    case portuguese
    case czech
    case traditionalch
    case vietnamese
    
    func toURL() -> URL {
        switch self {
        case .english:
            return URL(string: "http://scp-wiki.wikidot.com/")!
        case .russian:
            return URL(string: "http://scpfoundation.net/")!
        case .korean:
            return URL(string: "http://ko.scp-wiki.net/")!
        case .chinese:
            return URL(string: "http://scp-wiki-cn.wikidot.com/")!
        case .french:
            return URL(string: "http://fondationscp.wikidot.com/")!
        case .polish:
            return URL(string: "http://scp-pl.wikidot.com/")!
        case .spanish:
            return URL(string: "http://lafundacionscp.wikidot.com/")!
        case .thai:
            return URL(string: "http://scp-th.wikidot.com/")!
        case .japanese:
            return URL(string: "http://scp-jp.wikidot.com/")!
        case .german:
            return URL(string: "http://scp-wiki-de.wikidot.com/")!
        case .italian:
            return URL(string: "http://fondazionescp.wikidot.com/")!
        case .ukranian:
            return URL(string: "http://scp-ukrainian.wikidot.com/")!
        case .portuguese:
            return URL(string: "http://scp-pt-br.wikidot.com/")!
        case .czech:
            return URL(string: "http://scp-cs.wikidot.com/")!
        case .traditionalch:
            return URL(string: "http://scp-zh-tr.wikidot.com/")!
        case .vietnamese:
            return URL(string: "http://scp-vn.wikidot.com/")!
        }
    }
}
