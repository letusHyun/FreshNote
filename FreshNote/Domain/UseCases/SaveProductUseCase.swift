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
  func save(product: Product) -> AnyPublisher<Void, any Error>
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
  
  func save(product: Product) -> AnyPublisher<Void, any Error> {
    guard let imageData = product.imageData else {
      return self.productRepository.saveProduct(product: product, imageURLString: nil)
    }

    return self.imageRepository
      .saveImage(with: imageData, fileName: UUID().uuidString)
      .flatMap { [weak self] url in
        guard let self = self else { return Empty<Void, any Error>().eraseToAnyPublisher() }
        
        let urlString = url.absoluteString
        return self.productRepository
          .saveProduct(product: product, imageURLString: urlString)
          .retry(2)
          .catch { _ in
            return self.imageRepository.deleteImage(with: urlString)
              .flatMap {
                return Fail(error: SaveProductUseCaseError.failToSaveProduct).eraseToAnyPublisher()
              }
          }
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}
