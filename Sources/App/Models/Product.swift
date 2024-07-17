//
//  File.swift
//
//
//  Created by Михаил on 15.07.2024.
//

import Vapor
import Fluent

final class Product: Model, Content, @unchecked Sendable {
	static let schema = "products"

	@ID
	var id: UUID?

	@Field(key: "title")
	var title: String

	@Field(key: "description")
	var description: String

	@Field(key: "price")
	var price: Int

	@Field(key: "category")
	var category: String

	@Field(key: "image")
	var image: String?

	init() {}

	init(id: UUID? = nil, title: String, description: String, price: Int, category: String, image: String? = nil) {
		self.id = id
		self.title = title
		self.description = description
		self.price = price
		self.category = category
		self.image = image
	}
}
