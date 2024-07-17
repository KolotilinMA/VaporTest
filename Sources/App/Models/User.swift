//
//  User.swift
//
//
//  Created by Михаил on 15.07.2024.
//

import Vapor
import Fluent

final class User {
	static let schema = "users"

	@ID
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Field(key: "login")
	var login: String
	
	@Field(key: "password")
	var password: String
	
	@Field(key: "role")
	var role: Role
	
	@Field(key: "profilePic")
	var profilePic: String?

	init() {}

	init(id: UUID? = nil, name: String, login: String, password: String, role: Role, profilePic: String? = nil) {
		self.id = id
		self.name = name
		self.login = login
		self.password = password
		self.role = role
		self.profilePic = profilePic
	}
	
	final class Public: Content {
		var id: UUID?
		var name: String
		var login: String
		var role: Role
		var profilePic: String?
		
		init(id: UUID? = nil, name: String, login: String, role: Role, profilePic: String?) {
			self.id = id
			self.name = name
			self.login = login
			self.role = role
			self.profilePic = profilePic
		}
	}
	
	final class PublicToken: Content {
		var id: UUID?
		var name: String
		var login: String
		var role: Role
		var token: String
		var profilePic: String?
		
		init(id: UUID? = nil, name: String, login: String, role: Role, token: String, profilePic: String?) {
			self.id = id
			self.name = name
			self.login = login
			self.role = role
			self.token = token
			self.profilePic = profilePic
		}
	}
}

extension User {
	func convertToPublic() -> User.Public {
		return User.Public(id: id, name: name, login: login, role: role, profilePic: profilePic)
	}
	
	func convertToPublicToken(token: String) -> User.PublicToken {
		return User.PublicToken(id: id, name: name, login: login, role: role, token: token, profilePic: profilePic)
	}
}

extension User: ModelAuthenticatable {
	static let usernameKey = \User.$login
	static let passwordHashKey = \User.$password

	func verify(password: String) throws -> Bool {
		try Bcrypt.verify(password, created: self.password)
	}
}

extension User: Content { }

extension User: Model { }

extension User: @unchecked Sendable { }

enum Role: String, Content {
	case officiant = "Официант"
	case manager = "Манаджер"
}
