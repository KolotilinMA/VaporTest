//
//  LoginDTO.swift
//
//
//  Created by Михаил on 17.07.2024.
//

import Vapor

struct LoginDTO: Content {
	var login: String
	var password: String
}
