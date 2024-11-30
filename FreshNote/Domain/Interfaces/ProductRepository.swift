//
//  ProductRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 11/27/24.
//

import Combine
import Foundation

protocol ProductRepository {
  func saveProduct(product: Product, imageURLString: String?) -> AnyPublisher<Void, any Error>
}
