//
//  DataController.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/13/23.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        
        let controller = PersistenceController(inMemory: true)
        
        let listTitles = [
            "Tufto's Proposal",
            "SCP-999",
            "SCP-173",
            "SCP-2317",
        ]
        
        for i in listTitles {
            controller.createListEntity(list: SCPList(listid: i))
        }
        
        controller.save()
        
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Model")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
    
    /// Delete all core data.
    func deleteAllData(context: NSManagedObjectContext? = nil) {
        deleteAllLists(context: context)
        deleteAllArticles(context: context)
        #if os(iOS)
        deleteAllHistory(context: context)
        #endif
    }
}


// MARK:  - List Operations
extension PersistenceController { // Lists
    /// Retrieve all saved list entities.
    func getAllLists(context: NSManagedObjectContext? = nil) -> [SCPListItem]? {
        let context = context ?? container.viewContext
        
        var lists = [SCPListItem]()
        let request = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        
        do {
            lists = try context.fetch(request)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return lists
    }
    
    /// Create a new list object for core data.
    @discardableResult
    func createListEntity(list: SCPList, context: NSManagedObjectContext? = nil) -> SCPListItem {
        let context = context ?? container.viewContext
        
        let object = SCPListItem(context: context)
        
        object.identifier = list.id
        object.listid = list.listid
        
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        
        return object
    }
    
    /// Add an article to a core data list object.
    func addArticleToList(list: SCPList, article: Article, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        object.predicate = NSPredicate(format: "identifier == %@", list.id)
        
        do {
            if let content = try context.fetch(object).first {
                if content.contents != nil {
                    content.contents!.append(article.title)
                } else {
                    content.contents = [article.title]
                }
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Add an article to a core data list object using the list id.
    func addArticleToListFromId(listid: String, article: Article, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let object = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        object.predicate = NSPredicate(format: "listid == %@", listid)

        do {
            if let content = try context.fetch(object).first {
                if content.contents != nil {
                    content.contents!.append(article.id)
                } else {
                    content.contents = [article.id]
                }
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Update list title.
    func updateListTitle(newTitle: String, list: SCPList, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        request.predicate = NSPredicate(format: "identifier == %@", list.id)

        do {
            if let list = try context.fetch(request).first {
                list.listid = newTitle
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Update list subtitle.
    func updateListSubtitle(newTitle: String, list: SCPList, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        request.predicate = NSPredicate(format: "identifier == %@", list.id)

        do {
            if let list = try context.fetch(request).first {
                list.subtitle = newTitle
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Delete a list entity.
    ///
    /// - Parameters:
    ///  - listitem: The entity.
    func deleteListEntity(listitem: SCPList, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        object.predicate = NSPredicate(format: "listid == %@", listitem.listid)
        
        do {
            let listEntities = try context.fetch(object)
            
            if let entity = listEntities.first {
                context.delete(entity)
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    /// Returns true if id is in a list.
    func isIdInList(listid: String, articleid id: String, context: NSManagedObjectContext? = nil) -> Bool {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        object.predicate = NSPredicate(format: "identifier == %@", listid)
        
        do {
            if let list = try context.fetch(object).first {
                if let contents = list.contents {
                    for listids in contents {
                        if listids == id { return true }
                    }
                }
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        return false
    }
    
    func removeIdFromList(listIdentifier listid: String, idToRemove id: String, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        object.predicate = NSPredicate(format: "identifier == %@", listid)
        
        do {
            if let list = try context.fetch(object).first, let contents = list.contents {
                list.contents = contents.filter { $0 != id }
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Retrieve a list from the core data store using its id.
    func getListByID(id: String, context: NSManagedObjectContext? = nil) -> SCPListItem? {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        object.predicate = NSPredicate(format: "identifier == %@", id)

        var newObject: SCPListItem?
        
        do {
            newObject = try context.fetch(object).first
            
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return newObject
    }
    
    /// Delete all list items in core data.
    func deleteAllLists(context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let objects = NSFetchRequest<SCPListItem>(entityName: "SCPListItem")
        
        do {
            let lists = try context.fetch(objects)
            for i in lists {
                context.delete(i)
            }
        } catch {
            print(error)
        }
    }
}


// MARK: - Article Operations
extension PersistenceController {
    
    /// Create a new Article object for core data.
    @discardableResult
    func createArticleEntity(article: Article, context: NSManagedObjectContext? = nil) -> ArticleItem {
        let context = context ?? container.viewContext
        
        let object = ArticleItem(context: context)
        
        object.identifier = article.id
        object.title = article.title
        object.pagesource = article.pagesource
        object.thumbnail = article.thumbnail
        object.currenttext = article.currenttext
        object.url = article.url
        
        object.objclass = article.objclass?.rawValue ?? ObjectClass.unknown.rawValue
        object.esoteric = article.esoteric?.rawValue ?? EsotericClass.unknown.rawValue
        object.disruption = article.disruption?.rawValue ?? DisruptionClass.unknown.rawValue
        object.risk = article.risk?.rawValue ?? RiskClass.unknown.rawValue
        
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        
        return object
    }
    
    /// Delete an Article entity.
    ///
    /// - Parameters:
    ///  - articleitem: The entity.
    func deleteArticleEntity(id: String, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        object.predicate = NSPredicate(format: "identifier == %@", id)
        
        do {
            let entities = try context.fetch(object)
            
            if let entity = entities.first {
                context.delete(entity)
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Retrieve an article from the core data store using its title.
    func getArticleByTitle(title: String, context: NSManagedObjectContext? = nil) -> ArticleItem? {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        object.predicate = NSPredicate(format: "title == %@", title)

        var newObject: ArticleItem?
        
        do {
            newObject = try context.fetch(object).first
            
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return newObject
    }
    
    /// Retrieve an article from the core data store using its id.
    func getArticleByID(id: String, context: NSManagedObjectContext? = nil) -> ArticleItem? {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        object.predicate = NSPredicate(format: "identifier == %@", id)

        var newObject: ArticleItem?
        
        do {
            newObject = try context.fetch(object).first
            
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return newObject
    }
    
    func getArticleByURL(url: URL, context: NSManagedObjectContext? = nil) -> ArticleItem? {
        let context = context ?? container.viewContext
        
        if url == URL(string: "https://scp-wiki.wikidot.com/") { return nil }
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        object.predicate = NSPredicate(format: "url == %@", url as CVarArg)

        var newObject: ArticleItem?
        
        do {
            newObject = try context.fetch(object).first
            
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return newObject
    }
    
    /// Return all articles in a list.
    func getAllListArticles(list: SCPList, context: NSManagedObjectContext? = nil) -> [ArticleItem]? {
        let context = context ?? container.viewContext
        guard list.contents != nil else {return nil}
        
        var articles = [ArticleItem]()
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        for id in list.contents! {
            object.predicate = NSPredicate(format: "identifier == %@", id)
            do {
                if let toAdd = try context.fetch(object).first {
                    articles.append(toAdd)
                }
                
                try context.save()
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        
        return articles
    }
    
    /// Retrieve all saved article entities.
    func getAllArticles(context: NSManagedObjectContext? = nil) -> [ArticleItem]? {
        let context = context ?? container.viewContext
        
        var articles = [ArticleItem]()
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        
        do {
            articles = try context.fetch(request)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return articles
    }
    
    /// Update scroll progress.
    func setScroll(text: String?, articleid: String, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", articleid)

        do {
            if let article = try context.fetch(request).first {
                article.currenttext = text
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Returns the scroll variable from core data.
    /// - Parameters:
    ///   - id: The article's id
    /// - Returns: The text stored in core data.
    func getScroll(id: String, context: NSManagedObjectContext? = nil) -> String? {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", id)

        do {
            if let article = try context.fetch(request).first {
                return article.currenttext
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    /// Deletes the page source of an article by setting it to an empty string.
    func deletePageSource(id: String, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", id)

        do {
            if let article = try context.fetch(request).first {
                article.pagesource = ""
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Sets the page source of a core data article.
    func updatePageSource(id: String, newPageSource source: String, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", id)

        do {
            if let article = try context.fetch(request).first {
                article.pagesource = source
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Update the object class of an article.
    func updateObjectClass(articleid: String, newattr: ObjectClass, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", articleid)
        
        do {
            if let article = try context.fetch(request).first {
                switch newattr {
                case .safe: article.objclass = 0
                case .euclid: article.objclass = 1
                case .keter: article.objclass = 2
                case .neutralized: article.objclass = 3
                case .pending: article.objclass = 4
                case .explained: article.objclass = 5
                case .esoteric: article.objclass = 6
                case .unknown: return
                }
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Update the esoteric class of an article.
    func updateEsotericClass(articleid: String, newattr: EsotericClass, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", articleid)
        
        do {
            if let article = try context.fetch(request).first {
                switch newattr {
                case .apollyon: article.esoteric = 0
                case .archon: article.esoteric = 1
                case .cernunnos: article.esoteric = 2
                case .decommissioned: article.esoteric = 3
                case .hiemal: article.esoteric = 4
                case .tiamat: article.esoteric = 5
                case .ticonderoga: article.esoteric = 6
                case .thaumiel: article.esoteric = 7
                case .uncontained: article.esoteric = 8
                case .unknown: return
                }
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Update the disruption class of an article.
    func updateDisruptionClass(articleid: String, newattr: DisruptionClass, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", articleid)
        
        do {
            if let article = try context.fetch(request).first {
                switch newattr {
                case .dark: article.disruption = 0
                case .vlam: article.disruption = 1
                case .keneq: article.disruption = 2
                case .ekhi: article.disruption = 3
                case .amida: article.disruption = 4
                case .unknown: return
                }
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Update the risk class of an article.
    func updateRiskClass(articleid: String, newattr: RiskClass, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", articleid)
        
        do {
            if let article = try context.fetch(request).first {
                switch newattr {
                case .notice: article.risk = 0
                case .caution: article.risk = 1
                case .warning: article.risk = 2
                case .danger: article.risk = 3
                case .critical: article.risk = 4
                case .unknown: return
                }
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Mark article as complete or incomplete.
    /// - Parameters:
    ///   - status: True if article is complete.
    func complete(status: Bool, article: Article, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", article.id)

        do {
            if let article = try context.fetch(request).first {
                article.completed = status
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// Get completion status of an article.
    func completionStatus(article: Article, context: NSManagedObjectContext? = nil) -> Bool {
        let context = context ?? container.viewContext

        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", article.id)

        do {
            if let article = try context.fetch(request).first {
                if article.completed == true {
                    return true
                } else {
                    return false
                }
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        return false
    }
    
    /// Delete all article items in core data.
    func deleteAllArticles(context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let objects = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        
        do {
            let articles = try context.fetch(objects)
            for i in articles {
                context.delete(i)
            }
        } catch {
            print(error)
        }
    }
    
    func isArticleSaved(url: URL, context: NSManagedObjectContext? = nil) -> Bool {
        let context = context ?? container.viewContext
        
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "url == %@", url as CVarArg)
        
        do {
            if try context.fetch(request).first != nil {
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func isArticleSaved(id: String, context: NSManagedObjectContext? = nil) -> Bool? {
        let context = context ?? container.viewContext
        
        let request = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        request.predicate = NSPredicate(format: "identifier == %@", id)
        
        do {
            if try context.fetch(request).first != nil {
                return true
            }
        } catch {
            print(error)
            return nil
        }
        
        return false
    }
}

// MARK: - History Operations
#if os(iOS)
extension PersistenceController {
    /// Retrieve all saved history entities.
    func getAllHistory(context: NSManagedObjectContext? = nil) -> [HistoryItem]? {
        let context = context ?? container.viewContext
        
        var history = [HistoryItem]()
        let request = NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
        
        do {
            history = try context.fetch(request)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return history
    }
    
    /// Retrieve the latest logged history entry.
    func getLatestHistory(context: NSManagedObjectContext? = nil) -> HistoryItem? {
        let context = context ?? container.viewContext
        
        var history: HistoryItem?
        let request = NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
        
        do {
            history = try context.fetch(request).last
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return history
    }
    
    /// Create a new History object for core data if it hasnt been saved in the past 24 hours.
    /// - Returns: true if successful
    @discardableResult
    func createHistory(from history: History, context: NSManagedObjectContext? = nil) -> Bool {
        let context = context ?? container.viewContext
        
        if let allHistory = PersistenceController.shared.getAllHistory() {
            for item in allHistory {
                let newHistory = History(fromEntity: item)!
                if newHistory.articletitle == history.articletitle { return false }
            }
        }
        
        let object = HistoryItem(context: context)
        
        object.identifier = history.id
        object.articletitle = history.articletitle
        object.date = Date()
        object.thumbnail = history.thumbnail
        
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        
        return true
    }
    
    /// Delete a specific history object from its id.
    func deleteHistoryFromId(id: String, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
                
        let object = NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
        object.predicate = NSPredicate(format: "identifier == %@", id)
        
        do {
            let entities = try context.fetch(object)
            
            if let entity = entities.first {
                context.delete(entity)
            }
            
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Delete all history items in core data.
    func deleteAllHistory(context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let objects = NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
        
        do {
            let history = try context.fetch(objects)
            for i in history {
                context.delete(i)
            }
        } catch {
            print(error)
        }
    }
}
#endif
