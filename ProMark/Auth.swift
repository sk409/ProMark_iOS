import Foundation

class Auth {
    
    static let shared = Auth()
    
    private static let userIdKey = "AUTH_USER_ID"
    
    private(set) var user: User?
    
    func register(userName: String, emailAddress: String, password: String, completion: ((User?) -> Void)? = nil) {
        guard !isLoggedIn() else {
            completion?(nil)
            return
        }
        let parameters = [
            URLQueryItem(name: "name", value: userName),
            URLQueryItem(name: "email", value: emailAddress),
            URLQueryItem(name: "password", value: password),
        ]
        HTTP().async(route: .init(api: .register), parameters: parameters) { response in
            guard let response = response else {
                completion?(nil)
                return
            }
            guard let userId = String(data: response, encoding: .utf8) else {
                completion?(nil)
                return
            }
            let parameters = [
                URLQueryItem(name: "id", value: userId)
            ]
            HTTP().async(route: .init(resource: .users, name: .index), parameters: parameters) { response in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                //print(String(data: response, encoding: .utf8))
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let user = (try? jsonDecoder.decode([User].self, from: response))?.first else {
                    completion?(nil)
                    return
                }
                self.user = user
                UserDefaults.standard.set(user.id, forKey: Auth.userIdKey)
                completion?(self.user)
            }
        }
    }
    
    func login(emailAddress: String, password: String, completion: ((User?) -> Void)? = nil) {
        let parameters = [
            URLQueryItem(name: "email", value: emailAddress),
            URLQueryItem(name: "password", value: password)
        ]
        HTTP().async(route: .init(api: .login), parameters: parameters) { response in
            guard let response = response else {
                completion?(nil)
                return
            }
            guard let userId = String(data: response, encoding: .utf8) else {
                completion?(nil)
                return
            }
            let parameters = [
                URLQueryItem(name: "id", value: userId)
            ]
            HTTP().async(route: .init(resource: .users, name: .index), parameters: parameters) { response in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                //print(String(data: response, encoding: .utf8))
                guard let user = (try? jsonDecoder.decode([User].self, from: response))?.first else {
                    completion?(nil)
                    return
                }
                UserDefaults.standard.set(user.id, forKey: Auth.userIdKey)
                self.user = user
                completion?(self.user)
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: Auth.userIdKey)
    }
    
    func isLoggedIn() -> Bool {
        // TODO: ユーザが削除されていないことを確認
        return UserDefaults.standard.value(forKey: Auth.userIdKey) != nil
    }
    
    func fetchUser(completion: ((User?) -> Void)? = nil) {
        guard let userId = UserDefaults.standard.value(forKey: Auth.userIdKey) as? Int else {
            completion?(nil)
            return
        }
        let parameters = [
            URLQueryItem(name: "id", value: String(userId))
        ]
        HTTP().async(route: .init(resource: .users, name: .index), parameters: parameters) { response in
            defer {
                completion?(self.user)
            }
            guard let response = response else {
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let users = try? jsonDecoder.decode([User].self, from: response) else {
                return
            }
            guard users.count == 1 else {
                return
            }
            self.user = users.first
        }
    }
    
    private init() {
        let semaphore = DispatchSemaphore(value: 0)
        fetchUser() { _ in
            semaphore.signal()
        }
        semaphore.wait()
    }
    
}
