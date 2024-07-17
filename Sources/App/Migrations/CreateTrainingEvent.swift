//
//  File.swift
//
//
//  Created by Михаил on 17.07.2024.
//

import Fluent

struct CreateTrainingEvent: Migration {
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		return database.schema("training_events")
			.id()
			.field("name", .string, .required)
			.field("type", .string, .required)
			.field("region", .string, .required)
			.field("headline", .string, .required)
			.field("category", .string, .required)
			.field("descriptionTitle", .string, .required)
			.field("description", .string, .required)
			.field("sessionTitle", .string, .required)
			.field("skillTitle", .string, .required)
			.field("created_at", .datetime)
			.field("durations", .json, .required)
			.field("skills", .json, .required)
			.create()
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		return database.schema("training_events").delete()
	}
}
