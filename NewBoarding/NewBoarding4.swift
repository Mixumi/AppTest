//
//  NewBoarding4.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//

import SwiftUI

// MARK: - 请求通知权限
struct NewBoarding4: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int

    private let currentStepIndex = 4

    @State private var isRequesting = false

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            isPrimaryButtonDisabled: isRequesting,
            onPrimaryButtonTap: requestPermission,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.8), SpaceTheme.brandPrimary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "bell.badge.waveform.fill")
                                .font(.system(size: 56, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 12)

                    Text("LIMSTAR 会在合适的时机提醒你查看屏幕使用情况。")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("这些通知帮助你及时了解自己的使用状态，并给出下一步建议。")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                NotificationPermissionAlertView()
                    .padding(.horizontal, 12)
                    .onTapGesture {
                        requestPermission()
                    }
            }
            .frame(maxWidth: 560)
        }
    }

    private func requestPermission() {
        guard !isRequesting else { return }
        feedbackGenerator.impactOccurred()
        isRequesting = true
        Task {
            defer { isRequesting = false }
            do {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                if settings.authorizationStatus == .notDetermined {
                    _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                }
                step += 1
            } catch {
                step += 1
            }
        }
    }

    private func skipToFinal() {
        withAnimation {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

#Preview {
    NewBoarding4(step: .constant(0))
}

struct NotificationPermissionAlertView: View {
    let appName: String = NSLocalizedString("LIMSTAR", comment: "")
    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("“\(appName)” 想给你发送通知")
                        .font(.system(size: 20, weight: .semibold))
                        .multilineTextAlignment(.center)
                    Text("通知可能包括提醒、声音和图标标记。这些可以在“设置”中配置。")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.secondary)

                HStack(spacing: 0) {
                    Text("不允许")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.blue)
                    Rectangle()
                        .frame(width : 1 , height: 44)
                        .foregroundColor(Color.secondary)
                    Text("允许")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.blue)
                }
                .frame(height: 44)
            }
            .frame(width: 270)
            .background(SpaceTheme.cardBackgroundPrimary)
            .padding(16)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(SpaceTheme.brandPrimary.opacity(0.6), lineWidth: 2)
            )
        }
    }
}
