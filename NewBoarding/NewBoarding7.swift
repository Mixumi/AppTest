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

    private let currentStepIndex = 7

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            isPrimaryButtonDisabled: positiveAppTokens.isEmpty,
            onPrimaryButtonTap: commitSelection,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 24) {
                header

                if positiveAppTokens.isEmpty {
                    emptyState
                } else {
                    selectedAppsGrid
                }

                Button {
                    feedbackGenerator.impactOccurred()
                    isChoosePlanet.toggle()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text(positiveAppTokens.isEmpty ? "选择正向应用" : "重新选择")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(SpaceTheme.textPrimary)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(SpaceTheme.textPrimary.opacity(0.35), lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.04))
                            )
                    )
                }
                .buttonStyle(.plain)

                if !positiveAppTokens.isEmpty {
                    Text("系统将自动选取前 5 个正向应用用于每日星币奖励。")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(SpaceTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
            .frame(maxWidth: 600)
        }
        .fullScreenCover(isPresented: $isChoosePlanet){
            SelectionSheet(
                title: NSLocalizedString("选择能够带来收益的应用", comment: ""),
                selection: $positiveSelection,
                onDismiss: handleSelectionDismiss
            )
        }
        .onAppear {
            loadExistingSelections()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("通过使用正向应用，你可以自动获取星币。")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(SpaceTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("请选择那些让你成长、学习或放松的工具，我们会将它们作为鼓励目标。")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(SpaceTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("blueVenus")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.45)
                .stroke(color: .white, width: 1.2)
                .shadow(color: Color.black.opacity(0.3), radius: 18, x: 0, y: 12)

            Text("暂未选择正向应用，挑选一些能够带来收益的应用即可赚取星币。")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(SpaceTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var selectedAppsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(positiveAppTokens), id: \.self) { token in
                    VStack {
                        HStack {
                            Spacer()
                            Label(token)
                                .labelStyle(DangerCustomLabelStyle())
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(SpaceTheme.cardBackgroundPrimary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func handleSelectionDismiss() {
        positiveAppTokens = []
        if positiveSelection.applicationTokens.isEmpty { return }
        for (_, token) in positiveSelection.applicationTokens.enumerated() {
            positiveAppTokens.insert(token)
        }
    }

    private func commitSelection() {
        guard !positiveAppTokens.isEmpty else { return }
        feedbackGenerator.impactOccurred()
        let fiveApplications = Set(positiveAppTokens.prefix(5))
        do {
            let list = try Applications.fetchByType(context: viewContext, type: 1)
            if let (app, _) = list.first {
                let encoder = JSONEncoder()
                app.appTokens = try encoder.encode(fiveApplications)
                try viewContext.save()
            } else {
                _ = try Applications.add(
                    context: viewContext,
                    tokens: fiveApplications,
                    id: UUID(),
                    type: 1
                )
            }
        } catch {
            // ignore
        }
        step += 1
    }

    private func loadExistingSelections() {
        do {
            let list = try Applications.fetchByType(context: viewContext, type: 1)
            for (_, tokens) in list {
                positiveAppTokens.formUnion(tokens)
            }
        } catch {
            // ignore
        }
    }

    private func skipToFinal() {
        withAnimation {
            step = OnboardingConstants.lastStepIndex
        }
    }
}

#Preview {
    NewBoarding7(step: .constant(0))
}
