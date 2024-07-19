//
//  File.swift
//  
//
//  Created by Михаил on 19.07.2024.
//

import Foundation
import Vapor
import SwiftTelegramSdk

final class TelegramController: RouteCollection {
	
	func boot(routes: Vapor.RoutesBuilder) throws {
		routes.post("telegramWebHook", use: telegramWebHook)
	}
}

extension TelegramController {
	
	@Sendable
	func telegramWebHook(_ req: Request) async throws -> Bool {
		let update: TGUpdate = try req.content.decode(TGUpdate.self)
		Task { await TGBotActor.shared.bot.dispatcher.process([update]) }
		return true
	}
}
