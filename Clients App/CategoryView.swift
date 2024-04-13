/**This code represents a SwiftUI that displays a list of categories and Navigate to their details.**/
import Foundation
import SwiftUI

// The main view that displays a list of categories
struct CategoryListView: View {
    
    //  Create a state object to manage the instance of ReqFun
    @StateObject var reqFuncInstance = ReqFunc()
    
    var body: some View {
        NavigationView {
            // Create a list view displaying each category
            List(reqFuncInstance.categories) { category in
                // Navigate to the detail view when a category is selected
                NavigationLink(destination: CategoryDetailView(categoty: category)) {
                    Text(category.name)
                }
            }
            .navigationTitle("Categories")
            .onAppear {
                //Fetch all the categories when the view appears
                reqFuncInstance.fetchCategories()
            }
        }
    }
}
    
// The detail view that shows individual category information
    struct CategoryDetailView: View{
        let categoty: Categories
         @StateObject private var reqFuncInstance = ReqFunc()
         
         var body: some View {
             List {
                        Section(header: Text("Category name")) {
                            Text(categoty.name)
                        }
                        
                 Section(header: Text("Category Products")) {
                     ForEach(reqFuncInstance.products.filter { $0.categoryId == categoty.id }) { product in
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
