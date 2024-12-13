//
//  CoreDataProductStorage.swift
//  FreshNote
//
//  Created by SeokHyun on 12/12/24.
//

import Combine
import Foundation

final class CoreDataProductStorage: ProductStorage {
  private let coreDataStorage: any CoreDataStorage
  
  init(coreDataStorage: any CoreDataStorage) {
    self.coreDataStorage = coreDataStorage
  }
  
  func saveProduct(with product: Product) -> AnyPublisher<Void, any Error> {
    self.coreDataStorage.performBackgroundTask { context in
      _ = ProductEntity(product: product, insertInto: context)
      do {
        try context.save()
      } catch {
        throw CoreDataStorageError.saveError(error)
      }
    }
    .eraseToAnyPublisher()
  }
  
  func fetchProducts() -> AnyPublisher<[Product], any Error> {
    <#code#>
  }
}
