import UIKit

class PoiTableViewCell: UITableViewCell {

    
    @IBOutlet var poiImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var visitedImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with poi: Poi) {
        self.poiImage.image = PoiWebService().getPoiImage(path: poi.imagePath)
        self.nameLabel.text = poi.name
        self.placeLabel.text = poi.city + ", " + poi.country
        self.dateLabel.text = DateUtils.fancyDateString(string: poi.dueDate)
        if !poi.city.isEmpty {
            self.placeLabel.text = poi.city + ", " + poi.country
        } else {
            self.placeLabel.text = poi.country
        }
        if poi.visited {
            visitedImage.image = UIImage(named: "visited")
        } else {
            visitedImage.image = UIImage(named: "unvisited")
        }
    }

}
