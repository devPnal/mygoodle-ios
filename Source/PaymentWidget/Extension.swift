import SwiftUI

extension Float {
   func formatted() -> String {
       let formatter = NumberFormatter()
       formatter.numberStyle = .currency  // 통화 스타일로 변경
       formatter.locale = Locale.current
       
       // 소수점 처리
       if self.truncatingRemainder(dividingBy: 1) == 0 {
           formatter.maximumFractionDigits = 0  // 소수점 이하가 0이면 표시하지 않음
       } else {
           formatter.minimumFractionDigits = 2
           formatter.maximumFractionDigits = 2  // 소수점 둘째자리까지만 표시
       }
       
       let formattedString = formatter.string(from: self as NSNumber) ?? "0"
       
       if Locale.current.currency?.identifier == "KRW" {
          let withoutSymbol = formattedString.replacingOccurrences(of: "₩", with: "")
          return withoutSymbol.trimmingCharacters(in: .whitespaces) + "원"
      } else {
          // 다른 통화의 경우 기본 포맷 사용
          return formattedString
      }
   }
}
