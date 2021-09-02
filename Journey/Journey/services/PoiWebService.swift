import UIKit

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case unsuccessfullyDelete
    case nullId
    case authorizationError
}

class PoiWebService {
    
    let GET = "GET"
    let POST = "POST"
    let PUT = "PUT"
    let DELETE = "DELETE"
    let baseUrl = "http://localhost:3000/api/poi"
    
    func getAllPois(token: String, completion: @escaping (Result<[Poi], NetworkError>) -> Void) {
        //1 - creating URL, 2- creating request
        guard let request = createRequest(url: baseUrl, httpMethod: GET, token: token) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 3. sending and handling response
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse,
                 httpResponse.statusCode == 401 {
                completion(.failure(.authorizationError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            guard let pois = try? JSONDecoder().decode([Poi].self, from: data) else {
                completion(.failure(.decodingError))
                return
            }
            
            completion(.success(pois))
        }.resume()
    }
    
    func add(token: String, poi: Poi, completion: @escaping (Result<Poi, NetworkError>) -> Void) {
        guard var request = createRequest(url: baseUrl, httpMethod: POST, token: token) else {
            completion(.failure(.invalidURL))
            return
        }
        request.httpBody = try? JSONEncoder().encode(poi)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            guard let poi = try? JSONDecoder().decode(Poi.self, from: data) else {
                completion(.failure(.decodingError))
                return
            }
            
            completion(.success(poi))
        }.resume()
    }
    
    func update(token: String, poi: Poi, completion: @escaping (Result<Poi, NetworkError>) -> Void) {
        guard let id = poi._id else {
            completion(.failure(.nullId))
            return
        }
        guard var request = createRequest(url: baseUrl + "/" + id, httpMethod: PUT, token: token) else {
            completion(.failure(.invalidURL))
            return
        }
        request.httpBody = try? JSONEncoder().encode(poi)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            guard let poi = try? JSONDecoder().decode(Poi.self, from: data) else {
                completion(.failure(.decodingError))
                return
            }
            completion(.success(poi))
        }.resume()
    }
    
    func delete(token: String, id: String?, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let id = id else {
            completion(.failure(.nullId))
            return
        }
        guard let request = createRequest(url: baseUrl + "/" + id, httpMethod: DELETE, token: token) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                completion(.failure(.unsuccessfullyDelete))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    private func createRequest(url: String, httpMethod: String, token: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
    
    func getPoiImage(path: String?) -> UIImage {
        guard let path = path,
              let imageUrl = URL(string: path) else {
            return UIImage(named: "Image not found")!
        }
        
        if let image = try? Data(contentsOf: imageUrl) {
            return UIImage(data: image) ?? UIImage(named: "Image not found")!
        }
        return UIImage(named: "Image not found")!
    }
}
