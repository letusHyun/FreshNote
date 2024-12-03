//
//  SaveProductUseCase.swift
//  FreshNote
//
//  Created by SeokHyun on 11/27/24.
//

import Combine
import Foundation

enum SaveProductUseCaseError: Error {
  case failToSaveProduct
  
  var errorDescription: String? {
    switch self {
    case .failToSaveProduct:
      return "제품 저장에 실패했습니다."
    }
  }
}

protocol SaveProductUseCase: AnyObject {
  func save(requestValue: SaveProductUseCaseRequestValue) -> AnyPublisher<Void, any Error>
}

final class DefaultSaveProductUseCase: SaveProductUseCase {
  private let productRepository: any ProductRepository
  private let imageRepository: any ImageRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  init(
    productRepository: any ProductRepository,
    imageRepository: any ImageRepository
  ) {
    self.productRepository = productRepository
    self.imageRepository = imageRepository
  }
  
  func save(requestValue: SaveProductUseCaseRequestValue) -> AnyPublisher<Void, any Error> {
//    let product = Product(
//      did: DocumentID(),
//      name: requestValue.name,
//      expirationDate: requestValue.expirationDate,
//      category: requestValue.category,
//      memo: requestValue.memo,
//      imageURL: requestValue.imageData,
//      isPinned: requestValue.isPinned
//    )
    
    guard let imageData = requestValue.imageData else {
      let product = Product(
        did: DocumentID(),
        name: requestValue.name,
        expirationDate: requestValue.expirationDate,
        category: requestValue.category,
        memo: requestValue.memo,
        imageURL: nil,
        isPinned: requestValue.isPinned
      )
      return self.productRepository.saveProduct(product: product)
    }

    return self.imageRepository
      .saveImage(with: imageData, fileName: UUID().uuidString)
      .flatMap { [weak self] url in
        guard let self = self else { return Empty<Void, any Error>().eraseToAnyPublisher() }
        let product = Product(
          did: DocumentID(),
          name: requestValue.name,
          expirationDate: requestValue.expirationDate,
          category: requestValue.category,
          memo: requestValue.memo,
          imageURL: url,
          isPinned: requestValue.isPinned
        )
        
        return self.productRepository
          .saveProduct(product: product)
          .retry(2)
          .catch { _ in
            return self.imageRepository.deleteImage(with: url.absoluteString)
              .flatMap {
                return Fail(error: SaveProductUseCaseError.failToSaveProduct).eraseToAnyPublisher()
              }
          }
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}

struct SaveProductUseCaseRequestValue {
  let name: String
  let expirationDate: Date
  let category: String
  let memo: String?
  let imageData: Data?
  let isPinned: Bool?
}
