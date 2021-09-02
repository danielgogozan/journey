import UIKit

class EditNameCell: UITableViewCell {
    typealias NameChangeAction = (String) -> Void
    typealias VisitedChangeAction = (Bool) -> Void

    @IBOutlet var nameLabel: UITextField!
    private var nameChangeAction: NameChangeAction?
    
    @IBOutlet var checkButton: UIButton!
    private var visitedChangeAction: VisitedChangeAction?
    private var visited: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.delegate = self
    }

    func configure(name: String, visited: Bool, nameChangeAction: @escaping NameChangeAction, visitedChangeAction: @escaping VisitedChangeAction) {
        self.nameLabel.text = name
        self.nameChangeAction = nameChangeAction
        self.visitedChangeAction = visitedChangeAction
        self.visited = visited
        setButtonImage()
    }
    
    @IBAction func onCheckboxClick(_ sender: Any) {
        visited.toggle()
        setButtonImage()
        visitedChangeAction?(visited)
    }
    
    private func setButtonImage() {
        let buttonImage = visited ? UIImage(named:  "visited") : UIImage(named: "unchecked")
        checkButton.setImage(buttonImage, for: .normal)
    }
}

extension EditNameCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            let name = (oldText as NSString).replacingCharacters(in: range, with: string)
            nameChangeAction?(name)
        }
        return true
    }
}
