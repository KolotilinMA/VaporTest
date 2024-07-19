//
//  DefaultBotHandlers.swift
//
//
//  Created by Михаил on 19.07.2024.
//

import Fluent
import Vapor
import SwiftTelegramSdk

final class DefaultBotHandlers {

	static func addHandlers(_ app: Application, bot: TGBot) async {
		await defaultBaseHandler(bot: bot)
		await messageHandler(app, bot: bot)
		await commandPingHandler(bot: bot)
		await commandShowButtonsHandler(bot: bot)
		await buttonsActionHandler(bot: bot)
	}
	
	private static func defaultBaseHandler(bot: TGBot) async {
		await bot.dispatcher.add(TGBaseHandler({ update in
			guard let message = update.message else { return }
			let params: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: "TGBaseHandler")
			try await bot.sendMessage(params: params)
		}))
	}

	private static func messageHandler(_ app: Application, bot: TGBot) async {
		await bot.dispatcher.add(TGMessageHandler(filters: (.all && !.command.names(["/ping", "/show_buttons"]))) { update in
			guard let message = update.message else { return }
			let chatId = message.chat.id
			let text = message.text ?? ""

			// Проверяем, что текст сообщения состоит из восьми цифр
			if let userCode = Int(text), text.count == 8 {
				do {
					// Ищем пользователя по коду
					if let user = try await findUserByCode(app, code: userCode) {
						// Обновляем пользователя, добавляя telegramID
						try await addTelegramID(app, user: user, telegramID: Int(chatId))

						// Отправляем сообщение о завершении регистрации
						let params: TGSendMessageParams = .init(chatId: .chat(chatId), text: "\(user.name) вы прошли регистрацию")
						try await bot.sendMessage(params: params)
					} else {
						let params: TGSendMessageParams = .init(chatId: .chat(chatId), text: "Пользователь не найден")
						try await bot.sendMessage(params: params)
					}
				} catch {
					// Обрабатываем ошибки, если они возникнут
					let params: TGSendMessageParams = .init(chatId: .chat(chatId), text: "Произошла ошибка")
					try await bot.sendMessage(params: params)
				}
			} else {
				// Если сообщение не является восьмизначным числом, отправляем другое сообщение
				let params: TGSendMessageParams = .init(chatId: .chat(chatId), text: "Введите восьмизначный код")
				try await bot.sendMessage(params: params)
			}
		})
	}

	private static func commandPingHandler(bot: TGBot) async {
		await bot.dispatcher.add(TGCommandHandler(commands: ["/ping"]) { update in
			try await update.message?.reply(text: "pong", bot: bot)
		})
	}

	private static func commandShowButtonsHandler(bot: TGBot) async {
		await bot.dispatcher.add(TGCommandHandler(commands: ["/show_buttons"]) { update in
			guard let userId = update.message?.from?.id else { fatalError("user id not found") }
			let buttons: [[TGInlineKeyboardButton]] = [
				[
					.init(
						text: "Button 1",
						callbackData: "press 1"
					),
					.init(
						text: "Button 2",
						callbackData: "press 2"
					)
				]
			]
			let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
			let params: TGSendMessageParams = .init(
				chatId: .chat(userId),
				text: "Keyboard active",
				replyMarkup: .inlineKeyboardMarkup(keyboard)
			)
			try await bot.sendMessage(params: params)
		})
	}

	private static func buttonsActionHandler(bot: TGBot) async {
		await bot.dispatcher.add(TGCallbackQueryHandler(pattern: "press 1") { update in
			bot.log.info("press 1")
			guard let userId = update.callbackQuery?.from.id else { fatalError("user id not found") }
			let params: TGAnswerCallbackQueryParams = .init(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: update.callbackQuery?.data  ?? "data not exist",
				showAlert: nil,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)
			try await bot.sendMessage(params: .init(chatId: .chat(userId), text: "press 1"))
		})
		
		await bot.dispatcher.add(TGCallbackQueryHandler(pattern: "press 2") { update in
			bot.log.info("press 2")
			guard let userId = update.callbackQuery?.from.id else { fatalError("user id not found") }
			let params: TGAnswerCallbackQueryParams = .init(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: update.callbackQuery?.data  ?? "data not exist",
				showAlert: nil,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)
			try await bot.sendMessage(params: .init(chatId: .chat(userId), text: "press 2"))
		})
	}
}

// Пример функций для поиска пользователя и обновления telegramID
private func findUserByCode(_ app: Application, code: Int) async throws -> User? {
	
	guard let existingUser = try await User.query(on: app.db).filter(\.$registrationCode == code).first() else {
		return nil
	}
	return existingUser
}

private func addTelegramID(_ app: Application, user: User, telegramID: Int) async throws {
	
	user.telegramID = telegramID
	user.finishedRegistration = true
	user.registrationCode = nil
	try await user.update(on: app.db)
}

