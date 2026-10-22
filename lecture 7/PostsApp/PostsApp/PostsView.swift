import SwiftUI

struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("იტვირთება...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    ContentUnavailableView {
                        Label("მონაცემები ვერ ჩაიტვირთა", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("ხელახლა ცდა") {
                            Task {
                                await loadPosts()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(posts) { post in
                        NavigationLink(value: post) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(post.title)
                                    .font(.headline)
                                Text(post.body)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: Post.self) { post in
                        PostDetailView(post: post)
                    }
                }
            }
            .navigationTitle("პოსტები")
            .task {
                await loadPosts()
            }
        }
    }

    @MainActor
    private func loadPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await APIService.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

extension Post: Hashable {}
