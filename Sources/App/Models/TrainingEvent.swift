//
//  File.swift
//
//
//  Created by Михаил on 17.07.2024.
//

import Vapor
import Fluent

final class TrainingEvent: Model, Content, @unchecked Sendable{
	static let schema = "training_events"
	
	@ID(key: .id)
	var id: UUID?
	
	@Field(key: "name")
	var name: String
	
	@Field(key: "type")
	var type: String
	
	@Field(key: "region")
	var region: String
	
	@Field(key: "headline")
	var headline: String
	
	@Field(key: "category")
	var category: String
	
	@Field(key: "descriptionTitle")
	var descriptionTitle: String
	
	@Field(key: "description")
	var description: String
	
	@Field(key: "sessionTitle")
	var sessionTitle: String
	
	@Field(key: "skillTitle")
	var skillTitle: String
	
	@Field(key: "created_at")
	var createdAt: Date
	
	// For durations and skills, we will use JSON fields
	@Field(key: "durations")
	var durations: [Duration]
	
	@Field(key: "skills")
	var skills: [Skill]
	
	init() { }
	
	internal init(
		id: UUID? = nil,
		name: String,
		type: String,
		region: String,
		headline: String,
		category: String,
		descriptionTitle: String,
		description: String,
		sessionTitle: String,
		skillTitle: String,
		createdAt: Date = Date(),
		durations: [TrainingEvent.Duration],
		skills: [TrainingEvent.Skill]
	) {
		self.id = id
		self.name = name
		self.type = type
		self.region = region
		self.headline = headline
		self.category = category
		self.descriptionTitle = descriptionTitle
		self.description = description
		self.sessionTitle = sessionTitle
		self.skillTitle = skillTitle
		self.createdAt = createdAt
		self.durations = durations
		self.skills = skills
	}
	
	struct Duration: Content {
		var name: String
		var minutes: Int
	}
	
	struct Skill: Content {
		var name: String
	}
	
	struct Public: Content {
		var id: UUID
		var name: String
		var type: String
		var region: String
		var headline: String
		var category: String
		var descriptionTitle: String
		var description: String
		var sessionTitle: String
		var skillTitle: String
		var createdAt: Date
		var durations: [Duration]
		var skills: [Skill]
	}
	
	struct Request: Content {
		var name: String
		var type: String
		var region: String
		var headline: String
		var category: String
		var descriptionTitle: String
		var description: String
		var sessionTitle: String
		var skillTitle: String
		var durations: [Duration]
		var skills: [Skill]
	}
}

extension TrainingEvent {
	func convertToPublic() throws -> TrainingEvent.Public {
		let id = try self.requireID()
		return TrainingEvent.Public(
			id: id,
			name: self.name,
			type: self.type,
			region: self.region,
			headline: self.headline,
			category: self.category,
			descriptionTitle: self.descriptionTitle,
			description: self.description,
			sessionTitle: self.sessionTitle,
			skillTitle: self.skillTitle,
			createdAt: self.createdAt,
			durations: self.durations,
			skills: self.skills
		)
	}
	
}

extension TrainingEvent.Request {
	func convertToTrainingEvent() -> TrainingEvent {
		return TrainingEvent(
			name: self.name,
			type: self.type,
			region: self.region,
			headline: self.headline,
			category: self.category,
			descriptionTitle: self.descriptionTitle,
			description: self.description,
			sessionTitle: self.sessionTitle,
			skillTitle: self.skillTitle,
			durations: self.durations,
			skills: self.skills
		)
	}
}

//extension TrainingEvent.Public {
//	
//	private enum CodingKeys: CodingKey {
//		case id, name, type, region, headline, category, descriptionTitle, description, sessionTitle, skillTitle, createdAt, durations, skills
//	}
//	
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(id, forKey: .id)
//		try container.encode(name, forKey: .name)
//		try container.encode(type, forKey: .type)
//		try container.encode(region, forKey: .region)
//		try container.encode(headline, forKey: .headline)
//		try container.encode(category, forKey: .category)
//		try container.encode(descriptionTitle, forKey: .descriptionTitle)
//		try container.encode(description, forKey: .description)
//		try container.encode(sessionTitle, forKey: .sessionTitle)
//		try container.encode(skillTitle, forKey: .skillTitle)
//		try container.encode(createdAt, forKey: .createdAt)
//		try container.encode(durations, forKey: .durations)
//		try container.encode(skills, forKey: .skills)
//	}
//}
