import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var comments: [PostComment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("კომენტარები იტვირთება...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                ContentUnavailableView {
                    Label("კომენტარები ვერ ჩაიტვირთა", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("ხელახლა ცდა") {
                        Task {
                            await loadComments()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    Section {
                        Text(post.title)
                            .font(.headline)
                        Text(post.body)
                            .font(.body)
                    }
                    Section("კომენტარები") {
                        ForEach(comments) { comment in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(comment.name)
                                    .font(.headline)
                                Text(comment.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(comment.body)
                                    .font(.body)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
        .navigationTitle("პოსტის დეტალები")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadComments()
        }
    }

    @MainActor
    private func loadComments() async {
        isLoading = true
        errorMessage = nil
        do {
            comments = try await APIService.fetchComments(for: post.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
