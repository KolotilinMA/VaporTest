//
//  AccessTokenPayload.swift
//
//
//  Created by Михаил on 16.07.2024.
//

import Foundation
import JWT

struct AccessTokenPayload: JWTPayload {
	
	internal init(
		subject: SubjectClaim,
		expirationAt: Date = Date().addingTimeInterval(JWTConfig.expirationTime),
		issuedAt: Date = Date(),
		name: String,
		userID: UUID,
		login: String,
		isAdmin: Bool
	) {
		self.subject = subject
		self.expirationAt = ExpirationClaim(value: expirationAt)
		self.issuedAt = IssuedAtClaim(value: issuedAt)
		self.name = name
		self.userID = userID
		self.login = login
		self.isAdmin = isAdmin
	}
	
	
	enum CodingKeys: String, CodingKey {
		case subject = "sub"
		case issuedAt = "iat"
		case expirationAt = "exp"
		case name = "name"
		case login = "login"
		case isAdmin = "admin"
		case userID = "id"
	}
	
	// The "sub" (subject) claim identifies the principal that is the
	// subject of the JWT.
	var subject: SubjectClaim
	
	// The "exp" (expiration time) claim identifies the expiration time on
	// or after which the JWT MUST NOT be accepted for processing.
	var expirationAt: ExpirationClaim
	var issuedAt: IssuedAtClaim
	var name: String
	var userID: UUID
	var login: String
	var isAdmin: Bool
	
	func verify(using algorithm: some JWTAlgorithm) async throws {
		
		try self.expirationAt.verifyNotExpired()
	}
}
