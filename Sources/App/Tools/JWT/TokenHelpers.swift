//
//  TokenHelpers.swift
//
//
//  Created by Михаил on 16.07.2024.
//

import Foundation
import JWT

class TokenHelpers {
	
	/// Create payload for Access Token
	class func createPayload(from user: User) throws -> AccessTokenPayload {
		if let userId = user.id {
			let payload = AccessTokenPayload(
				subject: SubjectClaim(value: userId.uuidString),
				name: user.name,
				userID: userId, 
				login: user.login,
				isAdmin: false
			)
			
			return payload
		} else {
			throw JWTError.invalidJWK
		}
	}
//	
//	/// Create Access Token for user
//	class func createAccessToken(from user: User) throws -> String {
//		let payload = try TokenHelpers.createPayload(from: user)
//		let header = JWTConfig.header
//		let signer = JWTConfig.signer
//		let jwt = JWT<AccessTokenPayload>(header: header, payload: payload)
//		let tokenData = try signer.sign(jwt)
//		
//		if let token = String(data: tokenData, encoding: .utf8) {
//			return token
//		} else {
//			throw JWTError.createJWT
//		}
//	}
//	
//	/// Get expiration date of token
//	class func expiredDate(of token: String) throws -> Date {
//		let receivedJWT = try JWT<AccessTokenPayload>(from: token, verifiedUsing: JWTConfig.signer)
//		
//		return receivedJWT.payload.expirationAt.value
//	}
//	
//	/// Verify token is valid or not
//	class func verifyToken(_ token: String) throws {
//		do {
//			let _ = try JWT<AccessTokenPayload>(from: token, verifiedUsing: JWTConfig.signer)
//		} catch {
//			throw JWTError.verificationFailed
//		}
//	}
//	
//	/// Get user ID from token
//	class func getUserID(fromPayloadOf token: String) throws -> Int {
//		do {
//			let receivedJWT = try JWT<AccessTokenPayload>(from: token, verifiedUsing: JWTConfig.signer)
//			let payload = receivedJWT.payload
//			
//			return payload.userID
//		} catch {
//			throw JWTError.verificationFailed
//		}
//	}
	
	/// Generate new Refresh Token
	class func createRefreshToken() -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0 ... 40).map { _ in letters.randomElement()! })
	}
}
