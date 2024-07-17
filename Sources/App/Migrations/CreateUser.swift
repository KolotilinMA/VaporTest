//
//  CreateUser.swift
//
//
//  Created by Михаил on 15.07.2024.
//

import Fluent
import Vapor

struct CreateUser: AsyncMigration {
	
	func prepare(on database: Database) async throws {
		try await database.schema("users")
			.id()
			.field("name", .string, .required)
			.field("login", .string, .required)
			.field("password", .string, .required)
			.field("role", .string, .required)
			.field("profilePic", .string)
			.unique(on: "login")
			.create()
	}
	
	func revert(on database: Database) async throws {
		try await database.schema("users").delete()
	}
}
