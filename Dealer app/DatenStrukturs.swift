/**This code contains the model structures for representing orders and the response object.**/
import Foundation
import SwiftUI

// Structure representing an order
struct Orders: Codable, Identifiable {
    let id: String
    let entries: [EntryDo]
    let state: String
}

// Structure representing an entry in an order
struct EntryDo: Codable {
    let amount: Int
    let productID: String
}

// Structure representing the response containing a list of orders
struct OrdersResponse: Codable {
    let orders: [Orders]
}

// This class is responsible for making network requests to interact with the server's API related to orders.
class ReqFunktionalität: ObservableObject {
    
    // Published property to hold the fetched orders
    @Published  var orders: [Orders] = []
    
    // Current page number for fetching orders
    private var currentPage: Int = 1
   
    // Fetches orders from the server
    func fetchOrders() async -> OrdersResponse? {
        
        var list: OrdersResponse? = nil
        
        let per = 100
            let url = URL(string: "http://YOUR Server Address/api/orders?page=\(currentPage)&per=\(per)")!

        do {
            
            let (data, _) = try await URLSession.shared.data(from: url)
            list = try JSONDecoder().decode(
                OrdersResponse.self,
                from: data)
            
        }
                     catch {
                        print("Error decoding orders data: \(error)")
                    }

    
        return list
    }


    // Completes an order
    func completeOrder(_ order: Orders) {
        
        let urlString = "http://YOUR Server Address/api/orders/\(order.id)/complete"
            print(order.id)

            guard let url = URL(string: urlString) else {
                fatalError("Ungültige URL: \(urlString)")
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")



            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Fehler: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Empty response data")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Orders.self, from: data)
                    
                    print("complete Success: \(response)")
                  
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Order is Completed.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        
                    
                    

                } catch {
                    print("Error parsing server response: \(error)")
                    
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Order is not processing.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                }
            }.resume()
       
     }
    
    // Cancels an order
    func cancelOrder(_ order: Orders) {
        let urlString = "http://YOUR Server Address/api/orders/\(order.id)/cancel"
            print(order.id)

            guard let url = URL(string: urlString) else {
                fatalError("Ungültige URL: \(urlString)")
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")



            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Fehler: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Empty response data")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Orders.self, from: data)
                    
                    print("Cancel Success: \(response)")
                   
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Order Canceled.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                    
                    
                

                } catch {
                    print("Error parsing server response: \(error)")
                }
            }.resume()
       
        }
    
    
    // Deletes an order
    func deleteOrder(_ order: Orders) {
        
        let urlString = "http://YOUR Server Address/api/orders/\(order.id)"
            print(order.id)

            guard let url = URL(string: urlString) else {
                fatalError("Ungültige URL: \(urlString)")
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Fehler: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Empty response data")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Orders.self, from: data)
                    print("Delete Success: \(response)")
                  
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Order Deleted.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                    
               
                   
                    
                } catch {
                    print("Order is not in statuc Cancel")
                    print("Error parsing server response: \(error)")
                    
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Order can not be deleted", message: "Order is not in status Cancel.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                    
                }
            }.resume()
       
    }
    
  
}


