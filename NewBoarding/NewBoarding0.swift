import SwiftUI

struct NewBoarding0: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @AppStorage("locationUserName") private var name: String = ""
    @Binding var step: Int
    
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
        ZStack {
            NightSkyView()
            // 1. Hi 图
            // Hi 动画状态
            // 在 .body 里：
            if !hideHi {
                Image("Hi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.5)
                    .stroke(color: .white, width: 2)
                    .offset(x: hiOffset, y: 0)
                    .opacity(hiOpacity)
                    .onAppear {
                        // 1. 进场动画
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                            hiOffset = 0
                            hiOpacity = 1
                        }
                        
                        // 2. 停留 0.7s
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // 3. 回缩动画
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                                hiOffset = UIScreen.main.bounds.width
                                hiOpacity = 0
                            }
                        }
                        // 4. Hi 消失 0.35s 后进入主内容
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            hideHi = true
                            showMainContent = true
                            // 这里触发主内容依次动画...
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
            
            // 2. 主内容
            if showMainContent {
                mainContent
                    .transition(.opacity)
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
                .frame(width: 64)
                .background(.black)
                .cornerRadius(8)
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
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .padding(14)
                .background(
                    .ultraThinMaterial.opacity(0.3),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.label).opacity(0.4), lineWidth: 1)
                )
                .onSubmit {
                    guard !name.isEmpty else { return }
                    withAnimation {
                        feedbackGenerator.impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            step += 1
                        }
                    }
                }
                .opacity(showTextField ? 1 : 0)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.8 - 16)
    }
}

#Preview {
    NewBoarding0(step: .constant(0))
}
