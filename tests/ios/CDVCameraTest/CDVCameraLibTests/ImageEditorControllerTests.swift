//
//  ImageEditorControllerTests.swift
//  POCCameraEditorTests
//
//  Created by Gonçalo Frade on 29/06/2021.
//

import XCTest
@testable import POCCameraEditor

class ImageEditorControllerTests: XCTestCase {
    
    private let cropRect = CGRect(x: 0, y: 0, width: 150, height: 150)

    func test_GivenImage_ThenRotateLeft_ExpectRotatedLeftImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-1-rotate", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }
        
        guard let resultImage = try? controller.rotateLeftImage(image) else {
            XCTFail("Failed rotation of image")
            return
        }
        
        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    func test_GivenImage_ThenRotate2TimesLeft_ExpectRotatedLeftImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-2-rotate", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }
        
        guard
            let firstRotate = try? controller.rotateLeftImage(image),
            let resultImage = try? controller.rotateLeftImage(firstRotate)
        else {
            XCTFail("Failed rotation of image")
            return
        }
        
        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    func test_GivenImage_ThenRotate3TimesLeft_ExpectRotatedLeftImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-3-rotate", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }
        
        guard
            let firstRotate = try? controller.rotateLeftImage(image),
            let secondRotate = try? controller.rotateLeftImage(firstRotate),
            let resultImage = try? controller.rotateLeftImage(secondRotate)
        else {
            XCTFail("Failed rotation of image")
            return
        }
        
        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    func test_GivenImage_ThenFlipHorizontaly_ExpectFlippedImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-flip", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }
        
        let resultImage = controller.flipHorizontaly(image)
        
        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    func test_GivenImage_ThendCrop_ExpectCroppedImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-crop", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }
        
        guard
            let resultImage = try? controller.cropImage(image, rect: cropRect)
        else {
            XCTFail("Failed rotation of image")
            return
        }
        
        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    func test_GivenImage_ThenRotateLeftAndCrop_ExpectCropedRotatedLeftImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-1-rotate-crop", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }
        
        guard
            let firstRotate = try? controller.rotateLeftImage(image),
            let resultImage = try? controller.cropImage(firstRotate, rect: cropRect)
        else {
            XCTFail("Failed rotation of image")
            return
        }
        
        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    func test_GivenImage_ThenRotate2TimesLeftAndCrop_ExpectRotatedLeft2TimesAndCropedImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-2-rotate-crop", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }

        guard
            let firstRotate = try? controller.rotateLeftImage(image),
            let secondRotate = try? controller.rotateLeftImage(firstRotate),
            let resultImage = try? controller.cropImage(secondRotate, rect: cropRect)
        else {
            XCTFail("Failed rotation of image")
            return
        }

        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }

    func test_GivenImage_ThenRotate3TimesLeftAndCrop_ExpectRotatedLeft3TimesAndCropedImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-3-rotate-crop", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }

        guard
            let firstRotate = try? controller.rotateLeftImage(image),
            let secondRotate = try? controller.rotateLeftImage(firstRotate),
            let thirdRotate = try? controller.rotateLeftImage(secondRotate),
            let resultImage = try? controller.cropImage(thirdRotate, rect: cropRect)
        else {
            XCTFail("Failed rotation of image")
            return
        }

        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }

    func test_GivenImage_ThenFlipHorizontalyAndCrop_ExpectFlippedCroppedImage() throws {
        let controller = ImageEditorControllerImpl(saveImageFeature: StubImageSaverFeature(), delegate: nil)
        guard
            let imagePath = try? testBundleImagePath("test-image", imageType: "jpg"),
            let image = UIImage(contentsOfFile: imagePath),
            let validationImagePath = try? testBundleImagePath("test-image-flip-crop", imageType: "png"),
            let validationImage = UIImage(contentsOfFile: validationImagePath)
        else {
            XCTFail("Sample image not available")
            return
        }

        let flippedImage = controller.flipHorizontaly(image)
        guard
            let resultImage = try? controller.cropImage(flippedImage, rect: cropRect)
        else {
            XCTFail("Failed rotation of image")
            return
        }

        XCTAssertEqual(validationImage.pngData(), resultImage.fixedOrientation().pngData())
    }
    
    private func testBundleImagePath(_ name: String, imageType: String) throws -> String {
        struct URLError: Error {}
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.path(forResource: name, ofType: imageType) else {
            throw URLError()
        }
        return url
    }
}

struct StubImageSaverFeature: ImageSaveFeature {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> ()) {}
}
