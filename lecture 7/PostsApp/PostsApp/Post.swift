import Foundation

struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct PostComment: Codable, Identifiable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case statusCode(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "სერვერიდან მიღებული პასუხი არასწორია."
        case .statusCode(let code):
            return "მონაცემების ჩატვირთვა ვერ მოხერხდა. შეცდომის კოდი: \(code)"
        }
    }
}

enum APIService {
    static func fetchPosts() async throws -> [Post] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.statusCode(response.statusCode)
        }
        return try JSONDecoder().decode([Post].self, from: data)
    }

    static func fetchComments(for postID: Int) async throws -> [PostComment] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=\(postID)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.statusCode(response.statusCode)
        }
        return try JSONDecoder().decode([PostComment].self, from: data)
    }
}
