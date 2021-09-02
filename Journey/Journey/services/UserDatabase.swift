import Foundation
import SQLite3

final class UserDatabase {
    
    var database: OpaquePointer?
    var path: String = "journey.sqlite"
    
    init() {
        self.database = createDatabase()
    }
    
    func createDatabase() -> OpaquePointer? {
        let filePath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathExtension(path)
        
        var db: OpaquePointer? = nil
        if sqlite3_open(filePath?.path, &db) != SQLITE_OK {
            print("Error while creating journey db.")
            return nil
        }
        
        print("Journey DB created successfully.")
        return db
    }
    
    func createTable() {
        let query = "CREATE TABLE IF NOT EXISTS users(username TEXT PRIMARY KEY, password TEXT, token TEXT, loginDate DOUBLE);"
        var createTable: OpaquePointer? = nil
        
        if sqlite3_prepare(self.database, query, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) ==  SQLITE_DONE {
                print("Users table created successfully.")
            }
            else {
                print("Users table creation failed.")
            }
            return
        }
        print("Users table preparation failed.")
    }
    
    func save(username: String, password: String, token: String) {
        let query = "INSERT OR REPLACE INTO users(username, password, token, loginDate) VALUES(?, ?, ?, ?);"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (password as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (token as NSString).utf8String, -1, nil)
            print("time: \(Date().timeIntervalSinceReferenceDate)")
            sqlite3_bind_double(statement, 4, Date().timeIntervalSinceReferenceDate)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("User data inserted successfully.")
            }
            else {
                print("User data insertion failed.")
            }
            return
        }
        print("Insert query preparation failed. It might be a query syntax error.")
    }
    
    func getLastLoggedInUser() -> User? {
        let query = "SELECT * FROM users order by loginDate DESC LIMIT 1;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let username = String(cString: sqlite3_column_text(statement, 0))
                print("[DB] user \(username)")
                let password = String(cString: sqlite3_column_text(statement, 1))
                print("[DB] password \(password)")
                let token = String(cString: sqlite3_column_text(statement, 2))
                print("[DB] token \(token)")
                return User(username: username, password: password, token: token)
            }
        }
        else {
            print("Get last logged in user by username query failed. It might be a query syntax error.")
            return nil
        }
        print("No logged in username found.")
        return nil
    }
    
    func getUserByUsername(username: String) -> User? {
        let query = "SELECT * FROM users WHERE username=?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let username = String(cString: sqlite3_column_text(statement, 0))
                print("[DB] user \(username)")
                let password = String(cString: sqlite3_column_text(statement, 1))
                print("[DB] password \(password)")
                let token = String(cString: sqlite3_column_text(statement, 2))
                print("[DB] token \(token)")
                return User(username: username, password: password, token: token)
            }
        }
        else {
            print("Get user by username query failed. It might be a query syntax error.")
            return nil
        }
        print("No username found.")
        return nil
    }
    
    // method won't work. seems like there might be some compatibilities issues
    func deleteByUsername(username: String) -> Bool {
        // let query = "DELETE FROM users"
        let query = "DELETE FROM users where username='a';"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.database, query, -1, &statement, nil) == SQLITE_OK {
         //sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("User deleted successfully.")
                return true
            }
            else{
                print("Delete failed from unknown reasons.")
                return false
            }
        }
        print("Delete user by username query failed. It might be a query syntax error.")
        return false
    }
    
    // method won't work. seems like there might be some compatibilities issues
    func deleteByUsername2(username: String) {
        let deleteStatementStirng = "DELETE FROM users WHERE username = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.database, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (username as NSString).utf8String, -1, nil)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
        print("delete")
    }
}
