//
//  NetworkService.swift
//  GeofenceReminders
//
//  Created by Macbook Pro on 13/05/2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchLocations() -> AnyPublisher<[Location], Error>
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://overpass-api.de/api/interpreter"
    
    func fetchLocations() -> AnyPublisher<[Location], Error> {
        let query = """
        [out:json];
        node["tourism"="attraction"](around:5000,40.785091,-73.968285);
        out body;
        """
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)".data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: OverpassResponse.self, decoder: JSONDecoder())
            .map { response in
                response.elements.map { element in
                    Location(
                        id: String(element.id),
                        name: element.tags["name"] ?? "Unknown",
                        latitude: element.lat,
                        longitude: element.lon,
                        category: element.tags["tourism"] ?? "Attraction"
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}

struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let id: Int
    let lat: Double
    let lon: Double
    let tags: [String: String]
}
