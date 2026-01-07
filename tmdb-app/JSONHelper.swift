//
//  JSONHelper.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 05-01-26.
//

//import Foundation
//
//func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T {
//    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
//        fatalError("❌ Could not find \(filename).json in bundle")
//    }
//
//    do {
//        let data = try Data(contentsOf: url)
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        decoder.dateDecodingStrategy = .custom { decoder in
//            let container = try decoder.singleValueContainer()
//            let dateString = try container.decode(String.self)
//
//            // 1️⃣ ISO-8601 WITH fractional seconds
//            let isoWithFractional = ISO8601DateFormatter()
//            isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//
//            if let date = isoWithFractional.date(from: dateString) {
//                return date
//            }
//
//            // 2️⃣ ISO-8601 WITHOUT fractional seconds
//            let isoWithoutFractional = ISO8601DateFormatter()
//            isoWithoutFractional.formatOptions = [.withInternetDateTime]
//
//            if let date = isoWithoutFractional.date(from: dateString) {
//                return date
//            }
//
//            // 3️⃣ Date-only format
//            let dateOnly = DateFormatter()
//            dateOnly.locale = Locale(identifier: "en_US_POSIX")
//            dateOnly.timeZone = TimeZone(secondsFromGMT: 0)
//            dateOnly.dateFormat = "yyyy-MM-dd"
//
//            if let date = dateOnly.date(from: dateString) {
//                return date
//            }
//
//            throw DecodingError.dataCorruptedError(
//                in: container,
//                debugDescription: "Invalid date format: \(dateString)"
//            )
//        }
//
//
//        return try decoder.decode(T.self, from: data)
//
//    } catch {
//        fatalError("❌ Failed to decode \(filename).json: \(error)")
//    }
//}
