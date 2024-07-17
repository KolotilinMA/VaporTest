//
//  UsersController.swift
//
//
//  Created by Михаил on 15.07.2024.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
	
	func boot(routes: RoutesBuilder) throws {
		
		let usersGroup = routes.grouped("v1/users")
		usersGroup.post(use: createHandler)
		usersGroup.get(use: getAllHandler)
		
		usersGroup.group(":id") { user in
			user.get(use: getHandler)
			user.delete(use: deleteHandler)
		}
		
		usersGroup.post("login", use: loginHandler)
	}

	@Sendable
	func createHandler(_ req: Request) async throws -> ServerResponse<User.PublicToken> {
		
		guard let user = try? req.content.decode(User.self) else {
			throw Abort(.custom(code: 499, reasonPhrase: "Не получилось декодировать контент в модель юзера"))
		}
		user.password = try Bcrypt.hash(user.password)
		try await user.save(on: req.db)
		let tokenPayload = try TokenHelpers.createPayload(from: user)
		let token = try await req.jwt.sign(tokenPayload, kid: "a")
		return ServerResponse(success: true, data: user.convertToPublicToken(token: token))
	}

	@Sendable
	func getAllHandler(_ req: Request) async throws -> ServerResponse<[User.Public]> {
		let query = User.query(on: req.db)
		let all = try await query.all().map { $0.convertToPublic() }
		return ServerResponse(success: true, data: all)
	}
	
	@Sendable
	func getHandler(_ req: Request) async throws -> ServerResponse<User.Public> {
		let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
		
		guard let _ = try await User.find(payload.userID, on: req.db) else {
			throw Abort(.unauthorized)
		}
		
		guard let id = req.parameters.get("id", as: UUID.self) else {
			throw Abort(.badRequest)
		}
		
		guard let user = try await User.find(id, on: req.db) else {
			throw Abort(.notFound)
		}
		return ServerResponse(success: true, data: user.convertToPublic())
	}
	
	@Sendable
	func deleteHandler(_ req: Request) async throws -> HTTPStatus {
		guard let id = req.parameters.get("id", as: UUID.self) else {
			throw Abort(.badRequest)
		}
		guard let user = try await Product.find(id, on: req.db) else {
			throw Abort(.notFound)
		}
		try await user.delete(on: req.db)
		return .ok
	}
	
	@Sendable
	func loginHandler(_ req: Request) async throws -> ServerResponse<User.PublicToken> {
		
		guard let login = try? req.content.decode(LoginDTO.self) else {
			throw Abort(.custom(code: 499, reasonPhrase: "Не верный формат Логин/Пароль"))
		}
		
		guard let existingUser = try await User.query(on: req.db).filter(\.$login == login.login).first() else {
			throw Abort(.notFound)
		}
		
		guard try Bcrypt.verify(login.password, created: existingUser.password) else {
			throw Abort(.unauthorized)
		}
		let tokenPayload = try TokenHelpers.createPayload(from: existingUser)
		let token = try await req.jwt.sign(tokenPayload, kid: "a")
		
		return ServerResponse(success: true, data: existingUser.convertToPublicToken(token: token))
	}
}
