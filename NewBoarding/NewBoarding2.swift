//
//  NewBoarding2.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/9.
//

import SwiftUI

struct NewBoarding2: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int
    @State private var currentPage: Int = 0

    private let currentStepIndex = 2

    private let cards = [
        (
            NSLocalizedString("健康", comment: ""),
            "dumbell",
            NSLocalizedString("每天运动30分钟，一年后你将拥有强壮的身体。", comment: "")
        ),
        (
            NSLocalizedString("学习", comment: ""),
            "language",
            NSLocalizedString("每天学习外语30分钟，一年后你将流利表达、拓展视野。", comment: "")
        ),
        (
            NSLocalizedString("生活", comment: ""),
            "movie",
            NSLocalizedString("每天陪伴家人30分钟，一年后你将拥有更加亲密的关系。", comment: "")
        )
    ]

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            isPrimaryButtonDisabled: currentPage < cards.count - 1,
            onPrimaryButtonTap: goNext,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text("探索减少使用手机后的三种可能宇宙")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("轻轻滑动星图，选择你最想先改变的方向。")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                TabView(selection: $currentPage) {
                    ForEach(0..<cards.count, id: \.self) { idx in
                        CardView(title: cards[idx].0, imgName: cards[idx].1, desc: cards[idx].2)
                            .tag(idx)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.48)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                CardCarouselIndicator(currentIndex: $currentPage, total: cards.count)
            }
            .frame(maxWidth: 560)
            .padding(.top, 24)
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

struct CardCarouselIndicator: View {
    @Binding var currentIndex: Int
    let total: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? SpaceTheme.accentGradient : LinearGradient(colors: [SpaceTheme.textSecondary.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: index == currentIndex ? 28 : 12, height: 4)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
        .padding(.top, 8)
    }
}

struct CardView: View {
    let title: String
    let imgName: String
    let desc: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(SpaceTheme.textPrimary)

            GeometryReader { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(imgName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.6)
                            .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 14)
                        Spacer()
                    }
                    Spacer()
                }
            }

            Text(desc)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(SpaceTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(SpaceTheme.cardBackgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1.2)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .blur(radius: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 18)
        .padding(.vertical, 8)
    }
}

#Preview {
    NewBoarding2(step: .constant(0))
}
