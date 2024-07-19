//
//  UsersController.swift
//
//
//  Created by Михаил on 15.07.2024.
//

import Fluent
import Vapor
import SwiftTelegramSdk

struct UsersController: RouteCollection {
	
	func boot(routes: RoutesBuilder) throws {
		
		let usersGroup = routes.grouped("users")
		usersGroup.post(use: createHandler)
		usersGroup.get(use: getAllHandler)
		
		usersGroup.group(":id") { user in
			user.get(use: getHandler)
			user.delete(use: deleteHandler)
		}
		
		usersGroup.post("login", use: loginHandler)
		usersGroup.post("check", use: checkHandler)
		
	}

	@Sendable
	func createHandler(_ req: Request) async throws -> ServerResponse<User.PublicRegistration> {
		let user = try req.content.decode(User.RequestDTO.self).convertToModel()
//		guard let user = try? req.content.decode(User.self) else {
//			throw Abort(.custom(code: 499, reasonPhrase: "Не получилось декодировать контент в модель юзера"))
//		}
		user.registrationCode = Int.random(in: 10000000...99999999)
		user.password = try Bcrypt.hash(user.password)
		try await user.save(on: req.db)
		
//		let tokenPayload = try TokenHelpers.createPayload(from: user)
//		let token = try await req.jwt.sign(tokenPayload, kid: "a")
		
		return ServerResponse(success: true, data: user.convertToPublicRegistration())
	}
	
	@Sendable
	func checkHandler(_ req: Request) async throws -> ServerResponse<User.PublicToken> {
		
		let credentials = try req.content.decode(LoginAttempts.Credentials.self)
		
		guard let existingUser = try await User.query(on: req.db).filter(\.$login == credentials.login).first() else {
			throw Abort(.notFound)
		}
		
		guard try Bcrypt.verify(credentials.password, created: existingUser.password) else {
			throw Abort(.unauthorized)
		}
		
		guard let loginAttempts = try await LoginAttempts.query(on: req.db).filter(\.$user.$id == existingUser.requireID()).first() else {
			throw Abort(.custom(code: 499, reasonPhrase: "Отправьте код повторно"))
		}
		if loginAttempts.attemptNumber >= 3 {
			try await loginAttempts.delete(on: req.db)
			throw Abort(.custom(code: 499, reasonPhrase: "Превышено количество попыток"))
		}
		guard loginAttempts.loginCode == credentials.code else {
			loginAttempts.attemptNumber += 1
			try await loginAttempts.save(on: req.db)
			throw Abort(.custom(code: 499, reasonPhrase: "Не верный код"))
		}
		try await loginAttempts.delete(on: req.db)
		let tokenPayload = try TokenHelpers.createPayload(from: existingUser)
		let token = try await req.jwt.sign(tokenPayload, kid: "a")
		
		return ServerResponse(success: true, data: existingUser.convertToPublicToken(token: token))
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
	func loginHandler(_ req: Request) async throws -> HTTPStatus{
		
		guard let login = try? req.content.decode(LoginDTO.self) else {
			throw Abort(.custom(code: 499, reasonPhrase: "Не верный формат Логин/Пароль"))
		}
		
		guard let existingUser = try await User.query(on: req.db).filter(\.$login == login.login).first() else {
			throw Abort(.notFound)
		}
		
		guard try Bcrypt.verify(login.password, created: existingUser.password) else {
			throw Abort(.unauthorized)
		}
		
		let code = Int.random(1000...9999)
		guard let chatId = existingUser.telegramID, existingUser.finishedRegistration == true else {
			throw Abort(.custom(code: 499, reasonPhrase: "Вы не прошли регистрацию"))
		}
		let params = TGSendMessageParams(chatId: .chat(Int64(chatId)), text: "Одноразовый код для входа: \(code)")
		let userID = try existingUser.requireID()
		let loginAttempts = LoginAttempts(userID: userID, loginCode: String(code))
		try await loginAttempts.save(on: req.db)
		try await TGBotActor.shared.bot.sendMessage(params: params)
		
		return .ok
		
//		let tokenPayload = try TokenHelpers.createPayload(from: existingUser)
//		let token = try await req.jwt.sign(tokenPayload, kid: "a")
//
//		return ServerResponse(success: true, data: existingUser.convertToPublicToken(token: token))
	}
}
