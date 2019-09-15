class Description: Decodable {
    
    let id: Int
    let index: Int
    let text: String
    let fileId: Int
    let createdAt: String
    let updatedAt: String
    let targets: [DescriptionTarget]
    let questions: [Question]
    
}
