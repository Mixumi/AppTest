import SwiftUI

struct OnboardingConstants {
    static let totalSteps: Int = 9
    static let lastStepIndex: Int = totalSteps - 1
}

enum SpaceTheme {
    static var backgroundPrimary: Color {
        Color(red: 11 / 255, green: 15 / 255, blue: 35 / 255)
    }

    static var backgroundSecondary: Color {
        Color(red: 19 / 255, green: 26 / 255, blue: 54 / 255)
    }

    static var textPrimary: Color {
        Color.white.opacity(0.92)
    }

    static var textSecondary: Color {
        Color.white.opacity(0.65)
    }

    static var cardBackgroundPrimary: Color {
        Color.white.opacity(0.12)
    }

    static var brandPrimary: Color {
        Color(red: 120 / 255, green: 190 / 255, blue: 255 / 255)
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 120 / 255, green: 190 / 255, blue: 255 / 255),
                Color(red: 155 / 255, green: 116 / 255, blue: 255 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct SpaceStar: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
}

struct NightSkyView: View {
    private let stars: [SpaceStar]

    init(starCount: Int = 120) {
        self.stars = (0..<starCount).map { _ in
            SpaceStar(
                position: CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1)),
                size: CGFloat.random(in: 1...2.6),
                opacity: Double.random(in: 0.35...1)
            )
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                LinearGradient(
                    colors: [
                        SpaceTheme.backgroundPrimary,
                        SpaceTheme.backgroundSecondary,
                        Color(red: 6 / 255, green: 7 / 255, blue: 18 / 255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 55 / 255, green: 95 / 255, blue: 150 / 255).opacity(0.7),
                        .clear
                    ]),
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: max(size.width, size.height) * 0.9
                )
                .offset(x: -size.width * 0.25, y: -size.height * 0.1)

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 120 / 255, green: 60 / 255, blue: 180 / 255).opacity(0.75),
                        .clear
                    ]),
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: max(size.width, size.height) * 0.8
                )
                .offset(x: size.width * 0.2, y: size.height * 0.2)

                StarField(stars: stars)
                PlanetCluster()
            }
            .ignoresSafeArea()
        }
    }
}

private struct StarField: View {
    let stars: [SpaceStar]

    var body: some View {
        GeometryReader { geometry in
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(
                        x: star.position.x * geometry.size.width,
                        y: star.position.y * geometry.size.height
                    )
            }
        }
        .blur(radius: 0.2)
    }
}

private struct PlanetCluster: View {
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(red: 160 / 255, green: 200 / 255, blue: 255 / 255).opacity(0.4),
                                Color(red: 120 / 255, green: 80 / 255, blue: 255 / 255).opacity(0.2),
                                Color(red: 100 / 255, green: 160 / 255, blue: 255 / 255).opacity(0.4)
                            ]),
                            center: .center
                        )
                    )
                    .frame(width: size.width * 0.9, height: size.width * 0.9)
                    .blur(radius: 60)
                    .offset(x: -size.width * 0.4, y: -size.height * 0.3)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 255 / 255, green: 186 / 255, blue: 120 / 255).opacity(0.3),
                                Color(red: 120 / 255, green: 175 / 255, blue: 255 / 255).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.width * 0.5)
                    .blur(radius: 40)
                    .offset(x: size.width * 0.35, y: size.height * 0.45)
            }
        }
    }
}

struct OnboardingScaffold<Content: View>: View {
    let currentStep: Int
    @Binding var step: Int
    var showsSkip: Bool = true
    var showsPrimaryButton: Bool = true
    var isPrimaryButtonDisabled: Bool = false
    var primaryButtonTitle: LocalizedStringKey?
    var primaryButtonIcon: String?
    var skipAction: (() -> Void)?
    var onPrimaryButtonTap: () -> Void
    @ViewBuilder var content: () -> Content

    init(
        currentStep: Int,
        step: Binding<Int>,
        showsSkip: Bool = true,
        showsPrimaryButton: Bool = true,
        isPrimaryButtonDisabled: Bool = false,
        primaryButtonTitle: LocalizedStringKey? = nil,
        primaryButtonIcon: String? = nil,
        skipAction: (() -> Void)? = nil,
        onPrimaryButtonTap: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.currentStep = currentStep
        self._step = step
        self.showsSkip = showsSkip
        self.showsPrimaryButton = showsPrimaryButton
        self.isPrimaryButtonDisabled = isPrimaryButtonDisabled
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonIcon = primaryButtonIcon
        self.skipAction = skipAction
        self.onPrimaryButtonTap = onPrimaryButtonTap
        self.content = content
    }

    private var computedPrimaryTitle: LocalizedStringKey {
        if let primaryButtonTitle {
            return primaryButtonTitle
        }
        return currentStep == OnboardingConstants.lastStepIndex ? "开始探索" : "下一步"
    }

    private var computedPrimaryIcon: String {
        if let primaryButtonIcon {
            return primaryButtonIcon
        }
        return currentStep == OnboardingConstants.lastStepIndex ? "sparkles" : "chevron.right"
    }

    var body: some View {
        ZStack {
            NightSkyView()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if showsSkip {
                        Button {
                            (skipAction ?? { step = OnboardingConstants.lastStepIndex })()
                        } label: {
                            Text("跳过")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(SpaceTheme.textSecondary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    Capsule().fill(SpaceTheme.cardBackgroundPrimary.opacity(0.6))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding([.top, .trailing], 24)
                    }
                }

                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 24)
                    .padding(.top, showsSkip ? 8 : 32)

                VStack(spacing: 20) {
                    OnboardingPageIndicator(currentStep: currentStep, totalSteps: OnboardingConstants.totalSteps)
                        .padding(.top, 8)

                    if showsPrimaryButton {
                        SpacePrimaryButton(
                            title: computedPrimaryTitle,
                            icon: computedPrimaryIcon,
                            isDisabled: isPrimaryButtonDisabled,
                            action: onPrimaryButtonTap
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPageIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentStep ? SpaceTheme.accentGradient : LinearGradient(colors: [SpaceTheme.textSecondary.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: index == currentStep ? 24 : 12, height: 4)
                    .opacity(index == currentStep ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
}

struct SpacePrimaryButton: View {
    let title: LocalizedStringKey
    let icon: String
    var isDisabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Color.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                SpaceTheme.accentGradient
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
        .buttonStyle(.plain)
    }
}

struct DangerCustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "app.fill")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(SpaceTheme.brandPrimary)
            configuration.title
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(SpaceTheme.textPrimary)
            configuration.icon
        }
    }
}
