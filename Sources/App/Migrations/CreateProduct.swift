//
//  File.swift
//
//
//  Created by Михаил on 15.07.2024.
//

import Fluent
import Vapor

struct CreateProduct: AsyncMigration {
	
	func prepare(on database: Database) async throws {
		try await database.schema("products")
			.id()
			.field("title", .string, .required)
			.field("description", .string, .required)
			.field("price", .int, .required)
			.field("category", .string, .required)
			.field("image", .string)
			.create()
	}
	
	func revert(on database: Database) async throws {
		try await database.schema("products").delete()
	}
}

