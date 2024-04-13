/**A SwiftUI view that represents a shopping cart. It allows the user to view and manage their cart items, as well as place a payment order.**/

import SwiftUI
 
// View for displaying the cart
struct CartView: View {
    
    // Observable object for managing the cart
    @ObservedObject var cartViewModel = CartViewModel()
    
    // State variables for managing payment view and transaction IDs
       @State var showPaymentView = false
       @State var paypalTransactionID = UUID().uuidString
      @State var orderID = UUID().uuidString
    
    // State object for making network requests
    @StateObject var reqFuncInstance = ReqFunc()
        
    var body: some View {
        NavigationView {
            List {
                ForEach(cartViewModel.cartItems, id: \.id) { cartItem in
                    
                    if let product = cartViewModel.productDetails[cartItem.productId] {
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            VStack(alignment: .leading) {
                                Text("\(product.name)")
                                    .font(.headline)
                                
                                Stepper(value: Binding(
                                    get: { cartViewModel.quantity(for: cartItem.productId) },
                                    set: { quantity in
                                        cartViewModel.setQuantity(quantity, for: cartItem.productId)
                                    }), in: 0...100) {
                                        Text("Quantity: \(cartViewModel.quantity(for: cartItem.productId))")
                                    }
                            }
                            
                            
                        }
                    } else {
                        Text("Loading...")
                            .onAppear {
                                cartViewModel.getProductDetails(for: cartItem) { product in
                                    if let product = product {
                                        cartViewModel.productDetails[cartItem.productId] = product
                                    }
                                }
                            }
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        let cartItem = cartViewModel.cartItems[index]
                        cartViewModel.deleteCartItem(cartItem)
                    }
                }
            }
            .navigationTitle("Cart")
            .refreshable {
              
                cartViewModel.updateCartItems()
            }
            
            .onAppear {
                cartViewModel.updateCartItems()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // Make a network request to create an order
                        reqFuncInstance.postfunc { generatedOrderID in
                            if !generatedOrderID.isEmpty {
                                paypalTransactionID = UUID().uuidString
                                self.orderID = generatedOrderID
                                showPaymentView = true
                            } else {
                                // Handle postfunc error
                                print("Error creating order")
                            }
                        }
                    
                    }) {
                        HStack {
                            Text("Kostenpflichtig Bestellen")
                            Text("Gesamtpreis: \(String(format: "%.2f", cartViewModel.totalPrice))")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
      
        .sheet(isPresented: $showPaymentView) {
            // Show the payment view as a sheet
            PaymentView(orderID:  $orderID , paypalTransactionID: paypalTransactionID)
                    }
        
    }
    
   
}

// View for payment completion
struct PaymentView: View {
    
    @Binding var orderID: String
    let paypalTransactionID: String
    
    @Environment(\.presentationMode) var presentationMode
    
    // State object for making network request
    @StateObject  var reqFuncInstance = ReqFunc()
    
    @ObservedObject  var cartViewModel = CartViewModel()
    
    @State  var paymentSuccessful = false
   
    
    var body: some View {
        VStack {
            Text("Complete payment")
                .font(.title)
                .padding()

            Button(action: {
                // Make a request to make the payment
                reqFuncInstance.makePayment(orderID: orderID, paypalTransactionID: paypalTransactionID) { success in
                    paymentSuccessful = success
                    
                    if success{
                       
                        cartViewModel.deleteAllCartItems()
                        
                        presentationMode.wrappedValue.dismiss()
    
                    }
                }
                
                
            }) {
                Text("Pay")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            .alert(isPresented: $paymentSuccessful) {
                Alert(
                    title: Text("Payment Successful"),
                    message: Text("Your payment was successful."),
                    dismissButton: .default(Text("OK"))
                )
               
            }
         
        }
     
    }
    
   
}


