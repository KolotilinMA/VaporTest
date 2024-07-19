//
//  CreateLoginAttempts.swift
//
//
//  Created by Михаил on 20.07.2024.
//

import Fluent
import Vapor

struct CreateLoginAttempts: AsyncMigration {

	func prepare(on database: Database) async throws {
		try await database.schema("login_attempts")
			.id()
			.field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
			.field("login_code", .string, .required)
			.field("created_at", .datetime, .required)
			.field("attempt_number", .int, .required)
			.field("expires_at", .datetime, .required)
			.create()
	}

	func revert(on database: Database) async throws {
		try await database.schema("login_attempts").delete()
	}
}
