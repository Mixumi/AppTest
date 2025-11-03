//
//  OnboardingView.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/5/2.
//

import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - 引导页

// 引导页的作用：给用户美好的愿景， 获取权限 ， 同时获取对应权限

struct OnboardingView: View {
    // 是否展示第一次进入的导航页
    @State var step : Int = 0
    var body: some View {
        if step == 0 {
            NewBoarding0(step: $step)
        }else if step == 1 {
            NewBoarding1(step: $step)
        }else if step == 2 {
            NewBoarding2(step: $step)
        }else if step == 3 {
            NewBoarding3(step: $step)
        }else if step == 4 {
            NewBoarding4(step: $step)
        }else if step == 5 {
            NewBoarding5(step: $step)
        }else if step == 6 {
            NewBoarding6(step: $step)
        }else if step == 7 {
            NewBoarding7(step: $step)
        }else if step == 8 {
            NewBoarding8(step: $step)
        }
    }
}










#Preview {
    OnboardingView()
}


/**
 - 限制应用 OK
 - 正向应用 OK
 - 运动数据 OK
 - 专注数据 OK
 - 挑战兑换 OK
 */


