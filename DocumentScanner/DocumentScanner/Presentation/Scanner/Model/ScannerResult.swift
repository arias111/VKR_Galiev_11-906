//
//  ScannerResult.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 25.04.2023.
//
enum DocumentType: String, Codable {
    case visa = "Виза"
    case mk = "mk"
    case document = "Документ"
}

struct ScannerResult: Decodable, Hashable {
    let result: [Results]?
}

struct Results: Decodable, Hashable {
    let original: String?
    let scanPng: String?
    let scanPdf: String?
    let type: DocumentType?

    enum CodingKeys: String, CodingKey {
        case original = "original"
        case scan_png = "scan_png"
        case scan_pdf = "scan_pdf"
        case type = "type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        original = try values.decodeIfPresent(String.self, forKey: .original)
        scanPng = try values.decodeIfPresent(String.self, forKey: .scan_png)
        scanPdf = try values.decodeIfPresent(String.self, forKey: .scan_pdf)
        type = try values.decodeIfPresent(DocumentType.self, forKey: .type)
    }
}
