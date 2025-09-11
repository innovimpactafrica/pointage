class CompanyModel {
  final int id;
  final String? name;
  final String? logo;
  final String? primaryColor;
  final String? secondaryColor;

  CompanyModel({
    required this.id,
    this.name,
    this.logo,
    this.primaryColor,
    this.secondaryColor,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "logo": logo,
      "primaryColor": primaryColor,
      "secondaryColor": secondaryColor,
    };
  }
}
