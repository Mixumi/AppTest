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
    
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // MARK: — 动画状态
    @State private var showHeadline = false
    @State private var showBody = false
    @State private var showButton = false
    
    
    
    @State private var isLoading = false
    
    
    var body: some View {
        ZStack {
            NightSkyView()
            if !isLoading {
                mainView
                    .transition(.opacity)
            }else {
                progressView
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 顺序浮现效果
            withAnimation(.easeOut(duration: 0.5)) {
                showBody = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showHeadline  = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showButton = true
                }
            }
        }
    }
    
    
    private var progressView: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("系统启动中")
                    .font(.system(size: 18, weight: .ultraLight, design: .monospaced))
                    .foregroundStyle(SpaceTheme.textPrimary)
                    .lineSpacing(6)
                
                AnimatedGradientProgressBar {
                }
            }
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.8 - 16)
    }
    
    
    private var mainView: some View {
        VStack{
            VStack {
                // 主体文字
                VStack(spacing: 16) {
                    HStack {
                        Text("此外，你还可以通过步行、正念、专注或完成系统任务来获取星币，以换取使用时间。")
                            .font(.system(size: 18, weight: .light, design: .monospaced))
                            .foregroundStyle(SpaceTheme.textPrimary)
                            .lineSpacing(12)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 16)
                .opacity(showBody ? 1 : 0)
                .offset(y: showBody ? 0 : 20)
                Spacer()
            }
            .padding(.all , 16)
            .frame(maxWidth: 500)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("准备好进入LIMSTAR，开启一年改变之旅了么？")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.purple, Color.blue, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .lineLimit(5)
                        .minimumScaleFactor(0.5)
                    Spacer()
                }
                .opacity(showHeadline ? 1 : 0)
                .offset(y: showHeadline ? 0 : 20)
                Spacer()
            }
            .padding(.all , 16)
            .frame(maxWidth: 500)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        feedbackGenerator.impactOccurred()
                        isLoading = true
                        
                        Task {
                            var startedAll = false
                            // —— 后面不管成功失败都要收尾：进入引导 + 复位 loading
                            defer {
                                Task { @MainActor in
                                    hasSeenOnboarding = true
                                    isLoading = false
                                }
                            }
                            
                            // 1) danger
                            let dangerOK = DeviceMonitorService.shared.startDangerMonitoring()
                            guard dangerOK else {
                                // 失败：记录并继续走到 defer -> 进入引导
                                // log("startDangerMonitoring failed")
                                return
                            }
                            // 2) 等 2 秒（若需要稳定期）
                            try? await Task.sleep(for: .seconds(2))
                            
                            // 3) positive
                            let positiveOK = DeviceMonitorService.shared.startPositiveMonitoring()
                            if !positiveOK {
                                // 回滚 danger，仍让用户进入引导
                                DeviceMonitorService.shared.stopMonitoring(named: "dangerplanetsmonitor")
                                // log("startPositiveMonitoring failed")
                                return
                            }
                            
                            // 都成功
                            startedAll = true
                            
                            // 4) （可选）体验上的缓冲
                            try? await Task.sleep(for: .seconds(5))
                            
                            // 5) 若需要在进入引导前做 UI 更新，也可显式切回主线程
                            await MainActor.run {
                                // 比如：给个提示
                                // toast = "监控已启动"
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("准备好了")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(SpaceTheme.textPrimary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(SpaceTheme.textPrimary)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                    }
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)
                }
            }
        }
    }
}

#Preview {
    NewBoarding8(step: .constant(0))
}
