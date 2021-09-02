import Foundation

struct User: Codable, Equatable{
    var username: String
    var password: String
    var token: String
    
    init(username: String, password: String, token: String) {
        self.username = username
        self.password = password
        self.token = token
    }
}
