//
//  NewBoarding4.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//

import SwiftUI

// MARK: - 请求通知权限
struct NewBoarding4: View {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int
    
    var body: some View {
        ZStack {
            NightSkyView()
            VStack {
                // 顶部数字
                HStack(alignment: .lastTextBaseline) {
                    Spacer()
                    Text("LIMSTAR会在合适的时候给您发送通知，告知屏幕使用情况。")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            SpaceTheme.textPrimary
                        )
                        .lineSpacing(12)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
                GeometryReader { geo in
                    ZStack {
                        NotificationPermissionAlertView()
                            .onTapGesture {
                                feedbackGenerator.impactOccurred()
                                Task {
                                    do {
                                        let settings = await UNUserNotificationCenter.current().notificationSettings()
                                        if settings.authorizationStatus == .notDetermined {
                                            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                                            step += 1
                                        } else {
                                            step += 1
                                        }
                                    } catch {
                                        step += 1
                                    }
                                }
                            }
                    }
                }
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
                        step += 1
                    } label: {
                        HStack(spacing: 8) {
                            Text("跳过")
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
    }
}

#Preview {
    NewBoarding4(step: .constant(0))
}


struct NotificationPermissionAlertView: View {
    let appName: String = NSLocalizedString("LIMSTAR", comment: "")
    var body: some View {
        ZStack {
            // 半透明遮罩
            Color.black.opacity(0)
                .ignoresSafeArea()
            // 弹窗主体
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        // 标题
                        Text("“\(appName)” 想给你发送通知")
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.center)
                        // 说明
                        Text("通知可能包括提醒、声音和图标标记。这些可以在\"设置\"中配置")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.secondary)
                    // 底部按钮
                    HStack(spacing: 0) {
                        Text("不允许")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.blue)
                        Rectangle()
                            .frame(width : 1 , height: 44)
                            .foregroundColor(Color.secondary)
                        Text("允许")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.blue)
                    }
                    .frame(height: 44)
                }
                .frame(width: 270)
                .background(SpaceTheme.cardBackgroundPrimary)
                .padding(.all , 16)
                .cornerRadius(13)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                .overlay(
                    // 这里的 cornerRadius 要和上面保持一致
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
        }
    }
}
