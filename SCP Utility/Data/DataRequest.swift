//
//  DataRequest.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/11/23.
//

import Foundation
import CoreData

enum ArticleItemRequestType {
    case clearance(_ raw: String? = nil)
    case completed(_ raw: Bool? = nil)
    case currenttext(_ raw: String? = nil)
    case disruption(_ raw: Int16? = nil)
    case esoteric(_ raw: Int16? = nil)
    case identifier(_ raw: String? = nil)
    case objclass(_ raw: Int16? = nil)
    case pagesource(_ raw: String? = nil)
    case risk(_ raw: Int16? = nil)
    case thumbnail(_ raw: URL? = nil)
    case title(_ raw: String? = nil)
    case url(_ raw: URL? = nil)
    
    func toPredicate() -> String {
        switch self {
        case .clearance:
            return "clearance"
        case .completed:
            return "completed"
        case .currenttext:
            return "currenttext"
        case .disruption:
            return "disruption"
        case .esoteric:
            return "esoteric"
        case .identifier:
            return "identifier"
        case .objclass:
            return "objclass"
        case .pagesource:
            return "pagesource"
        case .risk:
            return "risk"
        case .thumbnail:
            return "thumbnail"
        case .title:
            return "title"
        case .url:
            return "url"
        }
    }
    
    func toCVArg() -> CVarArg? {
        switch self {
        case .clearance(let str):
            return str
        case .completed(let bool):
            return bool
        case .currenttext(let str):
            return str
        case .disruption(let int):
            return int
        case .esoteric(let int):
            return int
        case .identifier(let str):
            return str
        case .objclass(let int):
            return int
        case .pagesource(let str):
            return str
        case .risk(let int):
            return int
        case .thumbnail(let url):
            guard let url = url else { return nil }
            return url as CVarArg
        case .title(let str):
            return str
        case .url(let url):
            guard let url = url else { return nil }
            return url as CVarArg
        }
    }
}

extension PersistenceController {
    func getArticleItem(
        withAttr id: ArticleItemRequestType,
        return attr: ArticleItemRequestType? = nil,
        context: NSManagedObjectContext? = nil
    ) -> (ArticleItemRequestType?, ArticleItem?) {
        let context = context ?? container.viewContext
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        
        precondition(id.toCVArg() != nil, "Getter attribute was not given a value.")
        let arg = id.toCVArg()!
        object.predicate = NSPredicate(format: "\(id.toPredicate()) == %@", arg)
        
        var newObject: ArticleItemRequestType?
        
        do {
            guard let articleItem = try context.fetch(object).first else { return (nil,nil) }
            try context.save()

            switch attr {
            case .none:
                return (nil, articleItem)
            case .some(let wrapped):
                return (wrapped, nil)
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return (newObject, nil)
    }
}
