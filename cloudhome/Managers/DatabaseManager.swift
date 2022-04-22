//
//  DatabaseManager.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 09/04/2022.
//

import Firebase

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let db = Firestore.firestore()
    
    struct UserNotFoundError: Error {}
    
    func addDeviceToUser(_ deviceId: String) async throws {
        guard let user = AuthManager.shared.user else {
            throw UserNotFoundError()
        }
        try await db.collection("users").document(user.uid).setData(["deviceIds": FieldValue.arrayUnion([deviceId])], mergeFields: ["deviceIds"])
    }
}
