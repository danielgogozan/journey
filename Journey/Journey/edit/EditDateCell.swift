import UIKit

class EditDateCell: UITableViewCell {
    typealias DateChangeAction = (Date) -> Void

    @IBOutlet var datePicker: UIDatePicker!
    private var dateChangeAction: DateChangeAction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.addTarget(self, action: #selector(dateChanged(_: )), for: .valueChanged)
    }
    
    func configure(date: Date, dateChangeAction: @escaping DateChangeAction) {
        self.datePicker.date = date
        self.dateChangeAction = dateChangeAction
    }
    
    @objc
    func dateChanged(_ sender: UIDatePicker) {
        dateChangeAction?(sender.date)
    }
}

