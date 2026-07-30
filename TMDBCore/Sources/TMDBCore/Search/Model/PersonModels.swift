import Foundation

public struct PersonDetail: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let biography: String
    public let profileURL: URL?
    public let birthday: String?
    public let placeOfBirth: String?
    public let knownForDepartment: String?

    public init(
        id: Int,
        name: String,
        biography: String,
        profileURL: URL?,
        birthday: String?,
        placeOfBirth: String?,
        knownForDepartment: String?
    ) {
        self.id = id
        self.name = name
        self.biography = biography
        self.profileURL = profileURL
        self.birthday = birthday
        self.placeOfBirth = placeOfBirth
        self.knownForDepartment = knownForDepartment
    }
}

extension PersonDetail {
    init(_ dto: PersonDetailDTO) {
        id = dto.id
        name = dto.name
        biography = dto.biography
        profileURL = dto.profilePath.flatMap { Constants.Urls.profile(path: $0) }
        birthday = dto.birthday
        placeOfBirth = dto.placeOfBirth
        knownForDepartment = dto.knownForDepartment
    }
}
