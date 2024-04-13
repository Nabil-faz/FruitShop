/**This code represents a SwiftUI  that displays a list of products and their details. Users can view product information, such as name and price, and navigate to vendor and category details. They can also add products to their cart.**/
import Foundation
import SwiftUI


// The main view that displays a list of products
struct ProduktListeView: View {

    // Create a state object to manage the instance of ReqFunc
    @StateObject var reqFuncInstance = ReqFunc()
    
    var body: some View {
        NavigationView {
            // Create a list view displaying each product
            List(reqFuncInstance.products) { product in
                // Navigate to the product detail view when a product is selected
                NavigationLink(destination: ProductDetailView(product: product)) {
                    // Display the product details in a row
                    ProductRowView(product: product)
                }
            }
            .navigationTitle("Products")
            .refreshable {
                // Fetch products when the view is refreshed
                reqFuncInstance.fetchProducts()
            }
            .onAppear {
                // Fetch products when the view appears
                reqFuncInstance.fetchProducts()
            }
        }
    }
}


// The row view that displays product details
struct ProductRowView: View {
    
    // Store the product object
    let product: Products
    // Create a state object to manage the instance of CacheFunc
    @StateObject  var CacheFuncInstance = CacheFunc()
    // Store the product's image
    @State  var productImage: UIImage?
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.headline)
                .multilineTextAlignment(.leading)
            
            if let image = productImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 300, height: 150)
                    .cornerRadius(8)
            } else {
                Text("No Photo")
                    .padding(.vertical, 6.0)
            }
            
            Text(product.price.formatted(.currency(code: "USD")))
                .font(.subheadline)
        }
        .onAppear {
            CacheFuncInstance.fetchProductImage(product: product) { image in
                productImage = image
            }
        }
    }
}

// The detail view that shows individual product information
struct ProductDetailView: View {
    
    // Store the selected product object
    let product: Products
    // Store the vendor object
    @State var vendor: Vendors?
    // Store the category object
    @State var category: Categories?
    // Create a state object to manage the cart view model
    @StateObject var cartViewModel = CartViewModel()
    // Create a state object to manage the instance of ReqFunc
    @StateObject var reqFuncInstance = ReqFunc()

    
    
    var body: some View {
        List {
            Section(header: Text("Product")) {
                Text(product.name)

                Text(product.price.formatted(.currency(code: "USD")))
            }
            
            Section(header: Text("Vendor")) {
                if let vendor = vendor {
                    NavigationLink(destination: VendorDetailView(vendor: vendor)) {
                        Text(vendor.name)
                    }
                }else {
                    Text("Loading vendor...")
                        .onAppear(perform: {
                    reqFuncInstance.fetchVendorId(vendorId: product.vendorId) { fetchedVendor in
                                self.vendor = fetchedVendor
                            }
                        })
                }
            }
            
            Section(header: Text("Category")) {
                if let category = category {
                    NavigationLink(destination: CategoryDetailView(categoty: category)) {
                        Text(category.name)
                    }
                } else {
                    Text("Loading category...")
                        .onAppear(perform: {
                reqFuncInstance.fetchCategoryId(categoryId: product.categoryId) { fetchedCategory in
                                self.category = fetchedCategory
                            }
                        })
                }
            }
            
           

            
        }
        .navigationTitle("Product Detail")
        
        .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button(action: {
                         addToCart()
                     }) {
                         Image(systemName: "cart.badge.plus")
                     }
                 }
             }
         }
    
    // Add the selected product to the cart
    private func addToCart() {
        let newCartItem = CartEntry(productId: product.id, quantity: 1)
           cartViewModel.addCartItem(newCartItem)
           cartViewModel.updateCartItems()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: "Order is added to Curt.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

}

