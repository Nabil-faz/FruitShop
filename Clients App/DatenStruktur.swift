/** This code defines structs that represent products, vendors, Categories, Orders, PayOrderDto data and their responses information. **/
import Foundation

// Represents a products object with properties for products details
struct Products: Codable, Identifiable{
    
    let id :String
    let vendorId: String
    let categoryId: String
    let price: Double
    let name: String
    let description: String
    let image: String? // An optional URL or path to the products image
   
}

// Represents a response object containing an array of products
struct ProductResponse: Codable {
    let products: [Products]
}

// Represents a vendors object with properties for Vendors details
struct Vendors: Codable, Identifiable{
    
    let name: String
    let id : String
}

// Represents a response object containing an array of vendors
struct VendorResponse: Codable {
    let vendors: [Vendors]
    
}

// Represents a Categories object with properties for Categories details
struct Categories: Codable, Identifiable{
    let id :String
    let name: String
 
}

// Represents a response object containing an array of Categories
struct CategoryResponse: Codable {
    let categories: [Categories]
}

// Represents a orders object with properties for orders details
struct Orders: Codable {
    let id: String
    let entries: [EntryDo]
    let state: String
}

// Represents a entries object with properties for entries details
struct EntryDo: Codable {
    let amount: Int
    let productID: String
}

// Represents a response object containing an array of Orders
struct OrdersResponse: Codable {
    let orders: [Orders]
}

// Represents a PayOrder object with properties for PayOrder details
struct PayOrderDto: Codable {
    
    let paypalTransactionId: String
}
