//
//  AddDice.swift
//  DiceyRoll
//
//  Created by Jemerson Canaya on 3/12/25.
//
import SwiftUI
import SwiftData

struct AddDice: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var dice: [Dice]
    @Environment(\.modelContext) private var modelContext
    
    let diceSides: [DiceSide] = [.fourSided, .sixSided, .eightSided, .tenSided, .twelveSided, .twentySided, .oneHundredSided]
    
    @State private var selectedDiceSide: DiceSide = .fourSided
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 5) {
                    Text("Add new dice")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                    HStack {
                        Image(systemName: "dot.square.fill")
                            .font(.largeTitle)
                        Image(systemName: "dice.fill")
                            .font(.largeTitle)
                    }
                    .accessibilityHidden(true)
                }
                
                Spacer()
                    .frame(height: 30)
                
                VStack {
                    Text("Select a dice")
                        .font(.headline)
                        .accessibilityHidden(true)
                    Picker("Select a dice", selection: $selectedDiceSide) {
                        ForEach(diceSides, id: \.self) { side in
                            Text(side.rawValue.description)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                
                Button {
                    let dice = Dice(id: dice.count, diceSide: selectedDiceSide, currentValue: 0, totalValue: 0)
                    modelContext.insert(dice)
                    dismiss()
                } label: {
                    
                    ZStack {
                        Color.white
                            .clipShape(.circle)
                            .shadow(radius: 5)
                            .frame(width: 60, height: 60)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                    }
                    .contentShape(.circle)
                    
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Tap to add a new dice"))
                .accessibilityAddTraits(.isButton)
                
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }

        }
                
    }
}

#Preview {
    AddDice()
        .modelContainer(for: Dice.self)
}
