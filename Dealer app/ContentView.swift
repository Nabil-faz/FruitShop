/**This SwiftUI view displays a list of orders. It allows users to view and manage orders, including completing, canceling, and deleting them.**/
import SwiftUI

struct OrderListView: View {
    @EnvironmentObject  var reqFunktionalität: ReqFunktionalität
    @State var orders: OrdersResponse? = nil
    
    var body: some View {
        NavigationView {
            let CheckorderItems = orders?.orders ?? []
            List(CheckorderItems) { order in
                    VStack(alignment: .leading) {
                        Text("Order number: \(order.id)")
                            .font(.headline)
                    
                        Text("Status: \(order.state)")
                    }
                    .swipeActions {
                        Button("Complete") {
                            reqFunktionalität.completeOrder(order)
                            Task(){
                                orders = await reqFunktionalität.fetchOrders()
                            }
                        }
                        .tint(.green)
                    
                        Button("Cancel") {
                            reqFunktionalität.cancelOrder(order)
                            Task(){
                                orders = await reqFunktionalität.fetchOrders()
                            }
                        }
                        .tint(.red)
                        
                        Button("Delete"){
                            reqFunktionalität.deleteOrder(order)
                            Task(){
                                orders = await reqFunktionalität.fetchOrders()
                            }
                        }
                    }
                    .background(order.state == "processing" ? Color.yellow.opacity(0.9) : Color.clear)
                }
               

                
            
          
            .navigationTitle("Order List")
            .refreshable {
                orders = await reqFunktionalität.fetchOrders()
               
            }
           
        }
        .task {

            orders = await reqFunktionalität.fetchOrders()


        }
    }
}

