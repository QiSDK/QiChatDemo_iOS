//
//  BWLinkDetector.swift
//  TeneasyChatSDKUI_iOS
//
//  Detects URLs, emails, and phone numbers in text and produces
//  attributed strings with tappable .link attributes.
//

import UIKit

enum BWLinkDetector {
    struct Link {
        let range: NSRange
        let url: URL
    }

    private static let detector: NSDataDetector? = {
        let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        return try? NSDataDetector(types: types.rawValue)
    }()

    static func detect(in text: String) -> [Link] {
        guard let detector = detector, !text.isEmpty else { return [] }
        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        var results: [Link] = []
        detector.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match = match else { return }
            if match.resultType == .phoneNumber, let phone = match.phoneNumber {
                let allowed = CharacterSet(charactersIn: "+0123456789")
                let normalized = String(phone.unicodeScalars.filter { allowed.contains($0) })
                if !normalized.isEmpty, let url = URL(string: "tel:\(normalized)") {
                    results.append(Link(range: match.range, url: url))
                }
            } else if let url = match.url {
                results.append(Link(range: match.range, url: url))
            }
        }
        return results
    }

    static func makeAttributedString(
        from text: String,
        font: UIFont,
        textColor: UIColor,
        linkColor: UIColor,
        underlineLinks: Bool = true
    ) -> (attributed: NSMutableAttributedString, links: [Link]) {
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: textColor]
        )
        let links = detect(in: text)
        for link in links {
            var attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: linkColor,
                .link: link.url
            ]
            if underlineLinks {
                attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            attributed.addAttributes(attrs, range: link.range)
        }
        return (attributed, links)
    }

    @discardableResult
    static func applyLinks(
        to attributed: NSMutableAttributedString,
        linkColor: UIColor,
        underlineLinks: Bool = true
    ) -> [Link] {
        let links = detect(in: attributed.string)
        for link in links {
            var hasExistingLink = false
            attributed.enumerateAttribute(.link, in: link.range, options: []) { value, _, stop in
                if value != nil {
                    hasExistingLink = true
                    stop.pointee = true
                }
            }
            if hasExistingLink { continue }

            attributed.addAttribute(.link, value: link.url, range: link.range)
            attributed.addAttribute(.foregroundColor, value: linkColor, range: link.range)
            if underlineLinks {
                attributed.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: link.range
                )
            }
        }
        return links
    }
}
