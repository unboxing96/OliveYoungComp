//
//  OliveYoungCompUITests.swift
//  OliveYoungCompUITests
//
//  Created by 김태현 on 6/11/24.
//

import XCTest

final class OliveYoungCompUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 20), "웹뷰가 존재하지 않습니다.")
        
        let dailyPopUpButton = webView.buttons["오늘 하루 보지 않기"]
        if dailyPopUpButton.exists {
            dailyPopUpButton.tap()
        }

        // '오특' 텍스트를 가진 버튼 찾기
        let todaySpecialButton = webView.buttons["오특"]
        XCTAssertTrue(todaySpecialButton.waitForExistence(timeout: 20), "오특 버튼이 존재하지 않습니다.")
        
        // 버튼 클릭
        todaySpecialButton.tap()

        // 새 페이지 로드 대기
        let newWebView = app.webViews.firstMatch
        XCTAssertTrue(newWebView.waitForExistence(timeout: 20), "새 페이지의 웹뷰가 존재하지 않습니다.")

        // 좌표값으로 tap
        let coordinate = newWebView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.tap()
                
        // 새 페이지 로드 대기
        let newNewWebView = app.webViews.firstMatch
        XCTAssertTrue(newNewWebView.waitForExistence(timeout: 20), "새 페이지의 웹뷰가 존재하지 않습니다.")
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
