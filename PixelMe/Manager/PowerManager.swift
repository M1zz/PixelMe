//
//  PowerManager.swift
//  PixelMe
//
//  저전력 모드 감지 및 동적 품질 스케일링
//

import UIKit
import Combine

/// 배터리 상태에 따른 동적 품질 스케일링 매니저
final class PowerManager: ObservableObject {
    static let shared = PowerManager()

    @Published var isLowPowerMode: Bool = false
    @Published var batteryLevel: Float = 1.0
    @Published var qualityScale: CGFloat = 1.0

    private var cancellables = Set<AnyCancellable>()

    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateState()

        // 저전력 모드 변경 알림
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateState() }
            .store(in: &cancellables)

        // 배터리 레벨 변경 알림
        NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateState() }
            .store(in: &cancellables)
    }

    private func updateState() {
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        batteryLevel = UIDevice.current.batteryLevel

        // 동적 품질 스케일링
        if isLowPowerMode || batteryLevel < 0.1 {
            qualityScale = 0.5  // 50% 품질
        } else if batteryLevel < 0.2 {
            qualityScale = 0.75  // 75% 품질
        } else {
            qualityScale = 1.0  // 100% 품질
        }
    }

    /// 현재 품질에 맞는 최대 이미지 처리 크기
    var maxProcessingSize: CGFloat {
        return 2048 * qualityScale
    }

    /// 애니메이션 프레임 속도 제한
    var maxFPS: Int {
        if isLowPowerMode { return 15 }
        if batteryLevel < 0.2 { return 24 }
        return 60
    }

    /// 자동 저장 간격 (저전력시 더 긴 간격)
    var autoSaveInterval: TimeInterval {
        return isLowPowerMode ? 60 : 30
    }
}
