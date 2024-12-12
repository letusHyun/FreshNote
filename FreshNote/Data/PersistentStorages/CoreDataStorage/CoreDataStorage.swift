//
//  CoreDataStorage.swift
//  FreshNote
//
//  Created by SeokHyun on 12/7/24.
//

import Combine
import CoreData
import Foundation

enum CoreDataStorageError: Error {
  case readError(Error)
  case saveError(Error)
  case deleteError(Error)
  case noEntity
}

final class CoreDataStorage {
  static let shared = CoreDataStorage()
  
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreDataStorage")
    container.loadPersistentStores { _, error in
      if let error = error {
        fatalError("CoreData store failed to load: \(error.localizedDescription)")
      }
    }
    return container
  }()
  
  private var context: NSManagedObjectContext {
    return self.persistentContainer.viewContext
  }
  
  func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, any Error> {
    return Future { [weak self] promise in
      self?.persistentContainer.performBackgroundTask { context in
        do {
          let result = try block(context)
          promise(.success(result))
        } catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
