import UIKit

class EditPlaceCell: UITableViewCell {
    
    typealias CityChangeAction = (String) -> Void
    typealias CountryChangeAction = (String) ->Void
    private let cityRestorationId = "City"
    private let countryRestorationid = "Country"
    
    @IBOutlet var cityField: UITextField!
    @IBOutlet var countryField: UITextField!
    private var cityChangeAction: CityChangeAction?
    private var countryChangeAction: CountryChangeAction?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cityField.delegate = self
        countryField.delegate = self
    }
    
    func configure(city: String, Country: String, cityChangeAction: @escaping CityChangeAction, countryChangeAction: @escaping CountryChangeAction) {
        self.cityField.text = city
        self.countryField.text = Country
        self.cityChangeAction = cityChangeAction
        self.countryChangeAction = countryChangeAction
    }
}

extension EditPlaceCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            let place = (oldText as NSString).replacingCharacters(in: range, with: string)
            
            switch textField.restorationIdentifier {
            case self.cityRestorationId:
                cityChangeAction?(place)
            case self.countryRestorationid:
                countryChangeAction?(place)
            case .none, .some(_):
                return true
            }
        }
        return true
    }
}
