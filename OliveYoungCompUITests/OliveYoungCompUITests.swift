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

    func testScenarioFirst() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let webView = app.webViews.firstMatch
        
        // 새 페이지 로드 대기
        XCTAssertTrue(webView.waitForExistence(timeout: 20), "웹뷰가 존재하지 않습니다.")
        
        // 팝업창 제거
        let dailyPopUpButton = webView.buttons["오늘 하루 보지 않기"]
        if dailyPopUpButton.exists {
            dailyPopUpButton.tap()
        }
        
        scrollToElement(in: webView, targetText: "카테고리 랭킹")
        doShortScroll(in: webView)
        waitForNewPage(in: webView)
        
        tapButtonByText(in: webView, text: "클렌징")
        
        tapCoordinateByRelative(in: webView, x: 0.5, y: 0.3)
        waitForNewPage(in: webView)
            
        goBack(in: app)
        waitForNewPage(in: webView)
        
        tapCoordinateByRelative(in: webView, x: 0.5, y: 0.5)
        waitForNewPage(in: webView)
            
        goBack(in: app)
        waitForNewPage(in: webView)
        
        tapCoordinateByRelative(in: webView, x: 0.5, y: 0.7)
        waitForNewPage(in: webView)
            
        goBack(in: app)
        waitForNewPage(in: webView)
    }
    
    func testScenarioSecond() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let webView = app.webViews.firstMatch
        
        // 새 페이지 로드 대기
        XCTAssertTrue(webView.waitForExistence(timeout: 20), "웹뷰가 존재하지 않습니다.")
        
        // 팝업창 제거
        let dailyPopUpButton = webView.buttons["오늘 하루 보지 않기"]
        if dailyPopUpButton.exists {
            dailyPopUpButton.tap()
        }
        
        // Shutter로 이동
        tapCoordinateByRelative(in: app, x: 0.5, y: 0.95)
        waitForNewPage(in: webView)

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

extension XCTestCase {
    func tapCoordinateByAbsolute(in context: XCUIElement, x: CGFloat, y: CGFloat) {
        let normalizedX = x / context.frame.width
        let normalizedY = y / context.frame.height
        let coordinate = context.coordinate(withNormalizedOffset: CGVector(dx: normalizedX, dy: normalizedY))
        coordinate.tap()
    }
    
    func tapCoordinateByRelative(in context: XCUIElement, x: CGFloat, y: CGFloat) {
        let coordinate = context.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
        coordinate.tap()
    }
    
    func scrollToElement(in context: XCUIElement, targetText: String) {
        let elementToScrollTo = context.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", targetText)).firstMatch

        // 스크롤하여 요소가 보이게 하기
        let maxScrolls = 10
        var count = 0
        
        while !elementToScrollTo.exists && count < maxScrolls {
            print("count: \(count)")
            context.swipeUp()
            count += 1
        }
    }
    
    func doShortScroll(in context: XCUIElement) {
        // 스크롤 길이를 더 세밀하게 조절
        let smallStartCoordinate = context.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let smallEndCoordinate = context.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4))
        smallStartCoordinate.press(forDuration: 0.1, thenDragTo: smallEndCoordinate)
    }    
    
    func doLongScroll(in context: XCUIElement) {
        // 스크롤 길이를 더 세밀하게 조절
        let smallStartCoordinate = context.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let smallEndCoordinate = context.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        smallStartCoordinate.press(forDuration: 0.1, thenDragTo: smallEndCoordinate)
    }
    
    func tapButtonByText(in context: XCUIElement, text: String) {
        context.buttons[text].tap()
    }
    
    func waitForNewPage(in context: XCUIElement) {
        XCTAssertTrue(context.waitForExistence(timeout: 20), "웹뷰가 존재하지 않습니다.")
    }
    
    func goBack(in context: XCUIApplication) {
        context.navigationBars.buttons.element(boundBy: 0).tap()
    }
}

//        // '오특' 텍스트를 가진 버튼 찾기
//        let todaySpecialButton = webView.buttons["오특"]
//        XCTAssertTrue(todaySpecialButton.waitForExistence(timeout: 20), "오특 버튼이 존재하지 않습니다.")
//        todaySpecialButton.tap()

//// '오특' 텍스트를 가진 버튼 찾기 + 클릭
//tapCoordinate(in: webView, x: 49, y: 48)
//
//// 새 페이지 로드 대기 + 제품1 찾기 + 클릭
//XCTAssertTrue(webView.waitForExistence(timeout: 20), "새 페이지의 웹뷰가 존재하지 않습니다.")
//let coordinate = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
//coordinate.tap()
//        
//// 새 페이지 로드 대기
//XCTAssertTrue(webView.waitForExistence(timeout: 20), "새 페이지의 웹뷰가 존재하지 않습니다.")
