//
//  ProductStorage.swift
//  FreshNote
//
//  Created by SeokHyun on 12/12/24.
//

import Combine
import Foundation

protocol ProductStorage {
  func saveProduct(with product: Product) -> AnyPublisher<Void, any Error>
  func fetchProducts() -> AnyPublisher<[Product], any Error>
}
