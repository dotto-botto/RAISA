//
//  DataController.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/13/23.
//

import CoreData
import Foundation

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

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

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "Model")

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
                let _ = PersistenceController(inMemory: false)
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
        object.predicate = NSPredicate(format: "listid == %@", list.listid)
        
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
    func deleteArticleEntity(articleitem: Article, context: NSManagedObjectContext? = nil) {
        let context = context ?? container.viewContext
        
        let object = NSFetchRequest<ArticleItem>(entityName: "ArticleItem")
        object.predicate = NSPredicate(format: "identifier == %@", articleitem.id)
        
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
            newObject = try context.fetch(object).first // first returns nil so array is empty
            
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
    func setScroll(text: String, articleid: String, context: NSManagedObjectContext? = nil) {
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
                }
            }
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
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
    
    /// Create a new History object for core data.
    @discardableResult
    func createHistory(from history: History, context: NSManagedObjectContext? = nil) -> HistoryItem {
        let context = context ?? container.viewContext
        
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
        
        return object
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
