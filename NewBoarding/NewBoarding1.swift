//
//  NewBoarding1.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/9.
//

import SwiftUI

// MARK: - 提示为什么要减少手机的使用，给出美好的愿景
struct NewBoarding1: View {

    @Environment(\.colorScheme) private var colorScheme
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @AppStorage("locationUserName") private var name: String = ""
    @Binding var step: Int

    private let currentStepIndex = 1

    // MARK: — 动画状态
    @State private var showHeadline = false
    @State private var showBody = false
    @State private var showCat = false
    @State private var showButton = false

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            showsPrimaryButton: showButton,
            onPrimaryButtonTap: goNext,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.8),
                                    SpaceTheme.brandPrimary.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "timer")
                                .font(.system(size: 56, weight: .thin, design: .rounded))
                                .foregroundStyle(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 12)
                        .opacity(showHeadline ? 1 : 0)
                        .scaleEffect(showHeadline ? 1 : 0.7)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: showHeadline)

                    Text("舰长\(name)，你知道么？每天仅需减少30分钟手机使用时间，您的生活将会发生翻天覆地的变化。")
                        .font(.system(size: 18, weight: .light, design: .monospaced))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .lineSpacing(12)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(showBody ? 1 : 0)
                        .offset(y: showBody ? 0 : 20)
                }

                Spacer()

                VStack(spacing: 12) {
                    Text("-30")
                        .font(.system(size: 84, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(showHeadline ? 1 : 0)
                        .offset(y: showHeadline ? 0 : 32)

                    Text("分钟")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .opacity(showHeadline ? 1 : 0)
                        .offset(y: showHeadline ? 0 : 32)
                }

                Spacer()

                HStack {
                    Image("left-bottom-cat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .stroke(color: .white, width: 1.2)
                        .opacity(showCat ? 1 : 0)
                        .offset(x: -8, y: showCat ? 0 : 24)
                    Spacer()
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showBody = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.6)) {
                    showHeadline = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.6)) {
                    showCat = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeOut(duration: 0.6)) {
                    showButton = true
                }
            }
        }
    }

    private func goNext() {
        feedbackGenerator.impactOccurred()
        step += 1
    }

    private func skipToFinal() {
        withAnimation {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

#Preview {
    NewBoarding1(step: .constant(0))
}
