import UIKit

class EditNotesCell: UITableViewCell {
    typealias NotesChangeAction = (String) -> Void

    @IBOutlet var notesTextView: UITextView!
    private var notesChangeAction: NotesChangeAction?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        notesTextView.delegate = self
    }

    func configure(notes: String, notesChangeAction: @escaping NotesChangeAction) {
        self.notesTextView.text = notes
        self.notesChangeAction = notesChangeAction
    }
}

extension EditNotesCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let oldText = textView.text {
            let notes = (oldText as NSString).replacingCharacters(in: range, with: text)
            notesChangeAction?(notes)
        }
        return true
    }
}
