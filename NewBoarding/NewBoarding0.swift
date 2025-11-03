import SwiftUI

struct NewBoarding0: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @AppStorage("locationUserName") private var name: String = ""
    @Binding var step: Int

    private let currentStepIndex = 0
    
    // Hi 动画状态
    @State private var hiOffset: CGFloat = UIScreen.main.bounds.width // 初始在右侧外部
    @State private var hiOpacity: Double = 0
    @State private var hideHi = false
    @State private var showMainContent = false
    
    
    
    
    
    // 主内容子项依次出现
    @State private var showCat = false
    @State private var showText = false
    @State private var showTextField = false
    
    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            isPrimaryButtonDisabled: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !showMainContent,
            onPrimaryButtonTap: proceedToNext,
            skipAction: skipToFinal
        ) {
            ZStack {
                if !hideHi {
                    Image("Hi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.5)
                        .stroke(color: .white, width: 2)
                        .offset(x: hiOffset, y: 0)
                        .opacity(hiOpacity)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                                hiOffset = 0
                                hiOpacity = 1
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                                    hiOffset = UIScreen.main.bounds.width
                                    hiOpacity = 0
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                hideHi = true
                                showMainContent = true
                                withAnimation(.easeIn(duration: 0.5)) { showCat = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.easeIn(duration: 0.5)) { showText = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation(.easeIn(duration: 0.5)) { showTextField = true }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding()
                }

                if showMainContent {
                    mainContent
                        .transition(.opacity)
                }
            }
        }
    }

    var mainContent: some View {
        VStack(spacing: 48) {
            Spacer()
            // 1. Cat 图标
            Image("limstar-cat-line")
                .resizable()
                .scaledToFit()
                .frame(width: 84)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(SpaceTheme.cardBackgroundPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
                .scaleEffect(showCat ? 1.0 : 0.5) // 变大动画
                .opacity(showCat ? 1 : 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.68), value: showCat)

            // 2. 提示语
            Text("欢迎舰长，我是星喵，您的专注智能体，请输入您的姓名：")
                .font(.system(size: 18, weight: .ultraLight, design: .monospaced))
                .foregroundStyle(SpaceTheme.textPrimary)
                .lineSpacing(6)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(showText ? 1 : 0)

            // 3. 输入框
            TextField("Your name", text: $name)
                .textFieldStyle(.plain)
                .foregroundStyle(SpaceTheme.textPrimary)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(SpaceTheme.cardBackgroundPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
                .onSubmit {
                    proceedToNext()
                }
                .opacity(showTextField ? 1 : 0)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.8 - 16)
    }

    private func proceedToNext() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, showMainContent else { return }
        withAnimation {
            feedbackGenerator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    NewBoarding0(step: .constant(0))
}
