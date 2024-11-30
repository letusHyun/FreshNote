//
//  DefaultImageRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 11/29/24.
//

import Combine
import Foundation

final class DefaultImageRepository: ImageRepository {
  private let firebaseNetworkService: any FirebaseNetworkService
  
  init(firebaseNetworkService: any FirebaseNetworkService) {
    self.firebaseNetworkService = firebaseNetworkService
  }
  
  func saveImage(with data: Data, fileName: String) -> AnyPublisher<URL, any Error> {
    guard let userID = FirebaseUserManager.shared.userID else {
      return Fail(error: FirebaseUserError.invalidUid).eraseToAnyPublisher()
    }
    
    return self.firebaseNetworkService.uploadData(path: userID, fileName: fileName, data: data)
  }
  
  func deleteImage(with urlString: String) -> AnyPublisher<Void, any Error> {
    self.firebaseNetworkService.deleteData(path: urlString)
  }
}
