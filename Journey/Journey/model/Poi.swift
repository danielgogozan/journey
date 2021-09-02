import MapKit

struct Poi: Equatable, Codable {
    var _id: String?
    var name: String
    var country: String
    var city: String
    var cost: String
    var notes: String
    var visited: Bool
    var dueDate: String
    var imagePath: String
    var lat: Double
    var long: Double
}

class MKPoi: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(name title: String?, cost subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
