import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import JWTKit
import SwiftTelegramSdk

// configures your application
public func configure(_ app: Application) async throws {
	// uncomment to serve files from /Public folder
	// app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	// override the global encoder used for the `.json` media type
	ContentConfiguration.global.use(encoder: JSONEncoder.serverEncoder, for: .json)
	ContentConfiguration.global.use(decoder: JSONDecoder.serverDecoder, for: .json)
	app.middleware.use(ErrorMiddleware())
	app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
	
	app.http.server.configuration.hostname = "0.0.0.0"
	app.http.server.configuration.port = 80
	
	await app.jwt.keys.add(hmac: JWTConfig.signerKey, digestAlgorithm: JWTConfig.algorithm)
	
	try await addMigration(app)
	
	// register routes
	try routes(app)
}

private func addMigration(_ app: Application) async throws {
	app.migrations.add(CreateProduct())
	app.migrations.add(CreateTrainingEvent())
	app.migrations.add(CreateUser())
	app.migrations.add(CreateLoginAttempts())
	try await app.autoMigrate()
}

func configure(_ app: Application, appContext: TelegramApplicationContext) async throws {
	let tgApi: String = "6730904969:AAHQ226O7QjwGq83MMMQO7n2kjuPZkpfRSQ"
	
	/// SET WEBHOOK CONNECTION
	// let bot: TGBot = try await .init(connectionType: .webhook(webHookURL: URL(string: "https://your_domain/telegramWebHook")!),
	//                                  dispatcher: nil,
	//                                  tgClient: URLSessionTGClient(),
	//                                  tgURI: TGBot.standardTGURL,
	//                                  botId: tgApi,
	//                                  log: appContext.logger)
	
	/// SET LONGPOLLING CONNECTION
	let bot: TGBot = try await .init(connectionType: .longpolling(limit: nil,
									 timeout: nil, allowedUpdates: nil),
									 dispatcher: nil, tgClient: AsyncHttpTGClient(),
									 tgURI: TGBot.standardTGURL, botId: tgApi, log: appContext.logger)
	
	// set level of debug if you needed
	// bot.log.logLevel = .error
	
	await appContext.botActor.setBot(bot)
	await DefaultBotHandlers.addHandlers(app, bot: appContext.botActor.bot)
	try await appContext.botActor.bot.start()
}

struct TelegramApplicationContext {
	let logger: Logger
	let botActor: TGBotActor
}
