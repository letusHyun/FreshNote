//
//  DefaultProductRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 11/27/24.
//

import Combine
import Foundation

final class DefaultProductRepository: ProductRepository {
  private let firebaseNetworkService: any FirebaseNetworkService

  init(firebaseNetworkService: any FirebaseNetworkService) {
    self.firebaseNetworkService = firebaseNetworkService
  }

  func fetchProducts() -> AnyPublisher<[Product], any Error> {
    guard let userID = FirebaseUserManager.shared.userID else {
      return Fail(error: FirebaseUserError.invalidUid).eraseToAnyPublisher()
    }
    
    let fullPath = FirestorePath.products(userID: userID)
    
    let requestPublisher: AnyPublisher<[ProductResponseDTO], any Error> = self.firebaseNetworkService
      .getDocuments(collectionPath: fullPath)
    
    return requestPublisher.map { dtoArray -> [Product] in
      return dtoArray.compactMap { self.convertProduct($0) }
    }
    .eraseToAnyPublisher()
  }
  
  func saveProduct(product: Product) -> AnyPublisher<Void, any Error> {
    guard let userID = FirebaseUserManager.shared.userID else {
      return Fail(error: FirebaseUserError.invalidUid).eraseToAnyPublisher()
    }
    
    let urlString = product.imageURL?.absoluteString
    let didString = DocumentID().didString
    let fullPath = FirestorePath.product(userID: userID, productID: didString)
    let requestDTO = ProductRequestDTO(
      name: product.name,
      memo: product.memo,
      imageURLString: urlString,
      expirationDate: product.expirationDate,
      category: product.category,
      isPinned: product.isPinned,
      didString: didString
    )

    return self.firebaseNetworkService.setDocument(documentPath: fullPath, requestDTO: requestDTO, merge: true)
  }
}

// MARK: - Private Helpers
extension DefaultProductRepository {
  private func convertProduct(_ dto: ProductResponseDTO) -> Product? {
    guard let did = DocumentID(from: dto.didString) else { return nil }
    
    let imageURL = dto.imageURLString.flatMap { URL(string: $0) }
    
    return Product(
      did: did,
      name: dto.name,
      expirationDate: dto.expirationDate,
      category: dto.category,
      memo: dto.memo,
      imageURL: imageURL,
      isPinned: dto.isPinned
    )
  }
}
