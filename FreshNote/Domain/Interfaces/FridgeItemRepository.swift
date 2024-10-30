//
//  FridgeItemRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 10/24/24.
//

import Foundation
import FirebaseFirestore
import Combine

protocol FridgeItemRepository {
  func fetchItems() -> AnyPublisher<[Void], Error>
  func addItem() -> AnyPublisher<Void, Error>
  func updateItem() -> AnyPublisher<Void, Error>
  func deleteItem() -> AnyPublisher<Void, Error>
  func deleteAllItems() -> AnyPublisher<Void, Error>
}
