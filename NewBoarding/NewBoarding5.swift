//
//  NewBoarding5.swift
//  LIMSTAR
//
//  Created by 唐羽 on 2025/6/10.
//

import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - 坏的app
struct NewBoarding5: View {
    @Environment(\.managedObjectContext) private var viewContext

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @Binding var step: Int

    @State var isChoosePlanet : Bool = false
    @State var limitSelection : FamilyActivitySelection  = FamilyActivitySelection(includeEntireCategory: true)  //限制应用选择器
    @State var limitAppTokens : Set<ApplicationToken> = [] // 被选中的app

    private let currentStepIndex = 5

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        OnboardingScaffold(
            currentStep: currentStepIndex,
            step: $step,
            isPrimaryButtonDisabled: limitAppTokens.isEmpty,
            onPrimaryButtonTap: commitSelection,
            skipAction: skipToFinal
        ) {
            VStack(spacing: 24) {
                header

                if limitAppTokens.isEmpty {
                    emptyState
                } else {
                    selectedAppsGrid
                }

                Button {
                    feedbackGenerator.impactOccurred()
                    isChoosePlanet.toggle()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text(limitAppTokens.isEmpty ? "选择要限制的应用" : "重新选择")
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
            }
            .frame(maxWidth: 600)
        }
        .fullScreenCover(isPresented: $isChoosePlanet){
            SelectionSheet(
                title: NSLocalizedString("选择需要限制的应用", comment: ""),
                selection: $limitSelection,
                onDismiss: handleSelectionDismiss
            )
        }
        .onAppear {
            loadExistingSelections()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("请选择那些需要限制时间的应用")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(SpaceTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("当每日限额用尽后，这些应用将被冻结，除非你用星币兑换时间。")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(SpaceTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("venus")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.45)
                .stroke(color: .white, width: 1.2)
                .shadow(color: Color.black.opacity(0.3), radius: 18, x: 0, y: 12)

            Text("当前尚未选择应用，点击下方按钮挑选那些最容易让你分心的星球。")
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
                ForEach(Array(limitAppTokens), id: \.self) { token in
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
        limitAppTokens = []
        if limitSelection.applicationTokens.isEmpty { return }
        for (_, token) in limitSelection.applicationTokens.enumerated() {
            limitAppTokens.insert(token)
        }
    }

    private func commitSelection() {
        guard !limitAppTokens.isEmpty else { return }
        feedbackGenerator.impactOccurred()
        do {
            let list = try Applications.fetchByType(context: viewContext, type: 0)
            if let (app, _) = list.first {
                let encoder = JSONEncoder()
                app.appTokens = try encoder.encode(limitAppTokens)
                try viewContext.save()
            } else {
                _ = try Applications.add(
                    context: viewContext,
                    tokens: limitAppTokens,
                    id: UUID(),
                    type: 0
                )
            }
        } catch {
            // Handle silently
        }
        step += 1
    }

    private func loadExistingSelections() {
        do {
            let list = try Applications.fetchByType(context: viewContext, type: 0)
            for (_, tokens) in list {
                limitAppTokens.formUnion(tokens)
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

struct SelectionSheet: View {
    let title: String
    @Binding var selection: FamilyActivitySelection
    var onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FamilyActivityPicker(selection: $selection)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 16)

                HStack {
                    Text("已选择 \(selection.applicationTokens.count) 个应用")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(SpaceTheme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)

                Button {
                    onDismiss()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("完成")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(SpaceTheme.backgroundPrimary)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(SpaceTheme.brandPrimary)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .foregroundStyle(SpaceTheme.textPrimary)
                }
            }
            .background(SpaceTheme.backgroundPrimary.ignoresSafeArea())
        }
    }
}

#Preview {
    NewBoarding5(step: .constant(0))
}
