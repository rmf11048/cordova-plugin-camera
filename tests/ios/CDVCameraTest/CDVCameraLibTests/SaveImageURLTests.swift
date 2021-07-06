//
//  SaveImageURLTests.swift
//  POCCameraEditorTests
//
//  Created by Gonçalo Frade on 29/06/2021.
//

import XCTest
@testable import POCCameraEditor

class SaveImageURLTests: XCTestCase {

    func test_GivenURLAndImage_ThenSaveImageToURL_ExpectImageLoadSuccessful() throws {
        guard
            let url = try? testBundleTemporaryURL().appendingPathComponent("temporaryFile.jpg"),
            let imagePath = try? testBundleImagePath(),
            let image = UIImage(contentsOfFile: imagePath)
        else {
            XCTFail("URL not available")
            return
        }
        
        let feature = SaveImageURLFeature(url: url)
        feature.saveImage(image) {
            switch $0 {
            case .success:
                do {
                    let validateImage = image.pngData()
                    let dataSaved = try Data(contentsOf: url)
                    XCTAssertEqual(validateImage, dataSaved)
                }
                catch {
                    XCTFail("An error ocurred")
                }
                break
            case .failure:
                XCTFail("Could not save image")
            }
        }
    }
    
    private func testBundleImagePath() throws -> String {
        struct URLError: Error {}
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.path(forResource: "test-image", ofType: "jpg") else {
            throw URLError()
        }
        return url
    }
    
    private func testBundleTemporaryURL() throws -> URL {
        struct URLError: Error {}
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.resourceURL else {
            throw URLError()
        }
        return url
    }
}
