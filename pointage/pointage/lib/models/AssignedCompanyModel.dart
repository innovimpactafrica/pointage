class AssignedCompanyModel {
    final int id;
    final String? name;

    AssignedCompanyModel({
        required this.id,
                this.name,
    });

    // Factory pour créer depuis JSON
    factory AssignedCompanyModel.fromJson(Map<String, dynamic> json) {
        return AssignedCompanyModel(
                id: json['id'],
                name: json['name'],
    );
    }

    // Conversion en JSON
    Map<String, dynamic> toJson() {
        return {
                'id': id,
                'name': name,
    };
    }
}
