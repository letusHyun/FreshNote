//
//  SaveProductUseCase.swift
//  FreshNote
//
//  Created by SeokHyun on 11/27/24.
//

import Combine
import Foundation

protocol SaveProductUseCase: AnyObject {
  func execute() -> AnyPublisher<Void, Never>()
}

final class SaveProductUseCase: SaveProductUseCase {
  private let productRepository: any ProductRepository
  
  func execute() -> AnyPublisher<Void, Never> {
    
  }
}
