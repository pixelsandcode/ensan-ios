//
//  ApiRouter.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 3/1/18.
//  Copyright © 2018 Ashkan Hesaraki. All rights reserved.
//

import Foundation
import Alamofire

enum BackendError: Error {
	case network(error: Error) // Capture any underlying Error from the URLSession API
	case dataSerialization(error: Error)
	case jsonSerialization(error: Error)
	case xmlSerialization(error: Error)
	case objectSerialization(reason: String)
}

public protocol ResponseCollectionSerializable {
	static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

public protocol ResponseObjectSerializable {
	init?(response: HTTPURLResponse, representation: Any)
}

extension DataRequest {
	@discardableResult
	public func responseObject<T: ResponseObjectSerializable>(
		_ queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<T>) -> Void)
		-> Self {
			let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
				guard error == nil else { return .failure(BackendError.network(error: error!)) }
				
				let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
				let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
				
				guard case let .success(jsonObject) = result else {
					return .failure(BackendError.jsonSerialization(error: result.error!))
				}
				
				guard let response = response, let responseObject = T(response: response, representation: jsonObject) else {
					return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
				}
				
				return .success(responseObject)
			}
			
			return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
	
	@discardableResult
	func responseCollection<T: ResponseCollectionSerializable>(
		_ queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
		let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
			guard error == nil else { return .failure(BackendError.network(error: error!)) }
			
			let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = jsonSerializer.serializeResponse(request, response, data, nil)
			
			guard case let .success(jsonObject) = result else {
				return .failure(BackendError.jsonSerialization(error: result.error!))
			}
			
			guard let response = response else {
				let reason = "Response collection could not be serialized due to nil response."
				return .failure(BackendError.objectSerialization(reason: reason))
			}
			
			return .success(T.collection(from: response, withRepresentation: jsonObject))
		}
		
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}

extension DataRequest {
	
	/// The logging level. `.simple` prints only a brief request/response description; `.verbose` prints the request/response body as well.
	public enum LogLevel {
		/// Prints the request and response at their respective `.simple` levels.
		case simple
		/// Prints the request and response at their respective `.verbose` levels.
		case verbose
	}
	
	/// Log the request and response at the specified `level`.
	public func log(_ level: LogLevel = .simple) -> Self {
		switch level {
		case .simple:
			return logRequest(.simple).logResponse(.simple)
		case .verbose:
			return logRequest(.verbose).logResponse(.verbose)
		}
	}
	
}

// MARK: - Request logging
extension DataRequest {
	
	/// The request logging level. `.simple` prints only the HTTP method and path; `.verbose` prints the request body as well.
	public enum RequestLogLevel {
		/// Print the request's HTTP method and path.
		case simple
		/// Print the request's HTTP method, path, and body.
		case verbose
	}
	
	/// Log the request at the specified `level`.
	public func logRequest(_ level: RequestLogLevel = .simple) -> Self {
		guard let method = request?.httpMethod, let path = request?.url?.absoluteString else {
			return self
		}
		
		if case .verbose = level, let data = request?.httpBody, let body = String(data: data, encoding: .utf8) {
			print("\(method) \(path): \"\(body)\"")
		} else {
			print("\(method) \(path)")
		}
		
		return self
	}
	
}

// MARK: - Response logging
extension DataRequest {
	
	/// The response logging level. `.simple` prints only the HTTP status code and path; `.verbose` prints the response body as well.
	public enum ResponseLogLevel {
		/// Print the response's HTTP status code and path, or error if one is returned.
		case simple
		/// Print the response's HTTP status code, path, and body, or error if one is returned.
		case verbose
	}
	
	/// Log the response at the specified `level`.
	public func logResponse(_ level: ResponseLogLevel = .simple) -> Self {
		return response { response in
			guard let code = response.response?.statusCode, let path = response.request?.url?.absoluteString else {
				return
			}
			
			if case .verbose = level, let data = response.data, let body = String(data: data, encoding: .utf8) {
				print("\(code) \(path): \"\(body)\"")
			} else {
				print("\(code) \(path)")
			}
		}
	}
	
}

struct ApiRouter {
	enum Router: URLRequestConvertible {
		case login()
		case signup(name: String, mobile: String)
		case addGuardian(name: String, mobile: String)
		case getGuardians()
		case registerDevice()
		case verifyPin(pin: String)
		case generatePin()
		case deleteGuardian(id: String)
		
		var method: Alamofire.HTTPMethod {
			switch self {
			case .login:
				return .post
			case .signup:
				return .post
			case .addGuardian:
				return .post
			case .getGuardians:
				return .get
			case .registerDevice:
				return .post
			case .verifyPin:
				return .post
			case .generatePin:
				return .post
			case .deleteGuardian:
				return .delete
			}
		}
		
		func asURLRequest() throws -> URLRequest {
			let result: (path: String, parameters: [String: AnyObject]?) = {
				switch self {
				case .login():
					let params = ["auth": UserInfo.getUserAuth(), "mobile": UserInfo.getMobile()]
					return ("/user/login", params as [String : AnyObject])
				case .signup(let name, let mobile):
					let params = ["name": name, "mobile": mobile]
					return ("user/signup", params as [String : AnyObject])
				case .addGuardian(let name, let mobile):
					let params = ["name": name, "mobile": mobile]
					return ("user/guardians", params as [String : AnyObject])
				case .getGuardians():
					return ("user/guardians", nil)
				case .registerDevice():
					let params = ["token": UserInfo.getNotificationId()]
					return ("user/devices", params as [String : AnyObject])
				case .verifyPin(let pin):
					let params = ["pin": pin, "mobile": UserInfo.getMobile()]
					return ("user/verify", params as [String : AnyObject])
				case .generatePin():
					let params = ["mobile": UserInfo.getMobile()]
					return ("/user/login", params as [String : AnyObject])
				case .deleteGuardian(let id):
					return ("/user/guardians/\(id)", nil)
				}
			}()
			
			let url = URL(string: "http://api.ensanapp.ir/v1")!
			//let url = URL(string: Constants.ApiConstants.baseURLString)!
			var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
			urlRequest.httpMethod = method.rawValue
			
			if let token = UserInfo.getToken() {
				urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
			}
			
			let encoding = try Alamofire.URLEncoding.default.encode(urlRequest, with: result.parameters)
			return encoding
		}
	}
}
