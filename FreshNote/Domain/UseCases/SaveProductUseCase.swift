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
  func execute(requestValue: SaveProductUseCaseRequestValue) -> AnyPublisher<Product, any Error>
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
  
  func execute(requestValue: SaveProductUseCaseRequestValue) -> AnyPublisher<Product, any Error> {
    // 업데이트 된 경우
    // 이미지가 존재하지 않는 경우
    guard let imageData = requestValue.imageData else {
      let product = self.makeProduct(from: requestValue, url: nil)
      
      return self.productRepository.saveProduct(product: product)
        .map { return product }
        .eraseToAnyPublisher()
    }

    // 이미지가 존재하는 경우
    let fileName = UUID().uuidString
    return self.imageRepository
      .saveImage(with: imageData, fileName: fileName)
      .flatMap { [weak self] url in
        guard let self = self else { return Empty<Product, any Error>().eraseToAnyPublisher() }
        let product = self.makeProduct(from: requestValue, url: url)
        
        return self.productRepository
          .saveProduct(product: product)
          .retry(2)
          .catch { _ in
            return self.imageRepository.deleteImage(with: url)
              .flatMap {
                return Fail(error: SaveProductUseCaseError.failToSaveProduct).eraseToAnyPublisher()
              }
          }
          .map { return product }
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}

// MARK: - Private Helpers
extension DefaultSaveProductUseCase {
  private func makeProduct(from requestValue: SaveProductUseCaseRequestValue, url: URL?) -> Product {
    let dateFormatManager = DateFormatManager()
    
    return Product(
      did: DocumentID(),
      name: requestValue.name,
      expirationDate: requestValue.expirationDate,
      category: requestValue.category,
      memo: requestValue.memo,
      imageURL: url,
      isPinned: requestValue.isPinned,
      creationDate: dateFormatManager.makeCurrentDate()
    )
  }
}

// MARK: - Request Value
struct SaveProductUseCaseRequestValue {
  let name: String
  let expirationDate: Date
  let category: String
  let memo: String?
  let imageData: Data?
  let isPinned: Bool
}
