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

  func saveProduct(product: Product, imageURLString: String?) -> AnyPublisher<Void, any Error> {
    guard let userID = FirebaseUserManager.shared.userID else {
      return Fail(error: FirebaseUserError.invalidUid).eraseToAnyPublisher()
    }
    
    let did = DocumentID().didString
    let fullPath = FirestorePath.item(userID: userID, itemID: did)
    let requestDTO = ProductRequestDTO(
      name: product.name,
      memo: product.memo,
      imageURLString: imageURLString,
      expirationDate: product.expirationDate,
      category: product.category,
      isPinned: product.isPinned,
      documentID: did
    )

    return self.firebaseNetworkService.setDocument(documentPath: fullPath, requestDTO: requestDTO, merge: true)
  }
}
