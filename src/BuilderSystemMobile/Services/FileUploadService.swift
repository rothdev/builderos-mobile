import Foundation

enum FileUploadError: Error {
    case invalidURL
    case uploadFailed(String)
    case networkError(Error)
}

@MainActor
class FileUploadService: ObservableObject {
    @Published var uploadProgress: [UUID: Double] = [:]

    private let baseURL: String
    private let session: URLSession

    init(baseURL: String = "https://api.builderos.dev") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }

    func uploadFile(_ attachment: FileAttachment, to endpoint: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw FileUploadError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = createMultipartBody(
            boundary: boundary,
            data: attachment.data,
            mimeType: attachment.mimeType,
            filename: attachment.filename
        )

        request.httpBody = httpBody

        do {
            // Track upload progress
            uploadProgress[attachment.id] = 0.0

            let (data, response) = try await session.upload(for: request, from: httpBody)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw FileUploadError.uploadFailed("Invalid response")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw FileUploadError.uploadFailed("HTTP \(httpResponse.statusCode)")
            }

            uploadProgress[attachment.id] = 1.0

            // Parse response
            if let responseString = String(data: data, encoding: .utf8) {
                return responseString
            } else {
                return "Upload successful"
            }
        } catch {
            uploadProgress[attachment.id] = nil
            throw FileUploadError.networkError(error)
        }
    }

    func uploadFiles(_ attachments: [FileAttachment], to endpoint: String) async throws -> [String] {
        var results: [String] = []

        for attachment in attachments {
            let result = try await uploadFile(attachment, to: endpoint)
            results.append(result)
        }

        return results
    }

    private func createMultipartBody(boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        var body = Data()

        let boundaryPrefix = "--\(boundary)\r\n"

        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
