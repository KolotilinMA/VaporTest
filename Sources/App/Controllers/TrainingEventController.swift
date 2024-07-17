//
//  TrainingEventController.swift
//
//
//  Created by Михаил on 17.07.2024.
//

import Fluent
import Vapor

struct TrainingEventController: RouteCollection {
	
	func boot(routes: RoutesBuilder) throws {
		
		let productsGroup = routes.grouped("training-events")
		productsGroup.post(use: createHandler)
		productsGroup.get(use: getAllHandler)
		
//		productsGroup.get(":productID", use: getHandler)
//		productsGroup.delete(":productID", use: deleteHandler)
//		productsGroup.put(":productID", use: updateHandler)
	}

	@Sendable
	func createHandler(_ req: Request) async throws -> TrainingEvent.Public {
		
		guard let productReq = try? req.content.decode(TrainingEvent.Request.self) else {
			throw Abort(.custom(code: 499, reasonPhrase: "Не получилось декодировать контент в модель продукта"))
		}
		let product = productReq.convertToTrainingEvent()
		try await product.save(on: req.db)
		let publicProduct = try product.convertToPublic()
		return publicProduct
	}

	@Sendable
	func getAllHandler(_ req: Request) async throws -> [TrainingEvent.Public] {
		let all = try await TrainingEvent.query(on: req.db).all()
		let publicEvents = try all.map { try $0.convertToPublic() }
		return publicEvents
	}
	
	
	
//	@Sendable
//	func getHandler(_ req: Request) async throws -> Product {
//		guard let id = req.parameters.get("productID", as: UUID.self) else {
//			throw Abort(.badRequest)
//		}
//		guard let product = try await Product.find(id, on: req.db) else {
//			throw Abort(.notFound)
//		}
//		return product
//	}
//
//	@Sendable
//	func updateHandler(_ req: Request) async throws -> Product {
//		guard let id = req.parameters.get("productID", as: UUID.self) else {
//			throw Abort(.badRequest)
//		}
//		guard let product = try? req.content.decode(Product.self) else {
//			throw Abort(.badRequest)
//		}
//
//		product.id = id
//		try await product.update(on: req.db)
//		return product
//	}
//
//	@Sendable
//	func deleteHandler(_ req: Request) async throws -> HTTPStatus {
//		guard let id = req.parameters.get("productID", as: UUID.self) else {
//			throw Abort(.badRequest)
//		}
//		guard let product = try await Product.find(id, on: req.db) else {
//			throw Abort(.notFound)
//		}
//		try await product.delete(on: req.db)
//		return .ok
//	}
//
//	enum SortableField: String {
//		case category, price
//	}
	
}
