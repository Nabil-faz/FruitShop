/**This code defines a class called CacheFunc that provides functions for caching and fetching images from cache or API.**/

import Foundation
import SwiftUI

// CacheFunc class to handle caching and fetching of images
class CacheFunc: ObservableObject {
    
    // Function to save an image to cache
    func saveImageToCache(image: UIImage, productId: String) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        // Create a filename using the productId
        let filename = "\(productId).png"
        let fileURL = cachesDirectory.appendingPathComponent(filename)
        
        // Convert the image to PNG data and save it to the fileURL
        if let data = image.pngData() {
            do {
                try data.write(to: fileURL)
                print("Image successfully saved in cache: \(fileURL.path)")
            } catch {
                print("Error saving the image in the cache: \(error)")
            }
        }
    }
    
    // Function to fetch an image from the API
    func fetchImageFromAPI(productId: String, completion: @escaping (UIImage?) -> Void) {
        
        guard let url = URL(string: "http://127.0.0.1:8080/api/products/\(productId)/photo") else {
            completion(nil)
            return
        }
        
        
        // Fetch the image data from the API
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image from API: \(error)")
                completion(nil)
                return
            }
            
            // Check if the data can be converted to an image
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Save the image in the cache
            self.saveImageToCache(image: image, productId: productId)
            
            // Return the fetched image
            completion(image)
        }.resume()
    }
    
    // Function to fetch an image from the cache
    func fetchImageFromCache(productId: String) -> UIImage? {
        
        // Get the caches directory
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Create a filename using the productId
        let filename = "\(productId).png"
        let fileURL = cachesDirectory.appendingPathComponent(filename)
        
        // Try to read the image data from the cache file
        if let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) {
            print("Image successfully retrieved from cache: \(fileURL.path)")
            return image
        }
        
        // If the image is not found in the cache, return nil
        return nil
    }
    
    // Function to fetch a product image either from the cache or API
    func fetchProductImage(product: Products, completion: @escaping (UIImage?) -> Void) {
        
        // Try to fetch the image from the cache
        if let cachedImage = fetchImageFromCache(productId: product.id) {
            completion(cachedImage)
        } else {
            // If image not found in cache, fetch it from the API
            fetchImageFromAPI(productId: product.id) { image in
                completion(image)
            }
        }
    }
}
