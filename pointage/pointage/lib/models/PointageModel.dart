class PointageModel {
  final int id;
  final int userId;
  final DateTime datePointage;
  final DateTime? heureArrivee;
  final DateTime? heureDepart;
  final String? typePointage; // 'ARRIVEE' ou 'DEPART'
  final String? statut; // 'PRESENT', 'ABSENT', 'RETARD', 'CONGE'
  final String? commentaire;
  final double? latitude;
  final double? longitude;
  final String? adresse;

  PointageModel({
    required this.id,
    required this.userId,
    required this.datePointage,
    this.heureArrivee,
    this.heureDepart,
    this.typePointage,
    this.statut,
    this.commentaire,
    this.latitude,
    this.longitude,
    this.adresse,
  });

  // Constructeur pour l'API ouvrier (structure PresenceLog)
  factory PointageModel.fromPresenceLog(Map<String, dynamic> json, int userId) {
    final today = DateTime.now();

    // Convertir les listes d'entiers en DateTime
    DateTime? checkIn;
    DateTime? checkOut;

    if (json['checkInTime'] != null &&
        (json['checkInTime'] as List).isNotEmpty) {
      final checkInList = List<int>.from(json['checkInTime']);
      if (checkInList.length >= 3) {
        checkIn = DateTime(
          today.year,
          today.month,
          today.day,
          checkInList[0],
          checkInList[1],
          checkInList[2],
        );
      }
    }

    if (json['checkOutTime'] != null &&
        (json['checkOutTime'] as List).isNotEmpty) {
      final checkOutList = List<int>.from(json['checkOutTime']);
      if (checkOutList.length >= 3) {
        checkOut = DateTime(
          today.year,
          today.month,
          today.day,
          checkOutList[0],
          checkOutList[1],
          checkOutList[2],
        );
      }
    }

    return PointageModel(
      id: json['id'] ?? 0,
      userId: userId,
      datePointage: today,
      heureArrivee: checkIn,
      heureDepart: checkOut,
      typePointage: null,
      statut: null,
      commentaire: null,
      latitude: null,
      longitude: null,
      adresse: null,
    );
  }

  // Constructeur pour l'historique de présence (nouveau format)
  factory PointageModel.fromPresenceHistory(
    Map<String, dynamic> json,
    int userId,
  ) {
    final today = DateTime.now();

    // Convertir les listes d'entiers en DateTime
    DateTime? checkIn;
    DateTime? checkOut;

    if (json['checkInTime'] != null &&
        (json['checkInTime'] as List).isNotEmpty) {
      final checkInList = List<int>.from(json['checkInTime']);
      if (checkInList.length >= 3) {
        checkIn = DateTime(
          today.year,
          today.month,
          today.day,
          checkInList[0],
          checkInList[1],
          checkInList[2],
        );
      }
    }

    if (json['checkOutTime'] != null &&
        (json['checkOutTime'] as List).isNotEmpty) {
      final checkOutList = List<int>.from(json['checkOutTime']);
      if (checkOutList.length >= 3) {
        checkOut = DateTime(
          today.year,
          today.month,
          today.day,
          checkOutList[0],
          checkOutList[1],
          checkOutList[2],
        );
      }
    }

    return PointageModel(
      id: json['id'] ?? 0,
      userId: userId,
      datePointage: today,
      heureArrivee: checkIn,
      heureDepart: checkOut,
      typePointage: null,
      statut: null,
      commentaire: null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      adresse: null,
    );
  }

  // Constructeur standard pour d'autres APIs
  factory PointageModel.fromJson(Map<String, dynamic> json) {
    return PointageModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      datePointage:
          json['datePointage'] != null
              ? DateTime.parse(json['datePointage'])
              : DateTime.now(),
      heureArrivee:
          json['heureArrivee'] != null
              ? DateTime.parse(json['heureArrivee'])
              : null,
      heureDepart:
          json['heureDepart'] != null
              ? DateTime.parse(json['heureDepart'])
              : null,
      typePointage: json['typePointage'],
      statut: json['statut'],
      commentaire: json['commentaire'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'datePointage': datePointage.toIso8601String(),
      'heureArrivee': heureArrivee?.toIso8601String(),
      'heureDepart': heureDepart?.toIso8601String(),
      'typePointage': typePointage,
      'statut': statut,
      'commentaire': commentaire,
      'latitude': latitude,
      'longitude': longitude,
      'adresse': adresse,
    };
  }

  // Calculer les heures travaillées
  Duration? get dureeTravail {
    if (heureArrivee != null && heureDepart != null) {
      return heureDepart!.difference(heureArrivee!);
    }
    return null;
  }

  // Formater la durée en heures:minutes
  String get dureeTravailFormatee {
    final duree = dureeTravail;
    if (duree != null) {
      final heures = duree.inHours;
      final minutes = duree.inMinutes % 60;
      return '${heures}h ${minutes.toString().padLeft(2, '0')}min';
    }
    return 'N/A';
  }
}
