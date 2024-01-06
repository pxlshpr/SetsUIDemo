import SwiftUI

//TODO: Next
/// [ ] Tapping a set should expand it to show options letting user; edit it, add a drop set, mark as completed, quickly set RPE
/// [ ] Add drop-sets as extra sets that gets displayed in a grouped way with sets—have it displayed as inline underneat the set with its own RPE burt no completions
/// [ ] Add option of "Pauses" in sets, maybe
/// [ ] Add option of eccentric seconds and concentric seconds
/// [ ] Try creating a tempo diagram based on eccentric and concentric seconds to display in cell especially
/// [ ] Let user set one rep and copy x number of times in set
/// [ ] Let user quickly set things like alternating raps as a partial, or add intr-set rests every x seconds
/// [ ] Let user quickly add warmup sets based on a pyramid warmup, having a default percentage step up based on how many warmups they wanna do, and letting them edit these. Also if they specify a machine or the dumbbell weights they have, and have specified the weight increments that are possible (in a machine with a weight stack), calculate the closest stack based on the percentages
/// [ ] Let user take a picture of the weight stack and automatically read in the stack increments to fill it in quickly
/// [ ] Let user save the machines and choose them when editing an exercise (it always picks the last used machine)
/// [ ] Let user save the location they're working out at too, so that we know what locataions X machine is at

struct Workout: View {
    @State var showingExercise = false
    var body: some View {
        NavigationStack {
            Form {
                Button {
                    showingExercise = true
                } label: {
                    HStack {
                        Text("Walking Lunges")
                        Spacer()
                        Text("3 sets")
                    }
                    .foregroundStyle(Color(.label))
                }
                Button {
                    showingExercise = true
                } label: {
                    HStack {
                        Text("Leg Extensions")
                        Spacer()
                        Text("5 sets")
                    }
                    .foregroundStyle(Color(.label))
                }
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showingExercise) {
                NavigationView {
                    Exercise()
                }
            }
        }
    }
}

struct Set: Identifiable {
    let id = UUID()
    var reps: Int
    var weightInKg: Int
    var rpe: Double?
    var isCompleted: Bool = false
}

struct Exercise: View {

    @State var warmupSets: [Set] = [
        .init(reps: 3, weightInKg: 16, isCompleted: true),
        .init(reps: 2, weightInKg: 22, isCompleted: true),
        .init(reps: 1, weightInKg: 30, isCompleted: true)
    ]

    @State var workingSets: [Set] = [
        .init(reps: 5, weightInKg: 44, rpe: 8.5, isCompleted: true),
        .init(reps: 5, weightInKg: 44, rpe: 9),
    ]

    @State var downSets: [Set] = [
        .init(reps: 5, weightInKg: 36, rpe: 8),
        .init(reps: 5, weightInKg: 36, rpe: 8.5),
    ]

    @State var setShowingFormFor: Set? = nil
    
    var body: some View {
        Form {
            Section {
                Text("Walking Lunges")
            }
            Section("Warmup Sets") {
                ForEach($warmupSets) { $set in
                    SetCell(
                        set: $set,
                        setShowingFormFor: $setShowingFormFor
                    )
                }
                Button("Add Warmup Set") {
                    
                }
            }
            Section("Working Sets") {
                ForEach($workingSets) { $set in
                    SetCell(
                        set: $set,
                        setShowingFormFor: $setShowingFormFor
                    )
                }
                Button("Add Working Set") {
                    
                }
            }
            Section("Down Sets") {
                ForEach($downSets) { $set in
                    SetCell(
                        set: $set,
                        setShowingFormFor: $setShowingFormFor
                    )
                }
                Button("Add Back-off Set") {
                    
                }
            }
        }
        .navigationTitle("Exercise")
        .sheet(item: $setShowingFormFor) { _ in
            SetForm()
        }
    }
}

struct SetCell: View {
    
    @Binding var set: Set
    @Binding var setShowingFormFor: Set?

    var body: some View {
        HStack {
            completionButton
            link
        }
    }
    
    var completionButton: some View {
        Button {
            withAnimation {
                set.isCompleted.toggle()
            }
        } label: {
            completionCircle
        }
        .buttonStyle(.plain)
    }
    
    var link: some View {
        NavigationLink {
            SetForm()
//            setShowingFormFor = set
        } label: {
            HStack {
                repsText
                multiplyText
                weightText
                Spacer()
                rpeText
//                infoLabel
            }
        }
    }
    
    var infoLabel: some View {
        Image(systemName: "info.circle")
            .foregroundStyle(Color.accentColor)
    }
    
    @ViewBuilder
    var completionCircle: some View {
        if set.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .imageScale(.large)
        } else {
            Image(systemName: "circle.dotted")
                .foregroundStyle(Color(.tertiaryLabel))
                .imageScale(.large)
        }
    }
    
    var repsText: some View {
        Text("\(set.reps)")
            .foregroundStyle(Color(.label))
    }
    
    var multiplyText: some View {
        Text("×")
            .foregroundStyle(Color(.secondaryLabel))
    }
    
    var weightText: some View {
        Text("\(set.weightInKg) kg")
            .foregroundStyle(Color(.label))
    }
    
    @ViewBuilder
    var rpeText: some View {
        if let rpe = set.rpe {
            Text("\(rpe, specifier: "%.1f")")
                .foregroundStyle(Color(.label))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(Color(.systemFill))
                )
        }
    }
}

struct Rep: Identifiable {
    var id = UUID()
    var number: Int
    var type: RepType = .fullRangeOfMotion
    var includeRest: Bool = false
    var restTimeInSeconds: Int = 0
}

enum RepType: CaseIterable {
    case fullRangeOfMotion
    case partialLongLength
    case partialShortLength
    
    var name: String {
        switch self {
        case .fullRangeOfMotion:
            "Full Range of Motion"
        case .partialLongLength:
            "Lengthened Partials"
        case .partialShortLength:
            "Shortened Partials"
        }
    }
    
    var shortName: String {
        switch self {
        case .fullRangeOfMotion:
            "Full"
        case .partialLongLength:
            "Lengthened"
        case .partialShortLength:
            "Shortened"
        }
    }
}

struct RepForm: View {

    let index: Int
    @Binding var reps: [Rep]
    
    var body: some View {
        Form {
            repCountSection
            rangeOfMotionSection
            tempoSection
            restSection
        }
        .navigationTitle("Rep")
    }
    
    var tempoSection: some View {
        Section("Tempo") {
            HStack {
                Text("Concentric")
            }
            HStack {
                Text("Pause")
            }
            HStack {
                Text("Eccentric")
            }
        }
    }

    var rep: Rep {
        reps[index]
    }
    
    var repCountSection: some View {
        Section {
            HStack {
                Text("Rep")
                Spacer()
                Text("\(rep.number)")
            }
        }
    }
    
    @State var showingRangeOfMotionInfo = false
    
    var rangeOfMotionSection: some View {
        var header: some View {
            Text("Range of Motion")
        }
        
        var footer: some View {
            Button("Learn More…") {
                showingRangeOfMotionInfo = true
            }
            .font(.footnote)
        }
        
        return Section(header: header, footer: footer) {
            Picker("", selection: $reps[index].type) {
                ForEach(RepType.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .multilineTextAlignment(.trailing)
            .pickerStyle(.wheel)
        }
        .sheet(isPresented: $showingRangeOfMotionInfo) {
            RangeOfMotionInfo()
        }
    }
    
    var restSection: some View {
        Section("Rest") {
            HStack {
                Toggle("Include", isOn: $reps[index].includeRest)
            }
            if rep.includeRest {
                HStack {
                    Text("Seconds")
                    Spacer()
                    TextField("", value: $reps[index].restTimeInSeconds, formatter: NumberFormatter.init())
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
}

struct SetForm: View {
    @State var reps: [Rep] = MockReps
    
    struct RepIndex: Identifiable {
        let id: Int
        init(_ rep: Int) {
            self.id = rep
        }
    }
    
    var body: some View {
        List {
            ForEach(Array(zip(reps.indices, reps)), id: \.0) { index, rep in
                NavigationLink {
                    RepForm(index: index, reps: $reps)
                } label: {
                    HStack {
                        Text("\(rep.number)")
                            .foregroundStyle(Color(.label))
                            .frame(width: 20)
                        Text(rep.type.shortName)
                            .foregroundStyle(Color(.label))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundStyle(Color(.systemFill))
                            )
//                        if rep.includeRest {
                            HStack(spacing: 0) {
                                Text("C ")
                                    .foregroundStyle(.secondary)
                                Text("1")
                                    .fontDesign(.monospaced)
                                Text("s")
                            }
                            .foregroundStyle(Color(.label))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundStyle(Color(.systemFill))
                            )
                        HStack(spacing: 0) {
                            Text("P ")
                                .foregroundStyle(.secondary)
                            Text("2")
                                .fontDesign(.monospaced)
                            Text("s")
                        }
                        .foregroundStyle(Color(.label))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color(.systemFill))
                        )
                        HStack(spacing: 0) {
                            Text("E ")
                                .foregroundStyle(.secondary)
                            Text("2")
                                .fontDesign(.monospaced)
                            Text("s")
                        }
                        .foregroundStyle(Color(.label))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color(.systemFill))
                        )
                        HStack(spacing: 0) {
                            Text("R ")
                                .foregroundStyle(.secondary)
                            Text("10")
                                .fontDesign(.monospaced)
                            Text("s")
                        }
                        .foregroundStyle(Color(.label))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color(.systemFill))
                        )

//                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Set")
    }
}

struct RangeOfMotionInfo: View {
    var body: some View {
        NavigationView {
            Form {
                Section("Full Range of Motion") {
                    Text("Full range of motion is defined as the act of moving as far as anatomically possible during a given exercise.")
                }
                Section("Lengthened Partials") {
                    Text("Lengthened partials, or long-length partials, are half reps repeatedly performed at the portion of the lift when the muscles are most lengthened.\n\nFor example, the bottom half of the bicep curl or the bottom half of the squat. When performing long-length partials, ideally 50% of the rep should be performed.")
                }
                Section("Shortened Partials") {
                    Text("Shortened partials, or short-length partials, are half reps where 50% of the rep is performed repeatedly when the muscle is at its shortest part.\n\nFor example, the top of bicep curls or the top half of a squat.")
                }
            }
            .navigationTitle("Ranges of Motion")
        }
    }
}

let MockReps: [Rep] = [
    .init(number: 1),
    .init(number: 2),
    .init(number: 3),
    .init(number: 4),
    .init(number: 5),
    .init(number: 6),
    .init(number: 7),
    .init(number: 8),
    .init(number: 9),
    .init(number: 10),
]

#Preview("Workout") {
    Workout()
}

#Preview("Exercise") {
    NavigationView {
        Exercise()
    }
}

#Preview("Set") {
    NavigationView {
        SetForm()
    }
}

struct RepFormTest: View {
    @State var reps = MockReps
    var body: some View {
        NavigationView {
            RepForm(index: 1, reps: $reps)
        }
    }
}

#Preview("Rep") {
    RepFormTest()
}

#Preview("ROM Info") {
    RangeOfMotionInfo()
}
