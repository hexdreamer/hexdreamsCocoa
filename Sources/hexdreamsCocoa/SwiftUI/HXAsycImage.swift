#if canImport(UIKit)
import SwiftUI
import Combine
import UIKit

public struct HXAsyncImage<Content:View>: View {
    @ObservedObject private var loader:HXImageLoader
    private let placeholder:(()->Content)?
    
    public init(url:URL?, placeholder:@escaping ()->Content) {
        self.loader = HXImageLoader(url:url)
        self.placeholder = placeholder
    }
    
    // Don't like the use of ! here, but if-let is not allowed
    public var body: some View {
        if ( self.loader.image != nil ) {
            Image(uiImage:self.loader.image!)
                .resizable()
        } else {
            self.placeholder!()
        }
    }
}

private class HXImageLoader: ObservableObject {
    static private var cache = NSCache<NSURL,UIImage>()
        
    @Published var image:UIImage?
    private var url:URL?
    private var dataTask:URLSessionDataTask?
    
    init(url:URL?) {
        if let url = url,
           let cachedImage = Self.cache.object(forKey:url as NSURL) {
            self.image = cachedImage
        } else {
            self.url = url
        }
        self.load()
    }
    
    deinit {
        self.cancel()
    }
    
    func load() {
        guard let url = self.url,
              self.dataTask == nil,
              self.image == nil else {
            return
        }
        
        if let cachedImage = Self.cache.object(forKey:url as NSURL) {
            self.image = cachedImage
            self.url = nil
            return
        }
                
        self.dataTask = URLSession.shared.dataTask(with:url, completionHandler: { [weak self] (data,response,error) in
            guard let self = self else {
                return
            }
            if let error = error {
                print(error)
            }
            if let data = data,
               let image = UIImage(data:data) {
                DispatchQueue.main.async { [weak self] in
                    Self.cache.setObject(image, forKey:url as NSURL)
                    self?.image = image
                    self?.url = nil
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.dataTask = nil
            }
        })
        self.dataTask?.resume()
    }
    
    func cancel() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
}
#endif
