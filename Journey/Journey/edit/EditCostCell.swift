import UIKit

class EditCostCell: UITableViewCell {
    typealias CostChangeAction = (String) -> Void

    @IBOutlet var costField: UITextField!
    private var costChangeAction: CostChangeAction?
    
    func configure(cost: String, costChangeAction: @escaping CostChangeAction) {
        self.costField.text = cost
        self.costChangeAction = costChangeAction
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        costField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension EditCostCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            let cost = (oldText as NSString).replacingCharacters(in: range, with: string)
            costChangeAction?(cost)
        }
        return true
    }
}
