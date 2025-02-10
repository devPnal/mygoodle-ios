import SwiftUI

struct EditPageView: View {
    let subscription: Sub
    @State var genreId = 0
    @State var title = ""
    @State var cycleType = 0
    @State var cycleMM = 0
    @State var cycleDD = 1
    @State var price: Float?
    
    @EnvironmentObject var subs: GlobalSub
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(subscription: Sub) {
        self.subscription = subscription
        
        // 초기값 설정
        _genreId = State(initialValue: subscription.genreId)
        _title = State(initialValue: subscription.title)
        _price = State(initialValue: subscription.price)
        
        let cycleNum = Int(subscription.cycleNumber) ?? 0
        if cycleNum < 100 {
            _cycleType = State(initialValue: 0)
            _cycleMM = State(initialValue: 0)
            _cycleDD = State(initialValue: cycleNum)
        } else {
            _cycleType = State(initialValue: 1)
            _cycleMM = State(initialValue: Int(subscription.cycleNumber.prefix(2)) ?? 0)
            _cycleDD = State(initialValue: Int(subscription.cycleNumber.suffix(2)) ?? 1)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                SubscriptionForm
                UpdateButton
                Spacer()
            }
            .padding()
            .navigationTitle("정기 결제 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { CloseButton }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
        }
    }
    
    private var SubscriptionForm: some View {
        VStack(alignment: .leading, spacing: 15) {
            GenreSelection
            ServiceInput
            PaymentDateSelection
            PriceInput
        }
    }
    
    private var GenreSelection: some View {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"
        
        return VStack(alignment: .leading) {
            Text("결제 분야").frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle()).onTapGesture {
                isFocused = false
            }
            Group {
                if isKorean {
                    Picker("분야 선택", selection: $genreId) {
                        ForEach(Genre.allCases, id: \.rawValue) { genre in
                            Text(genre.title).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                } else {
                    Picker("분야 선택", selection: $genreId) {
                        ForEach(Genre.allCases, id: \.rawValue) { genre in
                            Text(genre.title).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
            }
            .onChange(of: genreId) { isFocused = false }
        }
    }
    
    private var ServiceInput: some View {
        VStack(alignment: .leading) {
            Text("결제 서비스").frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle()).onTapGesture {
                isFocused = false
            }
            TextField("유튜브 프리미엄, 정기 적금...", text: $title)
                .textFieldStyle(RoundedTextFieldStyle())
                .focused($isFocused)
        }
    }
    
    private var PaymentDateSelection: some View {
        VStack(alignment: .leading) {
            Text("결제 주기").frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle()).onTapGesture {
                isFocused = false
            }
            HStack {
                CycleTypePicker
                DatePickers
            }
            .frame(height: 100)
        }
    }
    
    private var CycleTypePicker: some View {
        Picker("결제 주기", selection: $cycleType) {
            Text("매달").tag(0)
            Text("매해").tag(1)
        }
        .pickerStyle(.segmented)
        .onChange(of: cycleType) {
            isFocused = false
            if (cycleType == 1) { cycleMM = 1 }
        }
    }
    
    private var DatePickers: some View {
        Group {
            Picker("월", selection: $cycleMM) {
                ForEach(1..<13) { Text("\($0)").tag($0) }
            }
            .disabled(cycleType == 0)
            .opacity(cycleType == 0 ? 0.3 : 1)
            .onChange(of: cycleType) { cycleMM = 0 }
            
            Text("월").onTapGesture { isFocused = false }
                .disabled(cycleType == 0)
                .opacity(cycleType == 0 ? 0.3 : 1)
            
            Picker("일", selection: $cycleDD) {
                ForEach(1..<32) { Text("\($0)").tag($0) }
            }
            Text("일").onTapGesture { isFocused = false }
        }
        .pickerStyle(.wheel)
    }
    
    private var PriceInput: some View {
        VStack(alignment: .leading) {
            Text("결제 금액").frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle()).onTapGesture {
                isFocused = false
            }
            TextField("9,900", value: $price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .textFieldStyle(RoundedTextFieldStyle())
                .keyboardType(.decimalPad)
                .focused($isFocused)
        }
    }
    
    private var UpdateButton: some View {
        Button(action: updateSubscription) {
            Text("정기 결제 수정하기")
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color(red: 29/255, green: 50/255, blue: 82/255))
                .foregroundColor(.white)
                .cornerRadius(6)
        }
    }
    
    private var CloseButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.black)
            }
        }
    }
    
    private func updateSubscription() {
        let cycleNumber = String(format: "%02d%02d", cycleMM, cycleDD)
        subs.updateSubscription(
            id: subscription.id,
            genreId: genreId,
            title: title,
            cycleNumber: cycleNumber,
            price: price!
        )
        dismiss()
    }
}
