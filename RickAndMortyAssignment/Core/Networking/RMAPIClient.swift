//
//  RMAPIClient.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 13/09/2025.
//

import Foundation

struct RickAndMortyAPIClientConfig {
    let baseURL: URL
    let timeout: TimeInterval = 20
    let retries: Int = 2
    let backoff: (Int) -> TimeInterval = { attempt in pow(2.0, Double(attempt)) * 0.4 }

    var urlSessionConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = max(60, timeout)
        return config
    }

    init(baseURL: URL = AppEnvironment.production.apiBaseURL) {
        self.baseURL = baseURL
    }
}

struct HTTPResult {
    let data: Data
    let response: HTTPURLResponse
}

protocol APIClient {
    func invoke<Response: Decodable>(_ operration: APIOperation) async throws -> Response
}

final class RMAPIClient: APIClient {
    private let config: RickAndMortyAPIClientConfig
    private let session: URLSession

    init(config: RickAndMortyAPIClientConfig = .init(), session: URLSession? = nil) {
        self.config = config
        self.session = session ?? URLSession(configuration: config.urlSessionConfiguration)
    }

    func invoke<Response: Decodable>(_ operration: APIOperation) async throws -> Response {
        do {
            let url = try buildURL(operation: operration)
            let request = try buildRequest(url: url, operation: operration)
            let result = try await send(request, maxRetries: config.retries)

            guard operration.acceptableStatus.contains(result.response.statusCode) else {
                throw APIError.serverError(status: result.response.statusCode, data: result.data)
            }

            let responseData: Response = try decodeReponse(result.data)
            return responseData

        } catch {
            print(error)
            throw error
        }
    }

    private func send(_ request: URLRequest, maxRetries: Int) async throws -> HTTPResult {
        for attempt in 0 ... maxRetries {
            do {
                let (data, urlResponse) = try await session.data(for: request)
                guard let http = urlResponse as? HTTPURLResponse else { throw APIError.invalidResponse }

                if (200 ..< 300).contains(http.statusCode) {
                    return HTTPResult(data: data, response: http)
                }

                // Too Many Requests
                if http.statusCode == 429, attempt < maxRetries {
                    try await sleep(seconds: config.backoff(attempt))
                    continue
                }

                if isRetriableStatus(http.statusCode), attempt < maxRetries {
                    try await sleep(seconds: config.backoff(attempt))
                    continue
                }

                return HTTPResult(data: data, response: http)
            } catch {
                if error is CancellationError { throw APIError.cancelled }
                if let urlError = error as? URLError, isTransient(urlError.code), attempt < maxRetries {
                    try await sleep(seconds: config.backoff(attempt))
                    continue
                }
                throw (error as? URLError).map(APIError.requestFailed) ?? error
            }
        }
        throw APIError.invalidResponse
    }

    // MARK: Builders

    private func buildRequest(url: URL, operation: APIOperation) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = operation.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        operation.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        if operation.body != nil {
            urlRequest.httpBody = try operation.encodeBody()
        }

        return urlRequest
    }

    // MARK: Helpers

    private func buildURL(operation: APIOperation) throws -> URL {
        // absoluteURL could be used in pageated apis
        if let absoluteURL = operation.absoluteURL {
            // prevent accidental cross-domain fetches
            guard absoluteURL.host == config.baseURL.host else { throw APIError.invalidURL }
            return absoluteURL
        } else {
            var URLComponents = URLComponents(
                url: config.baseURL.appendingPathComponent(operation.path),
                resolvingAgainstBaseURL: false
            )
            URLComponents?.queryItems = operation.query.isEmpty ? nil : operation.query
            guard let composedURL = URLComponents?.url else { throw APIError.invalidURL }
            return composedURL
        }
    }

    private func decodeReponse<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private func isRetriableStatus(_ code: Int) -> Bool {
        [500, 502, 503, 504].contains(code)
    }

    private func isTransient(_ code: URLError.Code) -> Bool {
        switch code {
        case .timedOut,
             .cannotConnectToHost,
             .networkConnectionLost,
             .dnsLookupFailed,
             .notConnectedToInternet: true
        default: false
        }
    }

    private func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
