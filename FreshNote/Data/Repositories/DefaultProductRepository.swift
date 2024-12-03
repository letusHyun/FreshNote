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

  // TODO: - 테스트 해보고 잘 작동되면, 클로드에게 부탁해서 지저분한 코드 리펙토링하기. 리펙토링 후 또 실험해보기
  func fetchProducts() -> AnyPublisher<[Product], any Error> {
    guard let userID = FirebaseUserManager.shared.userID else {
      return Fail(error: FirebaseUserError.invalidUid).eraseToAnyPublisher()
    }
    
    let fullPath = FirestorePath.products(userID: userID)
    
    let requestPublisher: AnyPublisher<[ProductResponseDTO], any Error> = self.firebaseNetworkService
      .getDocuments(collectionPath: fullPath)
    
    return requestPublisher.map { responseDTOArr -> [Product] in
      
      var products: [Product] = []
      for responseDTO in responseDTOArr {
        if let did = DocumentID(from: responseDTO.didString) {
          if let imageURLString = responseDTO.imageURLString, let url = URL(string: imageURLString) {
            do {
              let product = Product(
                did: did,
                name: responseDTO.name,
                expirationDate: responseDTO.expirationDate,
                category: responseDTO.category,
                memo: responseDTO.memo,
                imageURL: url,
                isPinned: responseDTO.isPinned
              )
              products.append(product)
            } catch { }
          } else { // 이미지 실패 시,
            let product = Product(
              did: did,
              name: responseDTO.name,
              expirationDate: responseDTO.expirationDate,
              category: responseDTO.category,
              memo: responseDTO.memo,
              imageURL: nil,
              isPinned: responseDTO.isPinned
            )
            products.append(product)
          }
        }
      }
      return products
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
