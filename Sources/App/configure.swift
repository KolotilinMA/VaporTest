import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import JWTKit

// configures your application
public func configure(_ app: Application) async throws {
	// uncomment to serve files from /Public folder
	// app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	// override the global encoder used for the `.json` media type
	ContentConfiguration.global.use(encoder: JSONEncoder.serverEncoder, for: .json)
	ContentConfiguration.global.use(decoder: JSONDecoder.serverDecoder, for: .json)
	app.middleware.use(ErrorMiddleware())
	app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
	app.migrations.add(CreateProduct())
	app.migrations.add(CreateUser())
	app.migrations.add(CreateTrainingEvent())
	
	await app.jwt.keys.add(hmac: JWTConfig.signerKey, digestAlgorithm: .sha256)
	
	try await app.autoMigrate()
	// register routes
	try routes(app)
}
