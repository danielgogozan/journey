import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    
    private let MAIN_SCREEN_SEGUE = "MainScreenSegue"
    private var token: String = ""
    private var username: String = ""
    private let userDatabase = UserDatabase()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MAIN_SCREEN_SEGUE,
           let destination = segue.destination as? PoiTableViewController {
            destination.configure(with: self.token, username: username)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        loadingSpinner.isHidden = true
        userDatabase.createTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        passwordTextField.text = ""
        usernameTextField.text = ""
    }
    
    // uncomment this in order to avoid login at every app start
//    override func viewWillAppear(_ animated: Bool) {
//        if let user = userDatabase.getLastLoggedInUser() {
//            print("token from db \(user.token)")
//            self.token = user.token
//            self.username = user.username
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: self.MAIN_SCREEN_SEGUE, sender: self)
//            }
//        }
//    }

    @IBAction func onLoginButtonClick(_ sender: Any) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              !username.isEmpty &&  !password.isEmpty else {
            print("")
            errorLabel.isHidden = false;
            errorLabel.text = Strings.emptyCredentials
            return;
        }
        
        loadingSpinner.isHidden = false
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.startAnimating()
        errorLabel.isHidden = true;
        
        UserWebService().login(username: username, password: password) { [self] result in
            
            DispatchQueue.main.async {
                loadingSpinner.stopAnimating()
            }
        
            switch result {
            case .success(let token):
                print(token)
                self.token = token
                self.username = username
                DispatchQueue.main.async {
                    performSegue(withIdentifier: MAIN_SCREEN_SEGUE, sender: sender)
                }
                userDatabase.save(username: username, password: password, token: token)
            case .failure(let error):
                switch error {
                case .invalidCredentials:
                    DispatchQueue.main.async {
                        errorLabel.text = Strings.invalidCredentials
                    }
                default:
                    DispatchQueue.main.async {
                        errorLabel.text = error.localizedDescription
                    }
                }
                DispatchQueue.main.async {
                    errorLabel.isHidden = false
                }
            }
        }
    }
}
