struct Folder: Decodable {
    
    let id: Int
    let name: String
    let createdAt: String
    let updatedAt: String
    let childFolders: [Folder]
    let childFiles: [File]
    
}
