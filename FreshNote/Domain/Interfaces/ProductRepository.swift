//
//  ProductRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 11/27/24.
//

import Combine
import Foundation

protocol ProductRepository {
  func saveProduct(product: Product) -> AnyPublisher<Void, any Error>
  func fetchProducts() -> AnyPublisher<[Product], any Error>
  func deleteProduct(didString: String) -> AnyPublisher<Void, any Error>
}
