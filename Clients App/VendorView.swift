/**This code represents a SwiftUI that displays a list of vendors and Navigate to their details.**/
import Foundation
import SwiftUI

// The main view that displays a list of Vendors
struct VendorListView: View {
    
    //  Create a state object to manage the instance of ReqFun
    @StateObject  var reqFuncInstance = ReqFunc()
    
    var body: some View {
        NavigationView {
            // Create a list view displaying each vendor
            List(reqFuncInstance.vendors) { vendor in
                // Navigate to the detail view when a vendor is selected
                NavigationLink(destination: VendorDetailView(vendor: vendor)) {
                    Text(vendor.name)
                }
            }
            .navigationTitle("Vendors")
            .onAppear{
                //Fetch all the vendors when the view appears
                reqFuncInstance.fetchVendors()
            }
        }
    }
}

// The detail view that shows individual vendor information
struct VendorDetailView: View {
    let vendor: Vendors
       @StateObject private var reqFuncInstance = ReqFunc()

       var body: some View {
           List {
               Section(header: Text("Vendor name")) {
                   Text(vendor.name)
               }

               Section(header: Text("Vendor Products")) {
                   ForEach(reqFuncInstance.products.filter { $0.vendorId == vendor.id }) { product in
                       NavigationLink(destination: ProductDetailView(product: product)) {
                           VStack(alignment: .leading) {
                               Text(product.name)
                                   .font(.headline)
                               Text(product.price.formatted(.currency(code: "USD")))
                                   .font(.subheadline)
                               Text(product.description)
                                   .font(.subheadline)
                           }
                       }
                   }
               }
           }
           .onAppear {
               reqFuncInstance.fetchProductsCT_VD()
           }
       }
}
