class TaskModel {
  final int id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final RealEstateProperty? realEstateProperty;
  final List<Executor> executors;
  final List<String> pictures;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TaskDocument> documents;
  final String? author;
  final String? promoterName;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.realEstateProperty,
    required this.executors,
    required this.pictures,
    this.startDate,
    this.endDate,
    required this.documents,
    this.author,
    this.promoterName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String? promoterName;
    try {
      if (json['realEstateProperty'] != null &&
          json['realEstateProperty']['promoter'] != null) {
        final promoter = json['realEstateProperty']['promoter'];
        final prenom = promoter['prenom'] ?? '';
        final nom = promoter['nom'] ?? '';
        promoterName = ('$prenom $nom').trim();
        print('[DEBUG] promoterName: $promoterName');
      } else {
        print('[DEBUG] Pas de promoteur trouvé pour la tâche id=${json['id']}');
      }
    } catch (e) {
      print('[DEBUG] Erreur extraction promoteur: $e');
    }
    List<TaskDocument> documents = [];
    if (json['documents'] != null && json['documents'] is List) {
      documents =
          (json['documents'] as List)
              .map((e) => TaskDocument.fromJson(e))
              .toList();
    }
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      realEstateProperty:
          json['realEstateProperty'] != null
              ? RealEstateProperty.fromJson(json['realEstateProperty'])
              : null,
      executors:
          (json['executors'] as List? ?? [])
              .map((e) => Executor.fromJson(e))
              .toList(),
      pictures:
          (json['pictures'] as List? ?? []).map((e) => e.toString()).toList(),
      startDate:
          json['startDate'] != null
              ? DateTime(
                json['startDate'][0],
                json['startDate'][1],
                json['startDate'][2],
                json['startDate'][3],
                json['startDate'][4],
              )
              : null,
      endDate:
          json['endDate'] != null
              ? DateTime(
                json['endDate'][0],
                json['endDate'][1],
                json['endDate'][2],
                json['endDate'][3],
                json['endDate'][4],
              )
              : null,
      documents: documents,
      author: json['author'] ?? json['authorName'] ?? null,
      promoterName: promoterName,
    );
  }
}

class RealEstateProperty {
  final int id;
  final String name;

  RealEstateProperty({required this.id, required this.name});

  factory RealEstateProperty.fromJson(Map<String, dynamic> json) {
    return RealEstateProperty(id: json['id'], name: json['name'] ?? '');
  }
}

class Executor {
  final int id;
  final String prenom;
  final String nom;
  final String telephone;

  Executor({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
  });

  factory Executor.fromJson(Map<String, dynamic> json) {
    return Executor(
      id: json['id'],
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
    );
  }
}

class TaskDocument {
  final int id;
  final String libelle;
  final String filePath;

  TaskDocument({
    required this.id,
    required this.libelle,
    required this.filePath,
  });

  factory TaskDocument.fromJson(Map<String, dynamic> json) {
    return TaskDocument(
      id: json['id'],
      libelle: json['libelle'] ?? '',
      filePath: json['filePath'] ?? '',
    );
  }
}
