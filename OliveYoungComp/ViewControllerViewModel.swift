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

    func addSuffixToMainBanner(_ url: URL) -> URL {
        var modifiedURLString = url.absoluteString
        if url.absoluteString.contains("getPlanShopDetail") {
            if !modifiedURLString.hasSuffix("&oy=0") {
                modifiedURLString += "&oy=0"
            }
        }
        
        return URL(string: modifiedURLString) ?? url
    }
}
