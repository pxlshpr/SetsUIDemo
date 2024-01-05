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
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    Exercise()
                } label: {
                    Text("Walking Lunges")
                }
                NavigationLink {
                    
                } label: {
                    Text("Leg Extensions")
                }
            }
            .navigationTitle("Workout")
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
            infoButton
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
    
    var infoButton: some View {
        Button {
            setShowingFormFor = set
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
            "Full ROM"
        case .partialLongLength:
            "Partial ROM (Long Length)"
        case .partialShortLength:
            "Partial ROM (Half Length)"
        }
    }
    
    var shortName: String {
        switch self {
        case .fullRangeOfMotion:
            "Full ROM"
        case .partialLongLength:
            "Partial (Long Length)"
        case .partialShortLength:
            "Partial (Half Length)"
        }
    }
}

struct RepForm: View {

    let index: Int
    @Binding var reps: [Rep]
//    @Binding var rep: Rep
    
    var body: some View {
//        NavigationView {
            Form {
                Section {
                    repRow
                    rangeOfMotionRow
                    includeRestRow
                    restTimeRow
                }
            }
            .navigationTitle("Rep")
//        }
    }
    
    var rep: Rep {
        reps[index]
    }
    
    var repRow: some View {
        HStack {
            Text("Rep")
            Spacer()
            Text("\(rep.number)")
        }
    }
    
    var rangeOfMotionRow: some View {
        HStack {
            Picker("Range of Motion", selection: $reps[index].type) {
                ForEach(RepType.allCases, id: \.self) {
                    Text($0.shortName)
                }
            }
            .multilineTextAlignment(.trailing)
            .pickerStyle(.menu)
        }
    }
    
    var includeRestRow: some View {
        HStack {
            Toggle("Intra-set Rest", isOn: $reps[index].includeRest)
        }
    }
    
    @ViewBuilder
    var restTimeRow: some View {
        if rep.includeRest {
            HStack {
                Text("Rest (seconds)")
                Spacer()
                TextField("", value: $reps[index].restTimeInSeconds, formatter: NumberFormatter.init())
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct SetForm: View {
    @State var reps: [Rep] = [
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
    
    @State var presentedRepIndex: RepIndex? = nil
    
    struct RepIndex: Identifiable {
        let id: Int
        init(_ rep: Int) {
            self.id = rep
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(zip(reps.indices, reps)), id: \.0) { index, rep in
                    NavigationLink {
//                        presentedRepIndex = RepIndex(index)
                        RepForm(index: index, reps: $reps)
                    } label: {
                        HStack {
                            Text("\(rep.number)")
                                .foregroundStyle(Color(.label))
                                .frame(width: 50)
                            Text(rep.type.shortName)
                                .foregroundStyle(Color(.label))
                            Spacer()
                            if rep.includeRest {
                                Text("\(rep.restTimeInSeconds) s")
                                    .foregroundStyle(Color(.label))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Set")
            .sheet(item: $presentedRepIndex) { index in
                RepForm(index: index.id, reps: $reps)
            }
        }
    }
}

//struct SetRepsForm: View {
//    
//    @State var reps: [Rep] = [
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//        .init(),
//    ]
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                ForEach(Array(zip(reps.indices, $reps)), id: \.0) { index, $rep in
//                    Section {
//                        RepSection(index: index, rep: $rep)
//                    }
//                }
//            }
//            .navigationTitle("Set")
//        }
//    }
//}

#Preview("Workout") {
    Workout()
}

#Preview("Exercise") {
    NavigationView {
        Exercise()
    }
}

#Preview("Set") {
    SetForm()
}