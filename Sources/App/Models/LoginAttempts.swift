//
//  LoginAttempts.swift
//
//
//  Created by Михаил on 20.07.2024.
//

import Fluent
import Vapor

final class LoginAttempts: Model, Content, @unchecked Sendable {
	static let schema = "login_attempts"

	@ID(key: .id)
	var id: UUID?

	@Parent(key: "user_id")
	var user: User

	@Field(key: "login_code")
	var loginCode: String

	@Field(key: "created_at")
	var createdAt: Date

	@Field(key: "attempt_number")
	var attemptNumber: Int

	@Field(key: "expires_at")
	var expiresAt: Date

	init() { }

	init(id: UUID? = nil,
		 userID: UUID,
		 loginCode: String,
		 createdAt: Date = Date(),
		 attemptNumber: Int = 1,
		 expiresAt: Date = Date().addingTimeInterval(60 * 15)
	) {
		self.id = id
		self.$user.id = userID
		self.loginCode = loginCode
		self.createdAt = createdAt
		self.attemptNumber = attemptNumber
		self.expiresAt = expiresAt
	}
	
	final class Credentials: Content {
		
		var login: String
		var password: String
		var code: String
		
		init(login: String, password: String, code: String) {
			self.login = login
			self.password = password
			self.code = code
		}
	}
}
