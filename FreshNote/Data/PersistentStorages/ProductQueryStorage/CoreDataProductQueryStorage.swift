//
//  CoreDataProductQueryStorage.swift
//  FreshNote
//
//  Created by SeokHyun on 12/10/24.
//

import Combine
import CoreData
import Foundation

final class CoreDataProductQueryStorage {
  private let coreDataStorage: CoreDataStorage
  
  init(coreDataStorage: CoreDataStorage = .shared) {
    self.coreDataStorage = coreDataStorage
  }
}

extension CoreDataProductQueryStorage: ProductQueryStorage {
  func saveQuery(productQuery: ProductQuery) -> AnyPublisher<ProductQuery, any Error> {
    return self.coreDataStorage
      .performBackgroundTask { context -> ProductQuery in
        _ = ProductQueryEntity(productQuery: productQuery, insertInto: context)
    
        do {
          try context.save()
          return productQuery
        } catch {
          throw CoreDataStorageError.saveError(error)
        }
      }
      .eraseToAnyPublisher()
  }
  
  func fetchQueries() -> AnyPublisher<[ProductQuery], any Error> {
    self.coreDataStorage
      .performBackgroundTask { context -> [ProductQuery] in
        let request: NSFetchRequest<ProductQueryEntity> = ProductQueryEntity.fetchRequest()
        request.sortDescriptors = [
          NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        
        do {
          // 데이터 존재하지 않는 경우, 빈 배열 반환
          let entities = try context.fetch(request)
          return entities.map { $0.toDomain() }
        } catch {
          throw CoreDataStorageError.readError(error)
        }
      }
      .eraseToAnyPublisher()
  }
  
  func deleteQuery(uuidString: String) -> AnyPublisher<Void, any Error> {
    self.coreDataStorage
      .performBackgroundTask { context -> Void in
        let request: NSFetchRequest<ProductQueryEntity> = ProductQueryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuidString)
        let entities = try context.fetch(request)
        
        guard !entities.isEmpty else {
          throw CoreDataStorageError.noEntity
        }
        
        entities.forEach { entity in
          context.delete(entity)
        }
        
        do {
          try context.save()
        } catch {
          throw CoreDataStorageError.saveError(error)
        }
      }
  }
}
