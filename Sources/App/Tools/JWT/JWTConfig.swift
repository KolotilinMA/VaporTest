//
//  File.swift
//
//
//  Created by Михаил on 16.07.2024.
//

import Foundation
import JWT

enum JWTConfig {
	static let signerKey: HMACKey = "JWT_API_SIGNER_KEY" // Key for signing JWT Access Token
	static let algorithm: DigestAlgorithm = .sha256 // Algorithm and Type
//	static let signer = JWTSigner.hs256(key: JWTConfig.signerKey) // Signer for JWT
	static let expirationTime: TimeInterval = 60 * 60 * 24 // In seconds
}
