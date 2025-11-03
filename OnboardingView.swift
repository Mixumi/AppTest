//
//  OnboardingView.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/5/2.
//

import SwiftUI

/// MARK: - 引导页
/// 全新引导体验：通过四个章节式的旅程，帮助用户逐步了解产品能力、建立使用期待并完成必要的权限设置。
struct OnboardingView: View {
    @State private var step: Int = 0

    var body: some View {
        switch step {
        case 0:
            SpaceWelcomeStep(step: $step)
        case 1:
            SpaceMissionOverviewStep(step: $step)
        case 2:
            SpaceFocusToolkitStep(step: $step)
        default:
            SpacePermissionWarmupStep(step: $step)
        }
    }
}

#Preview {
    OnboardingView()
}

/**
 - 限制应用 OK
 - 正向应用 OK
 - 运动数据 OK
 - 专注数据 OK
 - 挑战兑换 OK
 */
