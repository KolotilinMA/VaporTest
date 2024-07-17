//
//  ServerResponseError.swift
//
//
//  Created by Михаил on 17.07.2024.
//

import Vapor

struct ServerResponseError: Content {
	let error: String
	let success: Bool
}

struct ServerResponse<T: Content>: Content {
	let success: Bool
	let data: T
}
