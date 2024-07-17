//
//  ErrorMiddleware.swift
//
//
//  Created by Михаил on 17.07.2024.
//

import Vapor

final class ErrorMiddleware: Middleware {
	func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
		return next.respond(to: request).flatMapError { error in
			self.handleError(request: request, error: error)
		}
	}

	private func handleError(request: Request, error: Error) -> EventLoopFuture<Response> {
		let status: HTTPResponseStatus
		let reason: String

		if let abortError = error as? AbortError {
			status = abortError.status
			reason = abortError.reason
		} else {
			status = .internalServerError
			reason = "An unknown error occurred."
		}

		let errorResponse = ServerResponseError(error: reason, success: false)
		var body: ByteBuffer
		do {
			body = try ByteBuffer(data: JSONEncoder().encode(errorResponse))
		} catch {
			let fallbackBody = try? JSONEncoder().encode(ServerResponseError(error: "Fatal error encoding error response.", success: false))
			body = ByteBuffer(data: fallbackBody ?? Data())
		}
		
		let response = Response(status: status, body: .init(buffer: body))
		response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
		return request.eventLoop.makeSucceededFuture(response)
	}
}
