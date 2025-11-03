import SwiftUI
import UIKit

// MARK: - 数据模型

private struct SpaceFeature: Identifiable {
    let id = UUID()
    let symbol: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
}

private struct SpaceRoutine: Identifiable {
    let id = UUID()
    let time: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let icon: String
}

private struct SpacePermission: Identifiable {
    let id = UUID()
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
}

// MARK: - Step 0 欢迎

struct SpaceWelcomeStep: View {
    @Binding var step: Int
    @AppStorage("locationUserName") private var name: String = ""
    @FocusState private var isNameFieldFocused: Bool
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var glowPhase: CGFloat = 0

    private var isPrimaryDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        OnboardingScaffold(
            currentStep: 0,
            step: $step,
            isPrimaryButtonDisabled: isPrimaryDisabled,
            onPrimaryButtonTap: goNext,
            skipAction: skipToFinal
        ) {
            VStack(alignment: .leading, spacing: 32) {
                Spacer(minLength: 0)

                CosmicHeroBadge(glowPhase: $glowPhase)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .onAppear(perform: startHeroAnimation)

                VStack(alignment: .leading, spacing: 16) {
                    Text("欢迎登舰，舰长！")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .transition(.move(edge: .leading).combined(with: .opacity))

                    Text("为了更好地协助您的专注航程，请告诉我您希望大家如何称呼您。")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .lineSpacing(6)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("舰长代号")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)

                    TextField("输入您的名字", text: $name)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(SpaceTheme.cardBackgroundPrimary))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .focused($isNameFieldFocused)
                        .submitLabel(.done)
                        .onSubmit(goNext)
                }

                Text("星喵 AI 将根据您的节奏推荐更适合的任务安排，随时可以在个人资料中修改昵称。")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .padding(.top, 8)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 32)
        }
    }

    private func startHeroAnimation() {
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            glowPhase = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isNameFieldFocused = true
        }
    }

    private func goNext() {
        guard !isPrimaryDisabled else { return }
        feedbackGenerator.impactOccurred()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            step = min(step + 1, OnboardingConstants.lastStepIndex)
        }
    }

    private func skipToFinal() {
        withAnimation(.easeInOut(duration: 0.35)) {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

// MARK: - Step 1 舰队使命

struct SpaceMissionOverviewStep: View {
    @Binding var step: Int
    @State private var appearProgress: CGFloat = 0

    private let features: [SpaceFeature] = [
        SpaceFeature(symbol: "sparkles", title: "智能守护", description: "自动识别分心模式，激活专注空间，帮助您进入工作状态。"),
        SpaceFeature(symbol: "timer", title: "节奏任务", description: "依据工作/休息节律生成任务节拍，并在恰当时机提醒您调整。"),
        SpaceFeature(symbol: "trophy", title: "激励挑战", description: "将每一次专注转化为养成点数，解锁挑战奖励。")
    ]

    var body: some View {
        OnboardingScaffold(
            currentStep: 1,
            step: $step,
            onPrimaryButtonTap: goNext,
            skipAction: skipToFinal
        ) {
            VStack(alignment: .leading, spacing: 32) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 16) {
                    Text("舰队使命")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)

                    Text("LIMSTAR 的智能体会根据您的行为动态调整策略，让「专注」成为自然的习惯。")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .lineSpacing(6)
                }

                VStack(spacing: 18) {
                    ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                        SpaceFeatureCard(feature: feature)
                            .opacity(Double(min(max(appearProgress - CGFloat(index) * 0.25, 0), 1)))
                            .offset(y: (1 - min(max(appearProgress - CGFloat(index) * 0.25, 0), 1)) * 24)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.bottom, 32)
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    appearProgress = 1
                }
            }
        }
    }

    private func goNext() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            step = min(step + 1, OnboardingConstants.lastStepIndex)
        }
    }

    private func skipToFinal() {
        withAnimation(.easeInOut(duration: 0.35)) {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

// MARK: - Step 2 专注工具包

struct SpaceFocusToolkitStep: View {
    @Binding var step: Int
    @State private var highlightedIndex: Int = 0

    private let routines: [SpaceRoutine] = [
        SpaceRoutine(time: "09:00", title: "沉浸准备", detail: "自动折叠社交应用，保留必要的工作渠道。", icon: "app.badge.checkmark"),
        SpaceRoutine(time: "11:30", title: "高效冲刺", detail: "实时监测任务进度，智能提醒休息并补充灵感。", icon: "bolt.badge.clock"),
        SpaceRoutine(time: "22:00", title: "舒缓收尾", detail: "引导放松与总结，帮助大脑完成一次完整的专注闭环。", icon: "moon.stars" )
    ]

    var body: some View {
        OnboardingScaffold(
            currentStep: 2,
            step: $step,
            onPrimaryButtonTap: goNext,
            skipAction: skipToFinal
        ) {
            VStack(alignment: .leading, spacing: 32) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 16) {
                    Text("专注工具包")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)

                    Text("每天的旅程将由一套循序渐进的仪式组成，帮助您保持节奏、调节能量并收集数据。")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .lineSpacing(6)
                }

                VStack(spacing: 18) {
                    ForEach(Array(routines.enumerated()), id: \.element.id) { index, routine in
                        SpaceRoutineRow(
                            routine: routine,
                            isHighlighted: highlightedIndex == index
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                highlightedIndex = index
                            }
                        }
                    }
                }

                Text("提示：完成每一个流程都会收集星尘积分，解锁更多舰队能力。")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 32)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.4)) {
                    highlightedIndex = 1
                }
            }
        }
    }

    private func goNext() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            step = min(step + 1, OnboardingConstants.lastStepIndex)
        }
    }

    private func skipToFinal() {
        withAnimation(.easeInOut(duration: 0.35)) {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

// MARK: - Step 3 权限热身

struct SpacePermissionWarmupStep: View {
    @Binding var step: Int
    @State private var permissions: [SpacePermissionSelection]
    @State private var isProcessing: Bool = false

    init(step: Binding<Int>) {
        let defaults: [SpacePermissionSelection] = [
            SpacePermissionSelection(permission: SpacePermission(symbol: "shield.lefthalf.filled", title: "应用限制", subtitle: "允许星喵代管分心应用，智能切换工作模式。"), isGranted: true),
            SpacePermissionSelection(permission: SpacePermission(symbol: "figure.run", title: "运动健康", subtitle: "分析活动与休息节奏，帮助你保持最佳专注状态。"), isGranted: false),
            SpacePermissionSelection(permission: SpacePermission(symbol: "chart.xyaxis.line", title: "专注数据", subtitle: "记录与展示专注时长，沉淀属于你的成长轨迹。"), isGranted: false)
        ]
        _step = step
        _permissions = State(initialValue: defaults)
    }

    var body: some View {
        OnboardingScaffold(
            currentStep: 3,
            step: $step,
            showsSkip: false,
            primaryButtonTitle: "开启旅程",
            primaryButtonIcon: "sparkles",
            isPrimaryButtonDisabled: isProcessing,
            onPrimaryButtonTap: completeOnboarding
        ) {
            VStack(alignment: .leading, spacing: 32) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 16) {
                    Text("最后一步：授权星喵")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)

                    Text("我们只会在专注旅程中使用这些权限，所有数据都会保存在您的设备上，可随时撤回。")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .lineSpacing(6)
                }

                VStack(spacing: 16) {
                    ForEach($permissions) { $selection in
                        SpacePermissionRow(selection: $selection)
                    }
                }

                Text("确认后我们会一次性引导完成所有授权，整个过程约需 30 秒。")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 32)
        }
    }

    private func completeOnboarding() {
        guard !isProcessing else { return }
        withAnimation(.easeIn(duration: 0.25)) {
            isProcessing = true
        }

        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                step = OnboardingConstants.lastStepIndex
                isProcessing = false
            }
        }
    }
}

private struct SpacePermissionSelection: Identifiable {
    let id = UUID()
    var permission: SpacePermission
    var isGranted: Bool
}

// MARK: - 组件

struct CosmicHeroBadge: View {
    @Binding var glowPhase: CGFloat
    @State private var rotation: Angle = .degrees(0)

    var body: some View {
        ZStack {
            Circle()
                .fill(SpaceTheme.cardBackgroundPrimary.opacity(0.6))
                .frame(width: 140, height: 140)
                .overlay(
                    Circle()
                        .stroke(SpaceTheme.brandPrimary.opacity(0.4), lineWidth: 1.5)
                        .blur(radius: 2)
                )
                .scaleEffect(1 + glowPhase * 0.04)
                .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 12)

            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [12, 24]))
                .foregroundStyle(SpaceTheme.accentGradient)
                .frame(width: 180, height: 180)
                .rotationEffect(rotation)
                .opacity(0.8)

            Image("limstar-cat-line")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
                .padding(20)
                .background(
                    Circle()
                        .fill(LinearGradient(colors: [Color.white.opacity(0.2), SpaceTheme.cardBackgroundPrimary], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotation = .degrees(360)
            }
        }
    }
}

struct SpaceFeatureCard: View {
    let feature: SpaceFeature

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SpaceTheme.cardBackgroundPrimary.opacity(0.7))
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                Image(systemName: feature.symbol)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(SpaceTheme.brandPrimary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(feature.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(SpaceTheme.textPrimary)

                Text(feature.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(SpaceTheme.cardBackgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct SpaceRoutineRow: View {
    let routine: SpaceRoutine
    var isHighlighted: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(spacing: 6) {
                Text(routine.time)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                Circle()
                    .fill(isHighlighted ? SpaceTheme.accentGradient : LinearGradient(colors: [SpaceTheme.textSecondary.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 10, height: 10)
            }
            .frame(width: 60)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: routine.icon)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.brandPrimary)
                    Text(routine.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                }

                Text(routine.detail)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isHighlighted ? SpaceTheme.cardBackgroundPrimary.opacity(1) : SpaceTheme.cardBackgroundPrimary.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(isHighlighted ? SpaceTheme.brandPrimary.opacity(0.3) : Color.white.opacity(0.12), lineWidth: 1.2)
                )
                .shadow(color: isHighlighted ? SpaceTheme.brandPrimary.opacity(0.25) : Color.clear, radius: isHighlighted ? 18 : 0, x: 0, y: 10)
        )
    }
}

struct SpacePermissionRow: View {
    @Binding var selection: SpacePermissionSelection

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(SpaceTheme.cardBackgroundPrimary.opacity(0.9))
                .frame(width: 52, height: 52)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: selection.permission.symbol)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.brandPrimary)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(selection.permission.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)

                    Spacer()

                    Toggle(isOn: $selection.isGranted.animation(.easeInOut(duration: 0.2))) {
                        EmptyView()
                    }
                    .toggleStyle(SpacePermissionToggleStyle())
                    .labelsHidden()
                }

                Text(selection.permission.subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(SpaceTheme.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(SpaceTheme.cardBackgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(selection.isGranted ? SpaceTheme.brandPrimary.opacity(0.35) : Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

struct SpacePermissionToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(configuration.isOn ? SpaceTheme.accentGradient : LinearGradient(colors: [Color.white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 56, height: 32)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .padding(3)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isOn)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
