//
//  Keychain.swift
//  SCP Utility
//
//  Created by Maximus Harding on 11/14/25.
//

import Foundation

struct Keychain {
    static func saveLogin(username: String, password: String) throws {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: password,
        ]
        
        let err = SecItemAdd(attributes as CFDictionary, nil)
        if err != noErr {
            throw KeychainError.saveLoginError
        }
    }
}

enum KeychainError: Error {
    case saveLoginError
}
