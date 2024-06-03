import Foundation

class ViewControllerViewModel {
    func shouldBlockURL(_ url: URL) -> Bool {
        let blockedURLs = [
            "about:blank",
            "https://www.youtube.com/",
            "https://gum.criteo.com/",
            "https://player.vimeo.com/",
            "https://play.grip.show/",
            "https://grip-8c4ce.firebaseapp.com/",
            "https://livegrip.oliveyoung.co.kr/",
            "https://m.oliveyoung.co.kr/m/live/",
            "https://cf-images.oliveyoung.co.kr/",
            "https://image.oliveyoung.co.kr/",
            "https://*.avkit.apple.com/"
        ]
        
        return blockedURLs.contains { url.absoluteString.contains($0) }
    }

    func shouldRefreshURL(_ url: URL) -> Bool {
//        if url.absoluteString.contains("https://m.oliveyoung.co.kr/m/cart") { return true }
//        if url.absoluteString.contains("https://m.oliveyoung.co.kr/m/mtn/search?") { return true }
        if url.absoluteString.contains("https://m.oliveyoung.co.kr/m/mtn?menu=home") { return true }
        
        let refreshURLs: [String] = [
            "https://m.oliveyoung.co.kr/m/mtn",
            "https://m.oliveyoung.co.kr/m/mtn/shutter?t_page=%EC%85%94%ED%84%B0&t_click=%ED%99%88_%ED%83%AD%EB%B0%94_%EC%85%94%ED%84%B0",
            "https://m.oliveyoung.co.kr/m/mtn/history?tab=recent",
            "https://m.oliveyoung.co.kr/m/mypage/myPageMain.do",
            "https://m.oliveyoung.co.kr/m/login/loginForm.do",
            "https://m.oliveyoung.co.kr/m/login/login.do",
            "https://m.oliveyoung.co.kr/m/mtn/history",
//            "https://m.oliveyoung.co.kr/m/mtn/setting?t_page=%EB%A7%88%EC%9D%B4%ED%8E%98%EC%9D%B4%EC%A7%80&t_click=%EC%84%A4%EC%A0%95"
        ]
        return refreshURLs.contains(url.absoluteString)
    }
}
