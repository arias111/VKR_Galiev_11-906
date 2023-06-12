//
//  DocumentCellModel.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 13.05.2023.
//

import UIKit

struct DocumentCellModel {
    let docUrl: String
    let type: DocumentType
    let countOfType: Int
}

struct DocumentUrls {
    let previewItems: [URL]
    let type: DocumentType
}
