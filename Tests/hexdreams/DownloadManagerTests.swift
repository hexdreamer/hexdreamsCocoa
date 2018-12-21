
import XCTest
import hexdreamsCocoa
import Foundation

class DownloadManagerTests: XCTestCase {
    
    static let resourceURLString = "https://www.dccomics.com/sites/default/files/comic_reader/GLpreview_Page_4_5bd8da547f6130.96010478.jpg"
    
    lazy var resourceURL:URL = {
        return URL(string:DownloadManagerTests.resourceURLString) ?? {fatalError()}
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRendezvousOnURL() {
        let dataExpectation = XCTestExpectation(description: "Get Green Lantern page using a dataTask")
        let immediateJob = HXDownloadManager.shared.downloadResource(at:resourceURL, options:[.immediate]) { (bjob, berror) in
            XCTAssertNil(berror)
            dataExpectation.fulfill()
        }
        self.wait(for:[dataExpectation], timeout:500.0)
        
        let downloadExpectation = XCTestExpectation(description: "Get Green Lantern page using a downloadTask")
        let downloadJob = HXDownloadManager.shared.downloadResource(at:resourceURL, options:[]) { (bjob, berror) in
            XCTAssertNil(berror)
            downloadExpectation.fulfill()
        }
        self.wait(for:[downloadExpectation], timeout:500.0)
        
        XCTAssertNotNil(immediateJob.task)
        XCTAssertNotNil(downloadJob.task)
        XCTAssertEqual(immediateJob.task, downloadJob.task)
        XCTAssertTrue(immediateJob.task === downloadJob.task)

        XCTAssertNotNil(immediateJob.downloadedData)
        XCTAssertNotNil(downloadJob.downloadedData)
        guard let immediateData = immediateJob.downloadedData else {
            XCTFail()
            return
        }
        XCTAssertEqual(2592010, immediateData.count)
        XCTAssertEqual(immediateJob.downloadedData, downloadJob.downloadedData)
    }
    
}
