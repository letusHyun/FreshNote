//
//  ProductEntity+Mapping.swift
//  FreshNote
//
//  Created by SeokHyun on 12/13/24.
//

import CoreData
import Foundation

extension ProductEntity {
  convenience init(product: Product, insertInto context: NSManagedObjectContext) {
    self.init(context: context)
    self.name = product.name
    self.memo = product.memo
    self.isPinned = product.isPinned
    self.category = product.category
    self.expirationDate = product.expirationDate
    self.didString = product.did.didString
    guard let url = product.imageURL else {
      self.imageData = nil
      return
    }
    
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      // 프로퍼티 초기화는 context의 스레드 내에서 수행되어야 합니다.
      context.perform {
        self?.imageData = data
      }
    }.resume()
  }
}
