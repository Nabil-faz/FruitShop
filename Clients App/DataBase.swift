
/**A class that handles the storage and management of shopping cart items**/
import Foundation
import Combine
import GRDB

struct CartEntry: Identifiable, Codable, FetchableRecord, MutablePersistableRecord {
    
    var id: Int?
    var productId: String
    var quantity: Int
}

class CartDatabase {
    
    let inMemory: Bool = false
    let queue: DatabaseQueue

    init() {
        // Initialize the database queue based on the inMemory
        if inMemory {
            queue = try! DatabaseQueue(path: ":memory")
        } else {
            let documentsDirectory = try! FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let databaseUrl = documentsDirectory.appendingPathComponent("databaseFS.sqlite")
            let databasePath = databaseUrl.path
            print("Database Path: \(databasePath)" )
            queue = try! DatabaseQueue(path: databasePath)
        }
       
        // Define and register the database migration for creating the "CartEntry" table
        var migrator: DatabaseMigrator = DatabaseMigrator()
        migrator.registerMigration("V1") { db in
            try db.create(table: "CartEntry") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("productId", .integer).notNull()
                t.column("quantity", .integer).notNull()
            }
        }

        
        // Perform the migrations
        do {
            try migrator.migrate(queue)
        } catch {
            print("Migration error: \(error)")
        }
    }

    // Add a shopping cart item to the database
    func addCartItem(_ cartItem: inout CartEntry) {
        do {
            try queue.write { db in
                try cartItem.saveAndFetch(db)
            }
        } catch {
           
            print("Error while adding the shopping cart entry: \(error)")
        }
    }

    // Update a shopping cart item in the database
    func updateCartItem(_ cartItem: CartEntry) {
        do {
            try queue.write { db in
                try cartItem.update(db)
            }
        } catch {
     
            print("Error while updating the shopping cart entry:\(error)")
        }
    }

    // Delete a shopping cart item from the database
    func deleteCartItem(_ cartItem: CartEntry) {
        guard let cartItemId = cartItem.id else {
            return
        }
        do {
            try queue.write { db in
                try CartEntry.deleteOne(db, key: cartItemId)
            }
        } catch {
            
            print("Error when deleting the shopping cart entry: \(error)")
        }
    }

    // Fetch all shopping cart items from the database
    func fetchAllCartItems() -> [CartEntry] {
        do {
            return try queue.read { db in
                try CartEntry.fetchAll(db)
            }
        } catch {
           
            print("Error retrieving shopping cart entries: \(error)")
            return []
        }
    }
}


class CartViewModel: ObservableObject {
    
    private var cartDatabase: CartDatabase
    
    @Published var cartItems: [CartEntry] = []
    @Published var productDetails: [String: Products] = [:]
    
   
  
// Compute the total price of all items in the cart
    var totalPrice: Double {
          let total = cartItems.reduce(0.0) {
              
              $0 + (productPrice(for: $1.productId) * Double($1.quantity))
              
          }
          return total
      }
      
      func productPrice(for productId: String) -> Double {
          if let product = productDetails[productId] {
              return product.price
          } else {
              return 0.0 // or any default price
          }
      }
    
    init() {
        cartDatabase = CartDatabase()
        cartItems = cartDatabase.fetchAllCartItems()
    }
    
    // Add a shopping cart item
    func addCartItem(_ cartItem: CartEntry) {
        var mutableCartItem = cartItem
        cartDatabase.addCartItem(&mutableCartItem)
        cartItems.append(mutableCartItem)
    }
    
    // Update a shopping cart item
    func updateCartItem(_ cartItem: CartEntry) {
        cartDatabase.updateCartItem(cartItem)
    }
    
    // Delete a shopping cart item
    func deleteCartItem(_ cartItem: CartEntry) {
        cartDatabase.deleteCartItem(cartItem)
        if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
            cartItems.remove(at: index)
        }
    }
    // Delete all shopping cart items
    func deleteAllCartItems() {
          for cartItem in cartItems {
              deleteCartItem(cartItem)
          }
          cartItems.removeAll()
      }
      
    
    // Update the cart items and fetch the corresponding product details
    func updateCartItems() {
        cartItems = cartDatabase.fetchAllCartItems()
        
        for cartItem in cartItems {
              getProductDetails(for: cartItem) { [weak self] product in
                  guard let product = product else { return }
                  self?.productDetails[cartItem.productId] = product
              }
          }
    }
    
    // Set the quantity of a product in the cart
       func quantity(for productId: String) -> Int {
           if let cartItem = cartItems.first(where: { $0.productId == productId }) {
               return cartItem.quantity
           }
           return 0
       }
       
   
       func setQuantity(_ quantity: Int, for productId: String) {
           if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
               cartItems[index].quantity = quantity
               updateCartItem(cartItems[index])
           }
       }
    

    // Fetch product details for a cart item from an API endpoint
    func getProductDetails(for cartItem: CartEntry, completion: @escaping (Products?) -> Void) {
        let urlString = "http://YOU Server Address/api/products/\(cartItem.productId)"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Products.self, from: data)
                        
                        DispatchQueue.main.async {
                            // Saving the product information in the productDetails dictionary
                            self.productDetails[cartItem.productId] = product
                            completion(product)
                        }
                    } catch {
                        print("Error processing the API response: \(error)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else if let error = error {
                    print("API request error: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        }
    }
    
    
}
