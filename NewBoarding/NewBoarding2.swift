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
        ZStack {
            NightSkyView()
            VStack {
                PageIndicator(currentPage: $currentPage)
                Spacer()
            }
            .padding(.all , 16)
            VStack {
                Spacer()
                HStack {
                    // 分页TabView
                    TabView(selection: $currentPage) {
                        ForEach(0..<cards.count, id: \.self) { idx in
                            CardView(title: cards[idx].0, imgName: cards[idx].1, desc: cards[idx].2)
                                .tag(idx)
                        }
                    }
                    // 隐藏系统自带的点
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                Spacer()
            }
            .frame(maxWidth: 500)
            
            
            VStack {
                Spacer()
                if currentPage == 2 {
                    HStack {
                        Spacer()
                        Button {
                            feedbackGenerator.impactOccurred()
                            step += 1
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(SpaceTheme.textPrimary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(SpaceTheme.textPrimary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                        }
                    }
                    
                }
            }
            .padding(.all , 16)
        }
    }
    
    
    
    
}


struct PageIndicator: View {
    /// 当前高亮的索引（0、1、2）
    @Binding var currentPage: Int
    
    /// 总页数
    let pageCount: Int = 3
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                // 选中页宽一点，不选中时半透明
                    .frame(width: currentPage == index ? 30 : 20, height: 4)
                    .foregroundColor(.gray)
                    .opacity(currentPage == index ? 1 : 0.5)
                // 加入动画效果
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
        }
        // 顶部间距，可根据状态栏/导航栏高度微调
        .padding(.top, 16)
    }
}


#Preview {
    NewBoarding2(step: .constant(0))
}


// 2. 你的卡片视图，可以按需求自定义样式
struct CardView: View {
    let title: String
    let imgName: String
    let desc: String
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .bold()
            Spacer()
            GeometryReader { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(imgName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.6)
                        Spacer()
                    }
                    Spacer()
                }
            }
            HStack {
                Text(desc)
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundStyle(SpaceTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal , 16)
        }
        .padding()
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .frame(maxWidth: .infinity)
        .background( // 毛玻璃面板
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemBackground)) // 系统玻璃质感
                .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 0)  // 外光晕，让边缘发亮
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5) // 投下的阴影，增加层次感
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 1.5)
                }
        )
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal, 24)
    }
}
