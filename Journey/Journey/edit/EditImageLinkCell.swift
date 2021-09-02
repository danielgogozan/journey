import UIKit

class EditImageLinkCell: UITableViewCell {
    typealias ImageLinkChangeAction = (String) -> Void

    @IBOutlet var imageField: UITextField!
    private var imageLinkChangeAction: ImageLinkChangeAction?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageField.delegate = self
    }

    func configure(imageLink: String, imageLinkChangeAction: @escaping ImageLinkChangeAction) {
        self.imageField.text = imageLink
        self.imageLinkChangeAction = imageLinkChangeAction
    }
}

extension EditImageLinkCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            let imageLink = (oldText as NSString).replacingCharacters(in: range, with: string)
            imageLinkChangeAction?(imageLink)
        }
        return true
    }
}
