//
//  ListOfDice.swift
//  DiceyRoll
//
//  Created by Jemerson Canaya on 3/12/25.
//
import SwiftUI
import LocalAuthentication
import SwiftData

struct ListOfDice: View {
    @Environment(\.dismiss) private var dismiss
    
    var isiPhone: Bool {
        #if os(iOS)
            UIDevice.current.userInterfaceIdiom == .phone
        #else
            false
        #endif
    }
    
    @Query var dice: [Dice]
    @State var selectedDiceID: Int
    @Environment(\.modelContext) private var modelContext
    
    @State var showAddDiceSheet: Bool = false
    
    var diceSelected: ((Int) -> Void)? = nil
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.largeTitle)
                        .foregroundStyle(.foreground)
                    
                }
                .padding(.leading)
                .accessibilityLabel(Text("Go back"))
                
                Spacer()
                
                
                Text("List of Dice")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                Image(systemName: "dice")
                    .font(.system(size: 40))
                    .accessibilityHidden(true)
                
                Spacer()
                
                Button {
                    showAddDiceSheet = true
                } label: {
                    HStack {
                        if isiPhone == false {
                            Text("Add new dice")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                        }
                        Image(systemName: "plus.square.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.black)
                    .clipShape(.rect(cornerRadius: 25))
                }
                .padding(.trailing)
                .accessibilityElement()
                .accessibilityLabel(Text("Tap to add new dice"))
                .accessibilityAddTraits(.isButton)
            }
            
            List {
                
                ForEach(dice) { dice in
                    
                    let ID = dice.id
                    
                    //"\(ID).circle.fill"
                    Button {
                        
                        for x in self.dice {
                            if x.id == selectedDiceID {
                                x.isSelected = false
                            }
                        }
                        
                        selectedDiceID = ID
                        
                        for x in self.dice {
                            if x.id == selectedDiceID {
                                x.isSelected = true
                            }
                        }
                        
                        diceSelected?(ID)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: selectedDiceID == ID ? "checkmark.circle.fill" : "\(ID).circle")
                                .font(.system(size: 30))
                            Text(dice.diceSideText)
                            Spacer()
                            
                            HStack(alignment: .midDiceAndValue, spacing: 10) {
                                VStack(alignment: .center) {
                                    Image(systemName: "dot.square")
                                        .font(.system(size: 16))
                                        .alignmentGuide(.midDiceAndValue) { $0[.bottom] }
                                    Text("\(dice.currentValue)")
                                        
                                }
                                VStack(alignment: .center) {
                                    Image(systemName: "dice.fill")
                                        .font(.footnote)
                                        .alignmentGuide(.midDiceAndValue) { $0[.bottom] }
                                    Text("\(dice.totalValue)")
                                        
                                }
                            }
                                                
                        }
                        .font(selectedDiceID == ID ? .headline : .body)
                    }
                    .accessibilityElement()
                    .accessibilityLabel(Text("\(selectedDiceID == ID ? "Selected, " : "")\(dice.diceSideText) (\(dice.currentValue))"))
                    .accessibilityHint(Text("Current Value is \(dice.currentValue), Total Value is \(dice.totalValue)"))
                    .accessibilityAddTraits(.isButton)
                    
                    
                }
                .onDelete(perform: removeDice(at:))
                
            }
            
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showAddDiceSheet) {
            AddDice()
        }
    }
    
    func removeDice(at offSets: IndexSet) {
        for offset in offSets {
            let dice = dice[offset]
            
            withAnimation {
                modelContext.delete(dice)
            }
        }
    }
}

#Preview {
    
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Dice.self, configurations: config)
        let context = container.mainContext
        
        var dice = Dice.exampleArray
        dice[1].isSelected = true
        
        dice.forEach { context.insert($0) }
        
        
        let selectedDice = dice[1].id
        
        return ListOfDice(selectedDiceID: selectedDice)
            .modelContainer(container)
        
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
    
}

