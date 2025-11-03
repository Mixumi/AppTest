//
//  NewBoarding8.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//

import SwiftUI

struct NewBoarding8: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int

    private let currentStepIndex = 8

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // MARK: — 动画状态
    @State private var showHeadline = false
    @State private var showBody = false

    @State private var isLoading = false

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            showsSkip: false,
            showsPrimaryButton: !isLoading,
            primaryButtonTitle: "开始探索",
            primaryButtonIcon: "sparkles",
            isPrimaryButtonDisabled: isLoading,
            onPrimaryButtonTap: startExperience,
            skipAction: nil
        ) {
            Group {
                if isLoading {
                    progressView
                } else {
                    mainView
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isLoading)
            .frame(maxWidth: 620)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showBody = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showHeadline = true
                }
            }
        }
    }

    private var progressView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 46, weight: .thin, design: .rounded))
                .foregroundStyle(SpaceTheme.textPrimary)

            Text("系统启动中")
                .font(.system(size: 18, weight: .ultraLight, design: .monospaced))
                .foregroundStyle(SpaceTheme.textPrimary)

            AnimatedGradientProgressBar {}
                .frame(height: 4)
        }
        .padding(.vertical, 80)
    }

    private var mainView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("此外，你还可以通过步行、正念、专注或完成系统任务来获取星币，以换取使用时间。")
                    .font(.system(size: 18, weight: .light, design: .monospaced))
                    .foregroundStyle(SpaceTheme.textPrimary)
                    .lineSpacing(12)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showBody ? 1 : 0)
                    .offset(y: showBody ? 0 : 20)

                Text("准备好进入 LIMSTAR，开启一年改变之旅了么？")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.blue, Color.green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .opacity(showHeadline ? 1 : 0)
                    .offset(y: showHeadline ? 0 : 20)
            }

            Image(systemName: "planet.fill")
                .font(.system(size: 100, weight: .ultraLight, design: .rounded))
                .foregroundStyle(SpaceTheme.textSecondary)
                .opacity(showHeadline ? 1 : 0.6)
        }
    }

    private func startExperience() {
        guard !isLoading else { return }
        feedbackGenerator.impactOccurred()
        isLoading = true

        Task {
            // —— 后面不管成功失败都要收尾：进入引导 + 复位 loading
            defer {
                Task { @MainActor in
                    hasSeenOnboarding = true
                    isLoading = false
                }
            }

            let dangerOK = DeviceMonitorService.shared.startDangerMonitoring()
            guard dangerOK else { return }
            try? await Task.sleep(for: .seconds(2))

            let positiveOK = DeviceMonitorService.shared.startPositiveMonitoring()
            if !positiveOK {
                DeviceMonitorService.shared.stopMonitoring(named: "dangerplanetsmonitor")
                return
            }

            try? await Task.sleep(for: .seconds(5))
        }
    }
}

#Preview {
    NewBoarding8(step: .constant(0))
}
