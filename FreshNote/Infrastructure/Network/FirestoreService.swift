//
//  FirestoreService.swift
//  FreshNote
//
//  Created by SeokHyun on 11/11/24.
//

import Combine
import Foundation

import FirebaseFirestore

enum FirestoreServiceError: Error {
  case invalidData
  case noUser
}

protocol FirestoreService {
  func getDocument<T: DTOable>(documentPath: String) -> AnyPublisher<T, any Error>
//  func getDocuments(documentPath: String, conditions: [String: Any]) -> AnyPublisher<[[String: Any]], any Error>
  func setDocument<T: DTOable>(documentPath: String, requestDTO: T, merge: Bool) -> AnyPublisher<Void, any Error>
}

final class DefaultFirestoreService: FirestoreService {
  private let firestore = Firestore.firestore()
  
  func getDocument<T>(documentPath: String) -> AnyPublisher<T, any Error> where T : DTOable {
    getDocument(documentPath: documentPath)
      .tryMap { dictionary in
        guard let decoded = T(dictionary: dictionary) else {
          throw FirestoreServiceError.invalidData
        }
        
        return decoded
      }
      .eraseToAnyPublisher()
  }
  
//  func getDocuments(
//    documentPath: String,
//    conditions: [String : Any]
//  ) -> AnyPublisher<[[String : Any]], any Error> {
//    var query: Query = firestore.collection(documentPath)
//    
//    conditions.forEach { field, condition in
//      query = query.whereField(field, isEqualTo: query)
//    }
//      
//  }
  
  func setDocument<T>(
    documentPath: String,
    requestDTO: T,
    merge: Bool
  ) -> AnyPublisher<Void, any Error> where T : DTOable {
    let dto = requestDTO.dictionary
    
    return Future { [weak self] promise in
      self?.firestore.document(documentPath)
        .setData(dto, merge: merge) { error in
          if let error = error { return promise(.failure(error)) }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
}

// MARK: - Private Helpers
extension DefaultFirestoreService {
  private func getDocument(documentPath: String) -> AnyPublisher<[String: Any], any Error> {
    return Future { [weak self] promise in
      self?.firestore.document(documentPath).getDocument { snapshot, error in
        if let error = error { return promise(.failure(error)) }
        
        guard let dictionary = snapshot?.data() else { return promise(.failure(FirestoreServiceError.invalidData)) }
        
        return promise(.success(dictionary))
      }
    }
    .eraseToAnyPublisher()
  }
}
