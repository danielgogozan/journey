import Foundation

class DateUtils {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return formatter
    }()
    
    public static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    //converting a string pattern dd.MM.yyyy to a date
    public static func convertStringToDate(from string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return string.isEmpty ? dateFormatter.date(from: dateFormatter.string(from: Date()))! : dateFormatter.date(from: string)!
    }
    
    public static func fancyDateString(string: String) -> String {
        return DateUtils.dateFormatter.string(from: DateUtils.formatter.date(from: string) ?? Date())
    }
    
    public static func compareStrings(date1: String, date2: String) -> Bool {
        return convertStringToDate(from: date1).compare(convertStringToDate(from: date2)).rawValue < 0
    }
}
