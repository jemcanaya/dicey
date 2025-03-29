//
//  SelectedDice.swift
//  DiceyRoll
//
//  Created by Jemerson Canaya on 3/12/25.
//
import SwiftUI
import CoreHaptics
import SwiftData

struct SelectedDice: View {
    @Query var dice: [Dice]
    @State var selectedDice: Dice
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var isActiveScene = true
    
    @State var showAddDiceSheet: Bool = false
    @State var hasDiceAdded: Bool = false
    
    
    @State private var diceY: CGFloat = 50
    @State private var dotY: CGFloat = 50
    
    @State private var diceAngle : Angle = .degrees(Double.random(in: 0...360))
    @State private var dotAngle : Angle = .degrees(-Double.random(in: 0...360))
    
    @State private var flickedValue = 0
    
    var rolledValue: Int {
        switch selectedDice.diceSide {
        case .fourSided:
            Int.random(in: 1...4)
        case .sixSided:
            Int.random(in: 1...6)
        case .eightSided:
            Int.random(in: 1...8)
        case .tenSided:
            Int.random(in: 1...10)
        case .twelveSided:
            Int.random(in: 1...12)
        case .twentySided:
            Int.random(in: 1...20)
        case .oneHundredSided:
            Int.random(in: 1...100)
        @unknown default:
            0
        }
    }
    
    @State private var engine: CHHapticEngine?
    @State private var rollDiceImpact = false
    
    @State private var flickTimeRemaining = 0
    @State private var dicePreviewTimeRemaining = 0
    let flickTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("Dicey")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                    Image(systemName: "dice.fill")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }
                .accessibilityElement()
                .accessibilityLabel(Text("Dicey"))
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 20) {
                    
                    if dice.count == 0 {
                        Button {
                            showAddDiceSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "dot.square")
                                    .font(.system(size: 50))
                                Text("Add your first dice here!")
                                    .font(.headline)
                                Image(systemName: "chevron.right")
                                    
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement()
                        .accessibilityLabel("Tap here to Add your first dice!")
                        .accessibilityAddTraits(.isButton)

                        
                    } else {
                        
                        NavigationLink {
                            ListOfDice(selectedDiceID: selectedDice.id) {
                                print($0)
                                for dice in self.dice {
                                    if dice.id == $0 {
                                        selectedDice = dice
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "dice")
                                    .font(.system(size: 50))
                                Text(selectedDice.diceSideText)
                                    .font(.headline)
                                Image(systemName: "chevron.right")
                                    
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement()
                        .accessibilityLabel("Your selected dice is \(selectedDice.diceSideText). Tap here to change dice.")
                        .accessibilityAddTraits(.isButton)

                        
                    }
                    
                    if dicePreviewTimeRemaining > 0 {
                        Rectangle()
                            .foregroundColor(.black)
                            .frame(width: 300, height: 300)
                            .overlay {
                                
                                ZStack {
                                    Text("\(selectedDice.currentValue)")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 80))
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .hidden(flickTimeRemaining > 0)
                                    
                                    Image(systemName: "dice.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white)
                                        .rotationEffect(diceAngle)
                                        .position(x: 200, y: diceY)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2), value: diceY)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2), value: diceAngle)
//                                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: diceY)
//                                        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: diceAngle)
                                    
                                    Image(systemName: "dot.square.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white)
                                        .rotationEffect(dotAngle)
                                        .position(x: 100, y: dotY)
                                        .animation(.spring(duration: 0.4, bounce: 0.5, blendDuration: 0), value: dotY)
                                        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: dotAngle)
                                }
                                
                                
                                
                            }
                            .clipShape(.rect(cornerRadius: 20))
                            .accessibilityElement()
                            .accessibilityLabel(flickTimeRemaining == 0 ? "The Dice Rolled is: \(selectedDice.currentValue)" : "Dice is rolling")
                    }
                    
                    
                    
                    if hasDiceAdded && dicePreviewTimeRemaining == 0 {
                        
                        VStack {
                            VStack {
                                Text("Current Value:")
                                    .font(.subheadline)
                                Text("\(selectedDice.tempValue)")
                                    .font(.title)
                                    
                            }
                            
                            HStack {
                                Text("Total Value:")
                                    .font(.subheadline)
                                Text("\(selectedDice.totalValue)")
                                    .font(.title)
                            }
                        }
                        .accessibilityElement()
                        .accessibilityLabel(Text("The Current Value or last dice roll is \(selectedDice.tempValue). The Total Value is \(selectedDice.totalValue)"))
                        
                        
                        
                        Button {
                            resetDice()
                            withAnimation(.bouncy) {
                                throwDice()
                            }
                            
                            rollDiceImpact.toggle()
                            
                            
                        } label: {
                            
                            HStack {
                                Image(systemName: "dice.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                Text("Roll dice")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.white)
                                Image(systemName: "dice.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(.black)
                            .clipShape(.rect(cornerRadius: 25))
                            
                        }
                        .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: rollDiceImpact)
                        .accessibilityElement()
                        .accessibilityLabel("\(selectedDice.currentValue != 0 ? "The last dice rolled is \(selectedDice.currentValue). " : "")Tap here to roll the dice")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHidden(hasDiceAdded == false && dicePreviewTimeRemaining > 0)
                        
                    }
                    
                }
                   
                    
            }
            .onAppear {
                print("Dice Count: \(dice.count)")
                if dice.count > 0 {
                    hasDiceAdded = true
                    
                    for x in dice {
                        if x.isSelected {
                            selectedDice = x
                        }
                    }
                    
                } else {
                    hasDiceAdded = false
                }
                
                prepareHaptics()
            }
            .onReceive(flickTimer) { time in
                guard isActiveScene else { return }
                
                if flickTimeRemaining > 0 {
                    flickTimeRemaining -= 1
                    
                    flickedValue = rolledValue
                    
                    print("Time Remarking: \(flickTimeRemaining), flickedValue: \(flickedValue)")
                    
                    if flickTimeRemaining == 0 {
                        print("FINAL FLICKED VALUE: \(flickedValue)")
                        selectedDice.currentValue = flickedValue
                    }
                }
                
                if dicePreviewTimeRemaining > 0 {
                    withAnimation(.bouncy) {
                        dicePreviewTimeRemaining -= 1
                    }
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    isActiveScene = true
                } else {
                    isActiveScene = false
                }
            }
            .sheet(isPresented: $showAddDiceSheet, onDismiss: determineFirstDice) {
                AddDice()
            }
        }
        
    }
    
    func determineFirstDice() {
        guard dice.count > 0 else { return }
        
        withAnimation(.snappy) {
            dice[0].isSelected = true
            selectedDice = dice[0]
            hasDiceAdded = true
        }
        
        
    }
    
    func resetDice() {
        diceY = 50
        dotY = 50
        
        diceAngle = .degrees(Double.random(in: 0...360))
        dotAngle = .degrees(-Double.random(in: 0...360))
    }
    
    func throwDice() {
        
        let diceAngles : [Double] = [-30, -15, 0, 15, 30]
        
        flickTimeRemaining = 3
        dicePreviewTimeRemaining = flickTimeRemaining + 2
        
        throwDiceHaptics()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dotY = 200
            dotAngle = .degrees(Double.random(in: -20...20))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dotY = 280
                diceY = 280
                dotAngle = .degrees(diceAngles[Int.random(in: 0..<diceAngles.count)])
                diceAngle = .degrees(diceAngles[Int.random(in: 0..<diceAngles.count)])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dotY = 270
                    diceY = 270
                    dotAngle = .degrees(diceAngles[Int.random(in: 0..<diceAngles.count)])
                    diceAngle = .degrees(diceAngles[Int.random(in: 0..<diceAngles.count)])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dotY = 280
                        diceY = 280
                        dotAngle = .degrees(diceAngles[Int.random(in: 0..<diceAngles.count)])
                        diceAngle = .degrees(diceAngles[Int.random(in: 0..<diceAngles.count)])
                    }
                }
            }
        }
    }
    
    // MARK: Haptics related methods
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    func throwDiceHaptics() {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0.4, through: 1, by: 0.8) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        for i in stride(from: 0.4, to: 1, by: 0.8) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
}

#Preview {
    
    do {
        let isEmpty = false
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Dice.self, configurations: config)
        let context = container.mainContext
        
        if isEmpty {
            return SelectedDice(selectedDice: .example)
                .modelContainer(container)
        } else {
            let dice = Dice.exampleArray
            
            dice.forEach { context.insert($0) }
            
            let sampleDice = dice[1]
            
            return SelectedDice(selectedDice: sampleDice)
                .modelContainer(container)
        }
        
        
        
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}
