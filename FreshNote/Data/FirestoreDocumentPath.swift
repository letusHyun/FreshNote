//
//  FirestoreDocumentPath.swift
//  FreshNote
//
//  Created by SeokHyun on 10/26/24.
//

import Foundation
import FirebaseFirestore

enum FirestoreDocumentPath {
  case user(userID: String)
  case item(userID: String, itemID: String)
}

extension FirestoreDocumentPath {
  func reference(db: Firestore) -> DocumentReference {
    let commonPath = db.collection("users")
    
    switch self {
    case .user(let userID):
      return commonPath.document(userID)
    case let .item(userID, itemID):
      return commonPath.document(userID).collection("items").document(itemID)
    }
  }
}
