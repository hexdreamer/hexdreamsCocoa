
import Foundation
import CoreData

public class HXResourceManager : NSObject, URLSessionDelegate {
    
    public static let shared = HXResourceManager()
    
    lazy var resourceManagerRootDirectory:URL = {
        HXApplication.cachesDirectory().appendingPathComponent("HXResourceManager")
    }()
    
    lazy var metadataStoreLocation:URL = {
        self.resourceManagerRootDirectory.appendingPathComponent("Metadata").appendingPathComponent("Metadata.sqlite")
    }()
    
    lazy var storageRootDirectory:URL = {
        self.resourceManagerRootDirectory.appendingPathComponent("Storage")
    }()
    
    lazy var modelURL:URL = {
        return Bundle(for: type(of: self)).url(forResource:"HXResourceManager", withExtension: "momd") ?? {
            fatalError("Could not find HXResourceManager model")
        }
    }()
    
    lazy var persistentContainer:NSPersistentContainer = {
        let model = NSManagedObjectModel(contentsOf:self.modelURL) ?? {
            fatalError("Could not load model at \(self.modelURL)")
        }
        let storeDescription = NSPersistentStoreDescription(url:self.metadataStoreLocation)
        let persistentContainer = NSPersistentContainer(name:"HXResourceManager", managedObjectModel:model)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        return persistentContainer
    }()

    lazy var moc:NSManagedObjectContext = {
        self.persistentContainer.newBackgroundContext()
    }()
    
    var domainsByIdentifier:[String:HXResourceDomain]
    
    private func cacheDomains() {
        self.moc.performAndWait {
            do {
                let domains = self.moc.hxFetch(entity:HXResourceDomain.self, predicate:nil, sortString:nil, returnFaults:false)
                self.domainsByIdentifier = try domains.mapDict({$0.identifier})
            } catch {
                fatalError("Error caching domains: \(error)")
            }
        }
    }
    
    private func domainFor(identifier:String) throws -> HXResourceDomain {
         return try self.domainsByIdentifier[identifier] ?? {
            throw HXErrors.invalidArgument("No domain with identifier \(identifier)")
        }
    }
    
    private func generateResourceURL(domain:HXResourceDomain, uuid:UUID, filename:String) -> URL {
        var path = self.storageRootDirectory
        for d in domain.path {
            path.appendPathComponent(d.name ?? "_")
        }
        path.appendPathComponent("\(uuid.uuidString)-\(filename)")
        return path
    }
    
    public lazy var operationQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public lazy var cellularSession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier:"HXResourceManagerCellular")
        config.allowsCellularAccess = true
        let session = URLSession(configuration:config, delegate:self, delegateQueue:self.operationQueue)
        return session
    }()
    
    public lazy var wifiOnlySession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier:"HXResourceManagerCellular")
        config.allowsCellularAccess = true
        let session = URLSession(configuration:config, delegate:self, delegateQueue:self.operationQueue)
        return session
    }()

    public var serialize:DispatchQueue {
        return self.operationQueue.underlyingQueue ?? {
            fatalError("Cannot get the serialize queue: The operation queue's underlyingQueue is nil")
        }
    }
    
    var runningTasks = [URLSessionDownloadTask]()
    
    override init() {
        self.domainsByIdentifier = [String:HXResourceDomain]()
        super.init()
        self.cacheDomains()
    }
    
    public func resourceFor(domainIdentifier:String, request:URLRequest, overCellular:Bool, purgeable:Bool,
                            completionHandler:@escaping (URL?, URLResponse?, Error?) -> Void) {
        self.resourceFor(domainIdentifier:domainIdentifier,
                         session:overCellular ? self.cellularSession : self.wifiOnlySession,
                         request:request, purgeable:purgeable, completionHandler:completionHandler)
    }

    private func resourceFor(domainIdentifier:String, session:URLSession, request:URLRequest, purgeable:Bool,
                             completionHandler:@escaping (URL?, URLResponse?, Error?) -> Void) {
        self.serialize.async {
            do {
                let url = try request.url ?? {throw HXErrors.hxnil("Request url")}
                let domain = try self.domainFor(identifier:domainIdentifier)
                let predicate = NSPredicate(format:"domain = %@ AND urlString = %@", argumentArray:[domain, url.absoluteString])
                
                self.moc.perform {
                    do {
                        let results = self.moc.hxFetch(entity:HXResource.self, predicate:predicate, sortString:nil, returnFaults:false)
                        switch results.count {
                        case 0:
                            self.retrieveResourceFor(domain:domain, session:session , request:request, purgeable:purgeable, completionHandler:completionHandler)
                        case 1:
                            let resource = results[0]
                            let path = try resource.path ?? {throw HXErrors.hxnil("resource.path for \(url)")}
                            completionHandler(URL(fileURLWithPath:path), nil, nil)
                        default:
                            throw HXErrors.internalInconsistency("More than one resource found for domain \(domainIdentifier) and url \(url)")
                        }
                    } catch { // self.moc.perform
                        completionHandler(nil, nil, error)
                    }
                }
            } catch { // self.serialize.async
                completionHandler(nil, nil, error)
            }
        }
    }
    
    private func retrieveResourceFor(domain:HXResourceDomain, session:URLSession, request:URLRequest, purgeable:Bool,
                                     completionHandler:@escaping (URL?, URLResponse?, Error?) -> Void
        ) {
        self.serialize.async {
            do {
                let requestURL = try request.url ?? {throw HXErrors.hxnil("request.url")}
                let task = session.downloadTask(with:request) { (burl,bresponse,berror) in
                    do {
                        try rethrow(berror)
                        let burl = try burl ?? {throw HXErrors.hxnil("no url available for downloaded file")}
                        let now = Date()
                        let uuid = UUID()
                        let resourceURL = self.generateResourceURL(domain:domain, uuid:uuid, filename:burl.lastPathComponent)
                        let attributes = try FileManager.default.attributesOfItem(atPath:burl.path)
                        let size = try attributes[.size] as? Int64 ?? {throw HXErrors.cocoa("Could not get size of resource file")}
                        try FileManager.default.copyItem(at:burl, to:resourceURL)
                        self.moc.perform {
                            do {
                                let resource = HXResource(context:self.moc)
                                resource.accessDate = now
                                resource.createDate = now
                                resource.path = resourceURL.path
                                resource.purgeable = purgeable
                                resource.purgeDate = nil
                                resource.size = size
                                resource.updateDate = now
                                resource.urlString = requestURL.absoluteString
                                resource.uuid = uuid
                                resource.domain = domain
                                resource.domain?.adjustSize(delta:size)
                                try self.moc.save()
                                completionHandler(resourceURL, bresponse, nil)
                                self.clearCompletedTasks()
                            } catch { // self.moc.perform
                                do {
                                    try FileManager.default.removeItem(at:resourceURL)
                                } catch {
                                    completionHandler(nil, nil, error)
                                }
                                completionHandler(nil, nil, error)
                            }
                        }
                    } catch { // let task = session.downloadTask
                        completionHandler(nil, nil, error)
                    }
                }
                self.runningTasks.append(task)
                task.resume()
            } catch { // self.serialize.async
                completionHandler(nil, nil, error)
            }
        }
    }

    private func refresh(resource:HXResource, session:URLSession, url:URL, purgeable:Bool,
                         completionHandler:@escaping (URL?, URLResponse?, Error?) -> Void
        ) {
        self.serialize.async {
            do {
                let urlString = try resource.urlString ?? {throw HXErrors.hxnil("resource.urlString")}
                let requestURL = try URL(string:urlString) ?? {throw HXErrors.invalidArgument("could not initialize URL with \(urlString)")}
                let task = session.downloadTask(with:URLRequest(url:requestURL)) { (burl,bresponse,berror) in
                    do {
                        try rethrow(berror)
                        let burl = try burl ?? {throw HXErrors.hxnil("no url available for downloaded file")}
                        let resourcePath = try resource.path ?? {throw HXErrors.hxnil("resource.path")}
                        let now = Date()
                        let resourceURL = URL(fileURLWithPath:resourcePath)
                        let attributes = try FileManager.default.attributesOfItem(atPath:burl.path)
                        let size = try attributes[.size] as? Int64 ?? {throw HXErrors.cocoa("Could not get size of resource file")}
                        try FileManager.default.copyItem(at:burl, to:resourceURL)
                        self.moc.perform {
                            do {
                                let domain = try resource.domain ?? {throw HXErrors.hxnil("resource.domain")}
                                domain.adjustSize(delta:-resource.size)
                                domain.adjustSize(delta:size)
                                resource.size = size
                                resource.updateDate = now
                                try self.moc.save()
                                completionHandler(resourceURL, bresponse, nil)
                                self.clearCompletedTasks()
                            } catch { // self.moc.perform
                                do {
                                    try FileManager.default.removeItem(at:resourceURL)
                                } catch {
                                    completionHandler(nil, nil, error)
                                }
                                completionHandler(nil, nil, error)
                            }
                        }
                    } catch { // let task = session.downloadTask
                        completionHandler(nil, nil, error)
                    }
                }
                self.registerTask(task)
                task.resume()
            } catch { // self.serialize.async
                completionHandler(nil, nil, error)
            }
        }
    }
    
    public func registerTask(_ task:URLSessionDownloadTask) {
        self.serialize.async {
            self.runningTasks.append(task)
            self.changed(\HXResourceManager.runningTasks)
        }
    }
    
    public func clearCompletedTasks() {
        self.serialize.async {
            self.runningTasks.removeAll {
                $0.state == .completed
            }
            self.changed(\HXResourceManager.runningTasks)
        }
    }
    
    public func clearErroredTasks() {
        self.serialize.async {
            self.runningTasks.removeAll {
                $0.error != nil
            }
            self.changed(\HXResourceManager.runningTasks)
        }
    }
    
    public func clearQuotaOverages() {
        
    }
}
