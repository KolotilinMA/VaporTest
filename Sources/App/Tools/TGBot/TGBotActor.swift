//
//  TGBotActor.swift
//
//
//  Created by Михаил on 19.07.2024.
//

import Foundation
import SwiftTelegramSdk

actor TGBotActor {
	// Используем статическое свойство shared для хранения единственного экземпляра актора
	static let shared = TGBotActor()
	
	private var _bot: TGBot!
	
	// Приватный инициализатор, чтобы предотвращать создание других экземпляров
	private init() {}
	
	var bot: TGBot {
		return self._bot
	}
	
	func setBot(_ bot: TGBot) {
		self._bot = bot
	}
}
