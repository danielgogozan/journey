import UIKit
import MapKit

protocol MapSearchHandler {
    func dropPinToLocation(placemark: MKPlacemark)
}

class MapCell: UITableViewCell {
    
    // lat, long, name, city, country
    typealias LocationChangeAction = (Double, Double, String, String, String) -> Void
    @IBOutlet var mapView: MKMapView!
    
    private var locationChangeAction: LocationChangeAction?
    private var placemark: MKPlacemark?
    
    func configureForView(with poi: Poi) {
        configureMap(lat: poi.lat, long: poi.long, name: poi.name, cost: poi.cost)
    }
    
    // ADD OR EDIT
    func configureForEdit(with poi: Poi, locationController: LocationSearchViewController?, completion: @escaping LocationChangeAction) {
        self.locationChangeAction = completion
        locationController?.configure(mapView: mapView)
        locationController?.handleMapSearchDelegate = self
        configureMap(lat: poi.lat, long: poi.long, name: poi.name, cost: poi.cost)
    }
    
    func configureMap(lat: Double, long: Double, name: String = "You are here", cost: String = "") {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.placemark = MKPlacemark(coordinate: location)
        mapView.addAnnotation(MKPoi(name: name, cost: cost, coordinate: location))
        mapView.setCenteredLocation(location: CLLocation(latitude: lat, longitude: long))
        //        setupMapGesture()
    }
    
    // disabled for the moment
    // alternative method for setting a new location based on map gestures
    func setupMapGesture(){
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleMapClick(gestureReconizer:)))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //searchBar.isHidden = true
        self.mapView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc
    func handleMapClick(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            let touchLocation = gestureReconizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            print("lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            //locationChangeAction?(Double(locationCoordinate.latitude), Double(locationCoordinate.longitude))
            return
        }
        
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            return
        }
    }
}

private extension MKMapView {
    func setCenteredLocation(location: CLLocation, regionRadius: CLLocationDistance = 700) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension MapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //is user location
            return nil
        }
        let reusePinId = "PIN"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusePinId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusePinId)
        pinView?.canShowCallout = true
        pinView?.pinTintColor = UIColor(named: "Main Color")
        
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 35)))
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.addTarget(self, action: #selector(self.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    @objc
    func getDirections() {
        if let selectedLocation = placemark {
            let mapItem = MKMapItem(placemark: selectedLocation)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}

extension MapCell : MapSearchHandler {
    func dropPinToLocation(placemark: MKPlacemark) {
        self.placemark = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.title
        
        if let city = placemark.locality,
           let country = placemark.country {
            annotation.subtitle = "\(city) \(country)"
        }
         
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: placemark.coordinate, latitudinalMeters: 0.05, longitudinalMeters: 0.05)
        mapView.setRegion(region, animated: true)
        self.locationChangeAction?(placemark.coordinate.latitude, placemark.coordinate.longitude, placemark.title ?? "", placemark.locality ?? "", placemark.country ?? "")
    }
}
