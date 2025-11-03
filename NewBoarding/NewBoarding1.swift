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
    
    // MARK: — 动画状态
    @State private var showHeadline = false
    @State private var showBody = false
    @State private var showCat = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            NightSkyView()
            VStack {
                // 顶部数字
                // 主体文字
                VStack(spacing: 16) {
                    HStack {
                        Text("舰长\(name)，你知道么？每天仅需减少30分钟手机使用时间，您的生活将会发生翻天覆地的变化。")
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
            VStack {
                Spacer()
                HStack(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("-30")
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.purple, Color.blue, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("分钟")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.purple, Color.blue, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Spacer()
                }
                .opacity(showHeadline ? 1 : 0)
                .offset(y: showHeadline ? 0 : 20)
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        feedbackGenerator.impactOccurred()
                        step += 1
                    } label: {
                        HStack(spacing: 8) {
                            Text("去了解")
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
            
            VStack {
                Spacer()
                HStack {
                    Image("left-bottom-cat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .stroke(color: .white, width: 1.2)
                        .opacity(showCat ? 1 : 0)
                        .offset(x : -3 , y: showCat ? 3 : 20)
                    
                    Spacer()
                }
            }
            .ignoresSafeArea()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showCat = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showButton = true
                }
            }
        }
    }
}

#Preview {
    NewBoarding1(step: .constant(0))
}
