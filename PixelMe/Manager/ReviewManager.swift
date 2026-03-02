//
//  ReviewManager.swift
//  PixelMe
//
//  인앱 리뷰 유도 시스템 (적절한 타이밍 트리거)
//

import StoreKit
import UIKit

/// 앱 리뷰 요청 타이밍을 관리하는 매니저
class ReviewManager {

    static let shared = ReviewManager()

    // MARK: - UserDefaults Keys

    private let completedActionsKey = "ReviewManager.completedActions"
    private let lastReviewRequestKey = "ReviewManager.lastReviewRequest"
    private let reviewRequestCountKey = "ReviewManager.reviewRequestCount"
    private let appLaunchCountKey = "ReviewManager.appLaunchCount"

    // MARK: - Thresholds

    /// 리뷰 요청을 위한 최소 완료 액션 수
    private let minActionsForReview = 3
    /// 리뷰 요청 간 최소 간격 (일)
    private let minDaysBetweenRequests = 30
    /// 최대 리뷰 요청 횟수 (연간)
    private let maxRequestsPerYear = 3

    private init() {}

    // MARK: - Track Events

    /// 앱 실행 시 호출
    func trackAppLaunch() {
        let count = UserDefaults.standard.integer(forKey: appLaunchCountKey) + 1
        UserDefaults.standard.set(count, forKey: appLaunchCountKey)
    }

    /// 의미 있는 사용자 액션 완료 시 호출
    /// - 이미지 변환 완료, 내보내기/저장, 공유 등 만족 순간에 호출
    func trackCompletedAction() {
        let count = UserDefaults.standard.integer(forKey: completedActionsKey) + 1
        UserDefaults.standard.set(count, forKey: completedActionsKey)
        requestReviewIfAppropriate()
    }

    // MARK: - Review Request Logic

    /// 조건을 만족하면 리뷰 요청
    private func requestReviewIfAppropriate() {
        let completedActions = UserDefaults.standard.integer(forKey: completedActionsKey)
        let requestCount = UserDefaults.standard.integer(forKey: reviewRequestCountKey)
        let appLaunches = UserDefaults.standard.integer(forKey: appLaunchCountKey)

        // 조건 1: 최소 액션 수 충족
        guard completedActions >= minActionsForReview else { return }

        // 조건 2: 최소 앱 실행 2회 이상
        guard appLaunches >= 2 else { return }

        // 조건 3: 연간 최대 요청 횟수 초과하지 않음
        guard requestCount < maxRequestsPerYear else { return }

        // 조건 4: 마지막 요청 후 충분한 시간 경과
        if let lastRequest = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
            guard daysSinceLastRequest >= minDaysBetweenRequests else { return }
        }

        // 모든 조건 충족 → 리뷰 요청
        requestReview()
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }

        SKStoreReviewController.requestReview(in: scene)

        // 요청 기록 업데이트
        UserDefaults.standard.set(Date(), forKey: lastReviewRequestKey)
        let newCount = UserDefaults.standard.integer(forKey: reviewRequestCountKey) + 1
        UserDefaults.standard.set(newCount, forKey: reviewRequestCountKey)

        // 액션 카운터 리셋 (다음 리뷰까지 다시 카운트)
        UserDefaults.standard.set(0, forKey: completedActionsKey)
    }
}
