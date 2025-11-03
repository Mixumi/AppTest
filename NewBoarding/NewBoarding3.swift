//
//  NewBoarding3.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//

import SwiftUI
import FamilyControls

// MARK: - 请求屏幕使用授权
struct NewBoarding3: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int
    private let center = AuthorizationCenter.shared   //familcontrols中心

    private let currentStepIndex = 3

    @State private var isRequesting = false

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            isPrimaryButtonDisabled: isRequesting,
            onPrimaryButtonTap: requestAuthorization,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [SpaceTheme.brandPrimary.opacity(0.8), Color.purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "shield.lefthalf.fill")
                                .font(.system(size: 56, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)

                    Text("如果你想改变，请授予 LIMSTAR 屏幕使用权限。")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("我们将根据你的使用数据生成专属的守护策略。数据始终由苹果加密保护。")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                PermissionAlertView()
                    .padding(.horizontal, 12)
                    .onTapGesture {
                        requestAuthorization()
                    }

                Text("您的使用信息将100%被苹果保护，不会被泄露。")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: 560)
        }
    }

    private func requestAuthorization() {
        guard !isRequesting else { return }
        feedbackGenerator.impactOccurred()
        isRequesting = true
        Task {
            defer { isRequesting = false }
            do {
                try await center.requestAuthorization(for: FamilyControlsMember.individual)
                proceedToNext()
            } catch {
                proceedToNext()
            }
        }
    }

    private func proceedToNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            step += 1
        }
    }

    private func skipToFinal() {
        withAnimation {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

#Preview {
    NewBoarding3(step: .constant(0))
}

struct PermissionAlertView: View {
    let appName: String = NSLocalizedString("LIMSTAR", comment: "")
    var body: some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0)
                .ignoresSafeArea()
            // 弹窗主体
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        // 标题
                        Text("“\(appName)” 想要访问屏幕使用时间")
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.center)
                        // 说明
                        Text("允许 “\(appName)” 访问屏幕使用时间可能会允许其查看你的活动数据、受限内容，并限制 App 和 网站使用。")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.secondary)
                    // 底部按钮
                    HStack(spacing: 0) {
                        Text("继续")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.blue)
                        Rectangle()
                            .frame(width : 1 , height: 44)
                            .foregroundColor(Color.secondary)

                        Text("不允许")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.blue)
                    }
                    .frame(height: 44)
                }
                .frame(width: 270)
                .background(SpaceTheme.cardBackgroundPrimary)
                .padding(.all , 16)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(SpaceTheme.brandPrimary.opacity(0.6), lineWidth: 2)
                )
            }
            // 箭头
            CurvedArrow()
                .stroke(SpaceTheme.brandPrimary, lineWidth: 3)
                .rotationEffect(.degrees(220))                     // 微调角度
                .frame(width: 100, height: 100)    // 箭头的“画布”大小
                .offset(x: -30, y: 120)             // 移动到“继续”按钮正下方
        }
    }
}

struct CurvedArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 1. 主干：从左下点弯曲到右上点
        let start = CGPoint(x: rect.minX + 40, y: rect.maxY - 100)
        let control = CGPoint(x: rect.midX, y: rect.minY)
        let end = CGPoint(x: rect.maxX, y: rect.midY)
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)

        // 2. 箭头头：在 end 点画两条短线
        let arrowHeadSize: CGFloat = 10
        let angle1 = atan2(end.y - control.y, end.x - control.x) + .pi / 6
        let angle2 = atan2(end.y - control.y, end.x - control.x) - .pi / 6

        let p1 = CGPoint(x: end.x - cos(angle1) * arrowHeadSize,
                         y: end.y - sin(angle1) * arrowHeadSize)
        let p2 = CGPoint(x: end.x - cos(angle2) * arrowHeadSize,
                         y: end.y - sin(angle2) * arrowHeadSize)

        path.move(to: end)
        path.addLine(to: p1)
        path.move(to: end)
        path.addLine(to: p2)

        return path
    }
}
