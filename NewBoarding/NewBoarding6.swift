//
//  NewBoarding6.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//
import SwiftUI

// MARK: - 限制的初始条件说明以及修改的地方
struct NewBoarding6: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int

    private let currentStepIndex = 6

    // 用来控制各部分显隐
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showCat = false

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            onPrimaryButtonTap: goNext,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text("10 分钟")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: showTitle)

                    Text("每天你拥有 10 分钟的限制应用使用时间，超过后这些应用会冻结。若想继续使用，可以通过星币兑换时间。")
                        .font(.system(size: 18, weight: .light, design: .monospaced))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .lineSpacing(12)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(showDescription ? 1 : 0)
                        .offset(y: showDescription ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: showDescription)
                }

                Image("cat-coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .opacity(showCat ? 1 : 0)
                    .offset(y: showCat ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: showCat)
            }
            .frame(maxWidth: 480)
        }
        .onAppear {
            showTitle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showDescription = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showCat = true
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
    NewBoarding6(step: .constant(0))
}
