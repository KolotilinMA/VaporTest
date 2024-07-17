import Fluent
import Vapor

struct ProductsController: RouteCollection {
	
	func boot(routes: RoutesBuilder) throws {
		
		let productsGroup = routes.grouped("products")
		productsGroup.get(use: getAllHandler)
		productsGroup.get(":productID", use: getHandler)
		
		let basicMW = User.authenticator()
		let guardMW = User.guardMiddleware()
		let protected = productsGroup.grouped(basicMW, guardMW)
		protected.post(use: createHandler)
		protected.delete(":productID", use: deleteHandler)
		protected.put(":productID", use: updateHandler)
	}

	@Sendable
	func createHandler(_ req: Request) async throws -> Product {
		
		guard let productDTO = try? req.content.decode(ProductDTO.self) else {
			throw Abort(.custom(code: 499, reasonPhrase: "Не получилось декодировать контент в модель продукта"))
		}
		let productId = UUID()
		let product = Product(id: productId, title: productDTO.title, description: productDTO.description, price: productDTO.price, category: productDTO.category, image: nil)
		
		if let image = productDTO.image {
			
			let imageDirectory = req.application.directory.workingDirectory + "images/products/"
			let imagePath = imageDirectory + "\(productId).png"
			
			// Проверяем, существует ли директория
			if !FileManager.default.fileExists(atPath: imageDirectory) {
				// Создаем директорию
				try FileManager.default.createDirectory(atPath: imageDirectory, withIntermediateDirectories: true, attributes: nil)
			}
			
			try await req.fileio.writeFile(.init(data: image), at: imagePath)
			
			product.image = imagePath
			
			try await product.save(on: req.db)
			return product
		} else {
			try await product.save(on: req.db)
			return product
		}
	}

	@Sendable
	func getAllHandler(_ req: Request) async throws -> Page<Product> {
		// Extract page and per parameters from the request query
		let page = (try? req.query.get(Int.self, at: "page")) ?? 1
		let per = (try? req.query.get(Int.self, at: "per")) ?? 10
		
		// Extract sorting parameters
		let sortField = SortableField(rawValue: req.query[String.self, at: "sortField"] ?? "category") ?? .category
		let sortDirection = req.query[String.self, at: "sortDirection"]?.lowercased() ?? "asc"
		
		// Apply sorting
		let query = Product.query(on: req.db)
		switch sortField {
		case .category:
			switch sortDirection {
			case "asc":
				query.sort(\.$category, .ascending)
			case "desc":
				query.sort(\.$category, .descending)
			default:
				query.sort(\.$category, .ascending)
			}
		case .price:
			switch sortDirection {
			case "asc":
				query.sort(\.$price, .ascending)
			case "desc":
				query.sort(\.$price, .descending)
			default:
				query.sort(\.$price, .ascending)
			}
		}
		
		return try await query.paginate(PageRequest(page: page, per: per))
	}
	
	@Sendable
	func getHandler(_ req: Request) async throws -> Product {
		guard let id = req.parameters.get("productID", as: UUID.self) else {
			throw Abort(.badRequest)
		}
		guard let product = try await Product.find(id, on: req.db) else {
			throw Abort(.notFound)
		}
		return product
	}
	
	@Sendable
	func updateHandler(_ req: Request) async throws -> Product {
		guard let id = req.parameters.get("productID", as: UUID.self) else {
			throw Abort(.badRequest)
		}
		guard let product = try? req.content.decode(Product.self) else {
			throw Abort(.badRequest)
		}
		
		product.id = id
		try await product.update(on: req.db)
		return product
	}
	
	@Sendable
	func deleteHandler(_ req: Request) async throws -> HTTPStatus {
		guard let id = req.parameters.get("productID", as: UUID.self) else {
			throw Abort(.badRequest)
		}
		guard let product = try await Product.find(id, on: req.db) else {
			throw Abort(.notFound)
		}
		try await product.delete(on: req.db)
		return .ok
	}

	enum SortableField: String {
		case category, price
	}
	
}

struct ProductDTO: Content {
	var title: String
	var description: String
	var price: Int
	var category: String
	var image: Data?
}

