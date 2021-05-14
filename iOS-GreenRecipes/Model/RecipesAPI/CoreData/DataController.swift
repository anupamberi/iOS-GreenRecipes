//
//  DataController.swift
//  iOS-GreenRecipes
//
//  Created by Anupam Beri on 13/05/2021.
//

import Foundation
import CoreData

/// Core Data Stack
class DataController {
  let persistentContainer: NSPersistentContainer

  var viewContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }

  var backgroundContext: NSManagedObjectContext {
    return persistentContainer.newBackgroundContext()
  }

  init(modelName: String) {
    persistentContainer = NSPersistentContainer(name: modelName)
  }

  func configureContexts() {
    viewContext.automaticallyMergesChangesFromParent = true
    backgroundContext.automaticallyMergesChangesFromParent = true

    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
  }

  func load(completion: (() -> Void)? = nil) {
    persistentContainer.loadPersistentStores { _, error in
      guard error == nil else {
        fatalError(error!.localizedDescription)
      }
      self.configureContexts()
      completion?()
    }
  }

  func saveContext() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
