import SwiftUI
import Combine
import UIKit

// https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/
public struct HXAsyncImage<Content:View>: View {
    @ObservedObject private var loader:HXImageLoader
    private let placeholder:(()->Content)?
        
    public init(url:URL?, placeholder:@escaping ()->Content) {
        self.loader = HXImageLoader(url:url)
        self.placeholder = placeholder
    }
        
    // Don't like the overuse of ! here, but if-let is not allowed
    public var body: some View {
        if ( self.loader.image != nil ) {
            let x = print("\(self.loader.id) show image")
            Image(uiImage:self.loader.image!)
                .resizable()
        } else {
            let y = print("\(self.loader.id) show placeholder")
            self.placeholder!()
                .onAppear() {
                    print("\(self.loader.id) requesting load image")
                    self.loader.load()
                }.onDisappear() {
                    print("\(self.loader.id) cancelling load image")
                    self.loader.cancel()
                }
        }
    }
}

private class HXImageLoader: ObservableObject {
    static private var cache = NSCache<NSURL,UIImage>()
        
    @Published var image:UIImage?
    private var url:URL?
    private var dataTask:URLSessionDataTask?
    
    var id:UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }

    init(url:URL?) {
        if let url = url,
           let cachedImage = Self.cache.object(forKey:url as NSURL) {
            self.image = cachedImage
        } else {
            self.url = url
        }
        
        print("\(self.id) init")
        //self.load()
    }
    
    deinit {
        print("\(self.id) deinit")
        self.cancel()
    }
    
    func load() {
        let selfid = self.id
        
        guard let url = self.url,
              self.dataTask == nil,
              self.image == nil else {
            print("\(self.id) 1. Escaping url:\(String(describing: self.url)) dataTask:\(String(describing: self.dataTask)) image:\(String(describing: self.image))")
            return
        }
        
        if let cachedImage = Self.cache.object(forKey:url as NSURL) {
            print("\(self.id) 2. Escaping cached image:\(cachedImage)")
            self.image = cachedImage
            self.url = nil
            return
        }
                
        print("loading image: \(url)")
        self.dataTask = URLSession.shared.dataTask(with:url, completionHandler: { [weak self] (data,response,error) in
            print("\(selfid) loaded url: \(url) data:\(String(describing: data?.count))")
            guard let self = self else {
                return
            }
            if let error = error {
                print(error)
            }
            if ( error == nil && data == nil ) {
                print(response as Any)
            }
            if let data = data,
               let image = UIImage(data:data) {
                DispatchQueue.main.async { [weak self] in
                    print("\(selfid) loaded image: \(url)")
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
