//
//  ProductPinRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 11/14/24.
//

import Combine
import Foundation

protocol ProductPinRepository {
  func togglePinned(itemID: String) -> AnyPublisher<Void, any Error>
  func fetchPinnedProducts() -> AnyPublisher<[Product], any Error>
}
