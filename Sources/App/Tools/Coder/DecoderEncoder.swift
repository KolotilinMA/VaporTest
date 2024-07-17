//
//  File.swift
//  
//
//  Created by Михаил on 17.07.2024.
//

import Foundation

extension JSONDecoder {
	
	public static let serverDecoder: JSONDecoder = {
	   
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		return decoder
	}()
}

extension JSONEncoder {
	
	public static let serverEncoder: JSONEncoder = {
	   
		let decoder = JSONEncoder()
		decoder.dateEncodingStrategy = .iso8601
		
		return decoder
	}()
}
