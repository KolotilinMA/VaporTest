import Fluent
import Vapor

func routes(_ app: Application) throws {
	// Fetch and verify JWT from incoming request.
	app.get("me") { req async throws -> HTTPStatus in
		let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
		print(payload)
		return .ok
	}
	
//	app.post("login") { req async throws -> [String: String] in
//		// Create a new instance of our JWTPayload
//		let payload = AccessTokenPayload(
//			subject: "vapor",
//			expiration: .init(value: .distantFuture),
//			name: "Name Ivan",
//			login: "login",
//			isAdmin: true
//		)
//		// Return the signed JWT
//		return try await [
//			"token": req.jwt.sign(payload, kid: "a"),
//		]
//	}
	
	try app.register(collection: ProductsController())
	try app.register(collection: UsersController())
	try app.register(collection: TrainingEventController())
	app.routes.defaultMaxBodySize = "10Mb"
	
}
