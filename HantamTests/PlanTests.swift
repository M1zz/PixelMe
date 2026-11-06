//
//  PlanTests.swift
//  HantamTests
//
//  무료 · Plus · Pro: 상품마다 여는 칸, 기능마다 필요한 칸, Hantam.storekit 과 상품 ID 의 약속.
//

import XCTest
@testable import Hantam

final class PlanTests: XCTestCase {

    func testTierOfOwnedProducts() {
        XCTAssertEqual(HantamPlan.tier(owning: []), .free)
        XCTAssertEqual(HantamPlan.tier(owning: [AppConfig.plusYearlyProductID]), .plus)
        XCTAssertEqual(HantamPlan.tier(owning: [AppConfig.plusLifetimeProductID, AppConfig.proUpgradeProductID]), .pro)
        // 2.1.x 에 팔던 상품 · 판매를 멈춘 예전 상품은 그대로 Pro.
        for id in [AppConfig.monthlyProductID, AppConfig.yearlyProductID, AppConfig.lifetimeProductID,
                   AppConfig.legacyWeeklyProductID, AppConfig.legacyMonthlyProductID,
                   AppConfig.legacyYearlyProductID, AppConfig.premiumVersion] {
            XCTAssertEqual(HantamPlan.tier(owning: [id]), .pro, id)
        }
    }

    func testTipsAndGiftDoNotUnlock() {
        let notEntitlements = AppConfig.tipProductIDs + [AppConfig.giftProductID]
        XCTAssertTrue(HantamPlan.entitlementIDs.isDisjoint(with: notEntitlements))
        XCTAssertEqual(HantamPlan.tier(owning: Set(notEntitlements)), .free)
    }

    func testFeatureTiers() {
        XCTAssertEqual(Set(HantamFeature.opened(by: .plus)), [.biggerPatterns, .keepPatterns, .cleanImage, .pixelTools])
        XCTAssertEqual(Set(HantamFeature.opened(by: .pro)), [.printablePDF, .cleanVideo, .filterPacks])
        XCTAssertTrue(HantamFeature.opened(by: .free).isEmpty)
    }

    func testSoldProductsAreEntitlements() {
        XCTAssertTrue(Set(HantamPlan.productIDs).isSubset(of: HantamPlan.entitlementIDs))
        XCTAssertEqual(HantamPlan.productIDs.count, 10)
        XCTAssertEqual(HantamPlan.subscriptionIDs.count, 6)
    }

    /// Hantam.storekit 은 App Store Connect 상품을 만드는 원본이다 — 앱이 파는 것과 하나도 어긋나면 안 된다.
    func testStoreKitConfigurationMatches() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Hantam/Hantam.storekit")
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let products = json["products"] as? [[String: Any]] ?? []
        let groups = json["subscriptionGroups"] as? [[String: Any]] ?? []
        XCTAssertEqual(groups.count, 1, "Plus 와 Pro 구독은 한 그룹")
        let subs = groups.flatMap { $0["subscriptions"] as? [[String: Any]] ?? [] }

        let ids = Set((products + subs).compactMap { $0["productID"] as? String })
        XCTAssertEqual(ids, Set(HantamPlan.productIDs))
        XCTAssertEqual(Set(subs.compactMap { $0["productID"] as? String }), HantamPlan.subscriptionIDs)

        for sub in subs {
            let id = sub["productID"] as! String
            let level = sub["groupNumber"] as? Int
            XCTAssertEqual(level, HantamPlan.tierByProduct[id] == .pro ? 1 : 2, "Pro 가 위 단계: \(id)")
        }
        for item in products + subs {
            let ref = item["referenceName"] as? String ?? ""
            XCTAssertTrue(ref.allSatisfy(\.isASCII), ref)
            for loc in item["localizations"] as? [[String: Any]] ?? [] {
                XCTAssertLessThanOrEqual((loc["displayName"] as? String ?? "").count, 30)
                XCTAssertLessThanOrEqual((loc["description"] as? String ?? "").count, 45)
            }
        }
    }
}
