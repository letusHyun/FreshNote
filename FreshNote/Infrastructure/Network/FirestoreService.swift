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
  case encodingError
}

protocol FirestoreService {
  func getDocument<T: Decodable>(documentPath: String) -> AnyPublisher<T, any Error>
//  func getDocuments(documentPath: String, conditions: [String: Any]) -> AnyPublisher<[[String: Any]], any Error>
  func setDocument<T: Encodable>(documentPath: String, requestDTO: T, merge: Bool) -> AnyPublisher<Void, any Error>
}

final class DefaultFirestoreService: FirestoreService {
  private let firestore = Firestore.firestore()
  
//  func getDocument<T>(documentPath: String) -> AnyPublisher<T, any Error> where T : Decodable {
//    getDocument(documentPath: documentPath)
//      .tryMap { dictionary in
//        guard let decoded = T(dictionary: dictionary) else {
//          throw FirestoreServiceError.invalidData
//        }
//        
//        return decoded
//      }
//      .eraseToAnyPublisher()
//  }
  
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
  
  func setDocument<T: Encodable>(
    documentPath: String,
    requestDTO: T,
    merge: Bool
  ) -> AnyPublisher<Void, any Error> {
    return Future { [weak self] promise in
      guard let dictionary = try? requestDTO.toDictionary() else {
        return promise(.failure(FirestoreServiceError.encodingError))
      }
      
      self?.firestore.document(documentPath)
        .setData(dictionary, merge: merge) { error in
          if let error = error {
            promise(.failure(error))
          }
          promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
}

// MARK: - Private Helpers
extension DefaultFirestoreService {
  func getDocument<T: Decodable>(documentPath: String) -> AnyPublisher<T, any Error> {
    return Future { [weak self] promise in
      self?.firestore.document(documentPath).getDocument { (snapshot, error) in
        if let error = error {
          promise(.failure(error))
        }
        
        guard let dictionary = snapshot?.data() else { return promise(.failure(FirestoreServiceError.invalidData)) }
        
        do {
          let data = try JSONSerialization.data(withJSONObject: dictionary)
          let decodedDate = try JSONDecoder().decode(T.self, from: data)
          promise(.success(decodedDate))
        } catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
