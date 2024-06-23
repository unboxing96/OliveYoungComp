# 올리브영 앱 개선 프로젝트
|현재 올영 앱|개선된 앱|
|---|---|
|![download (2)](https://github.com/unboxing96/OliveYoungComp/assets/102353544/27903353-86fd-4a65-a07b-403762663707)|![download (3)](https://github.com/unboxing96/OliveYoungComp/assets/102353544/6bce63e3-a2b0-4269-8a2d-c24b667b3535)|


</br>

### 🫒 올리브영 앱에 계층적 네비게이션 적용하기
평소처럼 올리브영 앱을 사용하다가 문득 불편함을 느꼈습니다. </br>
올리브영 앱의 콘텐츠 부분은 `웹뷰`로 제작되어, 뷰를 이동할 때마다 `새로운 페이지를 로드`하는 방식으로 동작합니다.
이 과정에서 선택했던 옵션 혹은 탐색 중이던 스크롤 위치를 잃기도 합니다.
여기에 `UINavigationController`를 적용하여 사용성을 개선하고, 네트워크 요청량을 줄이고자 했습니다.

</br>

### 📝 상세 보고서
https://gowild.tistory.com/73


</br>

### 📆 개발 기간
2024.05.13 ~ 2024.06.12

</br>

## 1. Development Environment ⚙️
`iOS 17.0` `Xcode 15.0`

</br>

## 2. Tech Stack ⚒️
- 언어: `Swift`
- 웹뷰: `WKWebView`
- 네비게이션: `UINavigationController`
- 웹 ↔ 앱 통신: `WKNavigationDelegate`, `WKUserContentController`, `WKScriptMessage`
- UI 테스트: `XCTest`

</br>

## 3. 기능 요약
### `모든 페이지를 UINavigationController로 관리`
|현재 올영 앱|개선된 앱|
|---|---|
|![oriStackCrop](https://github.com/unboxing96/OliveYoungComp/assets/102353544/b7da3f0b-c5df-411b-800b-da9e2c4b73f0)|![compStackCropLow](https://github.com/unboxing96/OliveYoungComp/assets/102353544/e31dd35e-d5fd-47a8-ac8e-b467b19d5557)|



#### `문제 상황`
- 웹뷰에서 뒤로가기를 실행할 때, 이전 페이지의 위치 / 입력값 / 선택한 옵션 등의 데이터를 잃는 문제.

#### `해결 방법`
- **MPA**
  - `WKNavigationDelegate`
- **SPA**
  - `messageHandler` 중심으로 웹 ↔ 앱 통신.
  - 올리브영의 경우 `Next.js를 사용하여 SPA처럼 렌더링 되는 페이지`가 문제.
  - `window.next`로 네비게이션 이동 방지 및 목적지 URL 획득.

#### `배운 점`
- **웹 ↔ 앱 통신 방식을 이해**
    - **웹 → 앱**
        1. 웹의 자바스크립트에 삽입된 `window.webkit.messageHandlers` 메서드를 호출하면, 앱으로 메시지를 보낸다.
        2. 앱의 `WKScriptMessageHandler`를 구현하여 `userContentController` 메서드에서 `WKScriptMessage` 타입의 메시지를 수신 후, 이름에 따라 처리한다
    - **앱 → 웹**
        - 앱에서 작성한 JavaScript 코드를 웹에서 실행한다.
            - `WKUserScript`: 웹 페이지 로드 시점에 자동으로 실행된다.
            - `evaluateJavascript`: 로드된 이후 특정 시점에 즉시 실행한다.
    - **웹 → 앱 → 웹**
        1. **`Promise`** 객체를 활용하면 된다.
        2. 웹에서 `Promise` 객체를 반환하는 함수를 실행한다. 함수 내부의 `webkit.messageHandlers`가 앱으로 메시지를 전송한다.
        3. 앱의 `WKScriptMessageHandler`가 메시지를 수신 후, `userContentController` 메서드에서 메시지의 이름에 따라 처리한다.
        4. 메시지 처리 후, 결과를 포함한 JS 코드를 `evaluateJavaScript` 메서드를 통해 다시 웹으로 전송한다.
        5. 웹은 앱에서 온 응답을 받아 `Promise` 객체를 resolve하거나 reject한다.
</br>

- **웹의 렌더링 방식을 이해**
    - CSR / SSR / SSG
    - SPA / MPA
    - Next.js

#### `개선한 점`

- **(특정 시나리오에서) 네트워크 요청량 32.4% 감소시킴**
    - 자동화된 UI Test
    - WKWebView 환경에서 UI Test가 제한되는 문제 → `XCUIElement`와 `Coordinate`로 해결


| 항목                     | 기준(Ori) 총합 | 개선(Comp) 총합 | 개선 퍼센티지 평균 |
|-------------------------|----------------|-----------------|------------------|
| **Protocols**           | HTTP/1.1       | HTTP/1.1        | -                |
| **Requests Completed**  | 138            | 101             | -26.81%          |
| **DNS**                 | 25             | 19              | -24.00%          |
| **Connects**            | 139            | 150             | 7.91%            |
| **TLS Handshakes**      | 136            | 133             | -2.21%           |
| **DNS Time**            | 436ms          | 229ms           | -47.48%          |
| **Connect Time**        | 6.23s          | 6.31s           | 1.29%            |
| **TLS Handshake Time**  | 14.87s         | 12.37s          | -16.82%          |
| **Latency**             | 0ms            | 0ms             | 0.00%            |
| **Speed**               | 406.88 KB/s    | 369.92 KB/s     | -9.09%           |
| **Request Size**        | 3,882.84 KB    | 2,531.58 KB     | -34.79%          |
| **Response Size**       | 16.89 MB       | 11.58 MB        | -31.40%          |
| **Combined Size**       | 20.76 MB       | 14.03 MB        | -32.42%          |

#### `추가`
- **24.06.20 일자로 올리브영 앱에 해당 문제를 개선한 업데이트가 반영됨**
  

</br>

### `하단 탭 바의 각 탭을 별개의 UINavigationController로 관리`
|현재 올영 앱|개선된 앱|
|---|---|
|![oriTabBarCropLow](https://github.com/unboxing96/OliveYoungComp/assets/102353544/7786d970-eb85-432a-878b-70ce75ed8cca)|![compTabBarCropLow](https://github.com/unboxing96/OliveYoungComp/assets/102353544/b8270897-c760-4ba4-bd80-a059728ee92c)|


#### `문제 상황`
- 올리브영 앱은 각 탭이 하나의 페이지로 취급되어 히스토리 스택([WKBackForwardList](https://developer.apple.com/documentation/webkit/wkbackforwardlist)로 추정)에 쌓임
  - 히스토리 스택에 너무 많은 페이지(+탭)이 쌓인다.
  - 탭 간을 오가며 정보를 탐색하는 행위가 불가능하다.
#### `해결 방법`
- SceneDelegate에서 각 탭이 각각의 UINavigationController를 갖도록 설정
#### `개선된 점`
- 사용자가 탭을 오가며 정보를 탐색할 때, 탭 별로 데이터를 저장하고 있음.
- 탭 이동이 히스토리 스택에 쌓이지 않음 → 메모리 개선


</br>

## 4. Folder Structure

```
├── OliveYoungComp
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── AppState.swift
│   ├── GenericViewController.swift
│   └── ViewControllerViewModel.swift
├── OliveYoungComp.xcodeproj
│   └── project.xcworkspace
├── OliveYoungCompTests
│   └── OliveYoungCompTests.swift
└── OliveYoungCompUITests
    ├── OliveYoungCompUITests.swift
    └── OliveYoungCompUITestsLaunchTests.swift
```


</br>
</br>

# 팀 개발자들을 위한 Git, Code Convention

## 네이밍
- 이슈</br>
  `이슈 핵심 내용`</br>
  `구글 로그인 구현`</br>

- 브랜치</br>
  `브랜치 종류/이슈 번호-개발할 기능 이름`</br>
  `feat/1-login-view`</br>
  
- 커밋</br>
  `(종류 이모지)[이슈 번호] 이슈 핵심 내용`</br>
  `:bug:[#11][#12] 구글 로그인 탈퇴시 발생하는 버그 해결`</br>
  
- PR</br>
  `(종류 이모지)[이슈 번호] 커밋 내용`</br>
  `:zap:[#1] 로그인 화면 개발`</br>

## 브랜치, 커밋 종류
|           종류              | 이모지                                          |       설명               |
|:---------------------------|:----------------------------------------------|:------------------------|
| initial                    | :tada: `:tada:`                               | 초기 설정                 |
| refactor                   | :recycle: `:recycle:`                         | 파일·타입 이름 변경, 파일 분리 |
| bug                        | :bug: `:bug:`                                 | 버그                     |
| feat                       | :zap: `:zap:`                                 | 기능                     |
| gui                        | :art: `:art:`                                 | View                    |
| chore                      | :broom: `:broom:`                             | SPM, 세팅, 빌드 등         |
| delete                     | :wastebasket: `:wastebasket:`                 | 파일 삭제                 |
| docs                       | :books: `:books:`                             | 코드 외 문서               |
| asset                      | :heart: `:heart:`                             | 에셋                     |
| comment                    | :memo: `:memo:`                               | 주석                     |
