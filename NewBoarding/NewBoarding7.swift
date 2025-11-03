//
//  NewBoarding7.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//


import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - 正向的app
struct NewBoarding7: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int
    
    
    // 限时应用
    @State var isChoosePlanet : Bool = false
    @State var positiveSelection : FamilyActivitySelection  = FamilyActivitySelection(includeEntireCategory: true)  // 正向应用选择器
    @State var positiveAppTokens : Set<ApplicationToken> = [] // 正向app
    
    // 首先定义网格布局
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    var body: some View {
        ZStack {
            NightSkyView()
            VStack {
                // 顶部数字
                HStack(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("通过使用正向应用，你可以自动获取星币。请选择对你有益的正向应用。")
                        .font(.system(size: 18, weight: .light, design: .monospaced))
                        .foregroundStyle(SpaceTheme.textPrimary)
                        .lineSpacing(12)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer()
                if positiveAppTokens.isEmpty {
                    VStack {
                        Spacer()
                        Image("blueVenus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                            .stroke(color: .white, width: 1.2)
                        Spacer()
                    }
                }else {
                    ScrollView{
                        LazyVGrid(columns: columns, spacing: 16) {
                            // 你的网格项
                            ForEach(Array(positiveAppTokens) , id :\.self) { token in
                                VStack {
                                    HStack {
                                        Spacer()
                                        Label(token)
                                            .labelStyle(DangerCustomLabelStyle())
                                        Spacer()
                                    }
                                }
                                .padding(.all , 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(SpaceTheme.cardBackgroundPrimary) // 系统玻璃质感
                                        .overlay(
                                            // 一层微弱的白色边框，增强边缘高光
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(Color.white.opacity(1), lineWidth: 1)
                                                .blur(radius: 1)
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    if !positiveAppTokens.isEmpty {
                        Button {
                            feedbackGenerator.impactOccurred()
                            let fiveApplications = Set(positiveAppTokens.prefix(5)) // 只设置5个
                            do {
                                // 查询 type=0 的 Applications
                                let list = try Applications.fetchByType(context: viewContext, type: 1)
                                if let (app, _) = list.first {
                                    // 已有数据，更新 appTokens
                                    let encoder = JSONEncoder()
                                    app.appTokens = try encoder.encode(fiveApplications)
                                    try viewContext.save()
                                    print("更新成功: \(app)")
                                } else {
                                    // 没有数据，新增
                                    _ = try Applications.add(
                                        context: viewContext,
                                        tokens: fiveApplications,
                                        id: UUID(),
                                        type: 1 // 1 表示限制鼓励
                                    )
                                    print("新增成功")
                                }
                            } catch {
                                print("操作失败: \(error)")
                            }
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
                    }else {
                        Button {
                            feedbackGenerator.impactOccurred()
                            isChoosePlanet.toggle()
                        } label: {
                            HStack(spacing: 8) {
                                Text("选取")
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
            .frame(maxWidth: 500)
        }
        .fullScreenCover(isPresented: $isChoosePlanet){
            ZStack {
                VStack {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(SpaceTheme.brandPrimary.opacity(0.1))
                            .frame(width: CGFloat.random(in: 100...300))
                            .offset(x: CGFloat.random(in: -100...100),
                                    y: CGFloat.random(in: -100...100))
                    }
                }
                .blur(radius: 20)
                // MARK: - 内容
                VStack(spacing : 12) {
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .frame(width: 32, height: 32)
                                .cornerRadius(8)
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18)
                                .foregroundStyle(SpaceTheme.textPrimary)
                        }
                        .onTapGesture {
                            feedbackGenerator.impactOccurred()
                            isChoosePlanet.toggle()
                        }
                        Spacer()
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .frame(width: 32, height: 32)
                                .cornerRadius(8)
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18)
                                .foregroundStyle(SpaceTheme.textPrimary)
                        }
                        .onTapGesture {
                            feedbackGenerator.impactOccurred()
                            positiveAppTokens = []
                            if positiveSelection.applicationTokens.isEmpty {
                                return
                            }else {
                                for (_ , token) in positiveSelection.applicationTokens.enumerated() {
                                    positiveAppTokens.insert(token)
                                }
                            }
                            isChoosePlanet.toggle()
                        }
                    }
                    FamilyActivityPicker(selection: $positiveSelection)
                    HStack {
                        Text("Selected")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(SpaceTheme.backgroundPrimary)
                        Spacer()
                        HStack {
                            Text("\(positiveSelection.applicationTokens.count) planets")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundStyle(SpaceTheme.backgroundPrimary)
                            
                            
                        }
                    }
                    .padding(.horizontal , 16)
                }
                .padding(.all , 16)
                
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .onAppear {
            do {
                let list = try Applications.fetchByType(context: viewContext, type: 1) // type == 1 正向app
                for (_, tokens) in list {
                    positiveAppTokens.formUnion(tokens)
                }
            } catch {
               
            }
        }
    }
}

#Preview {
    NewBoarding7(step: .constant(0))
}
