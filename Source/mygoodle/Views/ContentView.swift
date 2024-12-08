import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subs: GlobalSub
    @State private var stackId = UUID()
    @State private var selectedSub: Sub? = nil
    
    var body: some View {
        NavigationStack {
            List {
                SummarySection(subs: subs)
                SubscriptionsList(
                    subs: subs,
                    selectedSub: $selectedSub
                )
            }
            .navigationTitle("나의 정기 결제")
            .toolbarModifier()
        }
        .id(stackId)
        .sheet(item: $selectedSub) { sub in
            EditPageView(subscription: sub)
                .presentationDragIndicator(.visible)
        }
    }
}

struct SummarySection: View {
    @ObservedObject var subs: GlobalSub
    
    var body: some View {
        Section(
            footer: Text("오늘 내야할 금액은 '이번 달 남은 청구 금액'에 포함됩니다.")
        ) {
            HStack {
                Text("이번 달 총 청구 금액")
                Spacer()
                Text(subs.calculatePlannedMoney().formatted())
            }
            HStack {
                Text("이번 달 남은 청구 금액")
                Spacer()
                Text(subs.calculateLeftMoney().formatted())
            }
        }
    }
}

struct SubscriptionsList: View {
    @ObservedObject var subs: GlobalSub
    @Binding var selectedSub: Sub?
    
    var body: some View {
        ForEach(subs.subs) { sub in
            SubscriptionRow(sub: sub)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        subs.removeSubscription(id: sub.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        selectedSub = sub
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
        }
    }
}

struct SubscriptionRow: View {
    let sub: Sub
    
    var body: some View {
        HStack {
            GenreTag(genre: Genre(rawValue: sub.genreId) ?? .others)
            VStack(alignment: .leading) {
                Text(sub.title).bold()
                Text(LocalizedStringKey(sub.cycleDisplay)).font(.system(size: 14))
            }.padding(.leading, 5)
            Spacer()
            Text(String(sub.price.formatted()))
        }
    }
}

struct GenreTag: View {
    let genre: Genre
    
    private var tagWidth: CGFloat {
        let language = Locale.current.language.languageCode?.identifier ?? ""
        switch language {
        case "ko", "ja", "zh":  // 한국어, 일본어, 중국어
            return 60.0
        default:  // 그 외 언어
            return 74.0
        }
    }
    
    var body: some View {
        Text(genre.title)
            .padding([.leading, .trailing], 10.0)
            .padding([.top, .bottom], 2.0)
            .frame(width: tagWidth)
            .font(.system(size: 14))
            .background(genre.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .foregroundStyle(Color.black)
    }
}

#Preview {
    @Previewable @StateObject var globalSub = GlobalSub()
    ContentView().environmentObject(globalSub)
}
