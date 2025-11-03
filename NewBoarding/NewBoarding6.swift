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
    
    // 用来控制各部分显隐
    @State private var showTitle = false
    @State private var showDescription = false
    
    
    @State private var showCat = false
    
    
    @State private var showButton = false
    
    
    var body: some View {
        ZStack {
            NightSkyView()
            
            VStack {
                // MARK: 标题
                HStack(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("10")
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
                // 根据 showTitle 切换透明度与偏移
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: showTitle)
                
                // MARK: 说明文案
                VStack(spacing: 16) {
                    Text("你每天有10分钟的限制应用使用时间，时间用尽后这些应用将被禁用。若需继续使用，可通过星币来兑换时间。")
                        .font(.system(size: 18, weight: .light, design: .monospaced))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .lineSpacing(12)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                .padding(.top, 16)
                .opacity(showDescription ? 1 : 0)
                .offset(y: showDescription ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: showDescription)
                Spacer()
                    .frame(height: 64)
                // MARK: 说明文案
                VStack(spacing: 16) {
                    Image("cat-coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }
                .padding(.top, 16)
                .opacity(showCat ? 1 : 0)
                .offset(y: showCat ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: showCat)
                
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: 500)
            
            // MARK: 底部按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        feedbackGenerator.impactOccurred()
                        step += 1
                    } label: {
                        HStack(spacing: 8) {
                            Text("如何获取星币")
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
                    .animation(.easeOut(duration: 0.5), value: showButton)
                }
            }
        }
        .onAppear {
            // 依次触发动画：0s 标题，1s 文案，2s 按钮
            showTitle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showDescription = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showCat = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showButton = true
            }
        }
    }
}





#Preview {
    NewBoarding6(step: .constant(0))
}


