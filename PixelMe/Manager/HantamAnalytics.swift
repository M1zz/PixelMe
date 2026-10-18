//
//  HantamAnalytics.swift
//  Hantam
//
//  FeedbackHub 로 보내는 익명 사용 통계 싱크.
//  LeeoUsageAnalytics 는 이벤트 이름만 보내고 파라미터를 버리므로, 여기서 파라미터를
//  이름 뒤에 붙여(`purchase_completed.com.pixelme.pro.lifetime`) 허브에서 갈래를 볼 수 있게 한다.
//

import Foundation
import LeeoKit

struct HantamAnalytics: LeeoAnalytics {
    private let reporter: LeeoUsageReporter

    init<Spec: LeeoAppSpec>(spec: Spec.Type) {
        reporter = LeeoUsageReporter(spec: spec)
    }

    func track(_ event: LeeoEvent) {
        reporter.logEventInBackground(Self.flatName(event))
    }

    /// 파라미터 값을 키 이름순으로 이름 뒤에 붙인다. 값이 없으면 이름 그대로.
    static func flatName(_ event: LeeoEvent) -> String {
        let values = event.parameters.sorted { $0.key < $1.key }.map(\.value).filter { !$0.isEmpty }
        return ([event.name] + values).joined(separator: ".")
    }
}

/// 앱 코드에서 이벤트를 보내는 창구 (LeeoKit 컴포넌트와 같은 싱크를 쓴다).
enum LeeoAnalyticsBridge {
    static func track(_ name: String) {
        LeeoAnalyticsCenter.track(.custom(name: name, parameters: [:]))
    }
}
