import SwiftUI

struct AddPageView: View {
    @State var genreId = 0
    @State var title = ""
    @State var cycleType = 0
    @State var cycleMM = 0
    @State var cycleDD = 1
    @State var price: Float?
    @EnvironmentObject var subs: GlobalSub
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                SubscriptionForm
                AddButton
                Spacer()
            }
            .padding()
            .navigationTitle("새 정기 결제 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { CloseButton }
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
            if (cycleType == 1) { cycleMM = 0 }
        }
    }
    
    private var DatePickers: some View {
        Group {
            Picker("월", selection: $cycleMM) {
                ForEach(1..<13) { Text("\($0)").tag($0) }
            }
            .disabled(cycleType == 0)
            .opacity(cycleType == 0 ? 0.3 : 1)
            .onChange(of: cycleType) { cycleMM = 0; }
            Text("월").onTapGesture {
                isFocused = false
            }
            .disabled(cycleType == 0)
            .opacity(cycleType == 0 ? 0.3 : 1)
            
            Picker("일", selection: $cycleDD) {
                ForEach(1..<32) { Text("\($0)").tag($0) }
            }
            Text("일").onTapGesture {
                isFocused = false
            }
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
    
    private var AddButton: some View {
        Button(action: addSubscription) {
            Text("정기 결제 추가하기")
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
    
    private func addSubscription() {
        let cycleNumber = String(format: "%02d%02d", cycleMM, cycleDD)
        guard let finalPrice = price else { return }
        subs.addSubscription(
            genreId: genreId,
            title: title,
            cycleNumber: cycleNumber,
            price: finalPrice
        )
        dismiss()
    }
}
