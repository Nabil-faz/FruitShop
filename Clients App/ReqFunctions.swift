/**This code represents a class called ReqFunc that handles network requests to fetch categories, vendors, and products. It also includes methods for fetching specific vendor and category details, making a payment, and creating a new order. The class is designed to work with API.**/
import Foundation
import SwiftUI

class ReqFunc: ObservableObject {
    
    // Store the fetched categories
    @Published var categories: [Categories] = []
    // Track the current page of categories
     private var currentPageCategory: Int = 1
    
    // Store the fetched vendors
    @Published var vendors: [Vendors] = []
    // Track the current page of vendors
     private var currentPageVendor: Int = 1
    
    // Store the fetched products
    @Published var products: [Products] = []
    // Track the current page of products
     private var currentPageProducts: Int = 1
    
 
    
    
    // Fetches products from the API
    func fetchProducts() {
        let per = 5 // Number of elements per page
        
        let url = URL(string: "http://127.0.0.1:8080/api/products?page=\(currentPageProducts)&per=\(per)")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data
            
            else {
                print("Error fetching products: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ProductResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.products.append(contentsOf: response.products)
                    self.currentPageProducts += 1
                }
            } catch {
                print("Error decoding products: \(error)")
            }
        }.resume()
    }

    
    // Fetches vendors from the API
    func fetchVendors() {
        let per = 100 // Number of elements per page

        let url = URL(string: "http://127.0.0.1:8080/api/vendors?page=\(currentPageVendor)&per=\(per)")!

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data
     
        
            else {
                print("Error fetching vendors: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(VendorResponse.self, from: data)

                DispatchQueue.main.async {
                    self.vendors.append(contentsOf: response.vendors)
                    self.currentPageVendor += 1
                }
            } catch {
                print("Error decoding vendors: \(error)")
            }
        }.resume()
    }
    
    
   // Fetches a specific vendor by ID from the API
    func fetchVendorId(vendorId: String, completion: @escaping (Vendors?) -> Void) {
        let url = URL(string: "http://127.0.0.1:8080/api/vendors/\(vendorId)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let vendor = try decoder.decode(Vendors.self, from: data)
                completion(vendor)
            } catch {
                print("Error decoding vendorID: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    
    // Fetches categories from the API
    func fetchCategories() {
        let per = 100 // Number of elements per page

        let url = URL(string: "http://127.0.0.1:8080/api/categories?page=\(currentPageCategory)&per=\(per)")!

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data
            
            else {
                print("Error fetching categories: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CategoryResponse.self, from: data)
                DispatchQueue.main.async {
                    self.categories.append(contentsOf: response.categories)
                    self.currentPageCategory += 1
                }
            } catch {
                print("Error decoding categories: \(error)")
            }
        }.resume()
    }
    
    // Fetches a specific category by ID from the API
    func fetchCategoryId(categoryId: String, completion: @escaping (Categories?) -> Void) {
        let url = URL(string: "http://127.0.0.1:8080/api/categories/\(categoryId)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let category = try decoder.decode(Categories.self, from: data)
                completion(category)
            } catch {
                print("Error decoding categoryID: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    
    // Makes a payment for a specific order
    func makePayment(orderID: String, paypalTransactionID: String, completion: @escaping (Bool) -> Void) {
        let urlString = "http://127.0.0.1:8080/api/orders/\(orderID)/pay"
       

        guard let url = URL(string: urlString) else {
            fatalError("invalid URL: \(urlString)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "paypalTransactionId": paypalTransactionID
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            print("Error decoding : \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Empty response data")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Orders.self, from: data)
                print("Success: \(response)")
                
                let paymentSuccessful = true // Replace with your payment success logic
                completion(paymentSuccessful)
                
            } catch {
                print("Error parsing server response: \(error)")
            }
        }.resume()
    }
    
    
    
    // Creates a new order with the items from the cart
    func postfunc(completion: @escaping (String) -> Void) {
        
        let orderID = UUID().uuidString
        var orderEntries: [EntryDo] = []
        let cartViewModel = CartViewModel()

        for cartItem in cartViewModel.cartItems {
            let entry = EntryDo(
                amount: cartItem.quantity,
                productID: cartItem.productId
            )
            orderEntries.append(entry)
        }

        let orderData = Orders(
            id: orderID,
            entries: orderEntries,
            state: "paymentPending"
        )

        guard let url = URL(string: "http://127.0.0.1:8080/api/orders") else {
             print("invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(orderData)
            request.httpBody = jsonData
        } catch {
            print("Error encoding order data: \(error)")
            completion("") // Return empty orderID in case of encoding error
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending order request: \(error)")
                completion("") // Return empty orderID in case of request error
                return
            }

            guard let data = data else {
                print("Empty response data")
                completion("") // Return empty orderID in case of empty response data
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Orders.self, from: data)
                print("Success: \(response)")
                completion(response.id) // Return the generated orderID
            } catch {
                print("Error parsing server response: \(error)")
                completion("") // Return empty orderID in case of parsing error
            }
        }
        task.resume()
    }
    
    
    // Fetches products for a specific category from the API
        func fetchProductsCT(for categoryId: String) {
            let per = 100 // Number of elements per page
            
            let url = URL(string: "http://127.0.0.1:8080/api/products?category=\(categoryId)&page=\(currentPageProducts)&per=\(per)")!
            
            // Perform the network request to fetch the products
            URLSession.shared.dataTask(with: url) { data, _, error in
                // Handle the received data
                guard let data = data else {
                    print("Error fetching products: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ProductResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.products = response.products
                        self.currentPageProducts += 1
                    }
                } catch {
                    print("Error decoding products: \(error)")
                }
            }.resume()
        }
    
    func fetchProductsCT_VD() {
        let per = 100 // Number of elements per page
        
        let url = URL(string: "http://127.0.0.1:8080/api/products?page=\(currentPageProducts)&per=\(per)")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data
            
            else {
                print("Error fetching products: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ProductResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.products.append(contentsOf: response.products)
                    self.currentPageProducts += 1
                }
            } catch {
                print("Error decoding products: \(error)")
            }
        }.resume()
    }

}
