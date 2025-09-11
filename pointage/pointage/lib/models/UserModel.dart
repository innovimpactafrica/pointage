import 'package:pointage/models/CompanyModel.dart';

class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String adress;
  final String? technicalSheet;
  final String profil;
  final bool activated;
  final bool notifiable;
  final String telephone;
  final CompanyModel? company;
  final DateTime createdAt;
  final double funds;
  final double note;
  final String? photo;
  final String? idCard;
  final bool accountNonExpired;
  final bool credentialsNonExpired;
  final bool accountNonLocked;
  final String username;
  // final List<AuthorityModel> authorities;
  final bool enabled;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.adress,
    this.technicalSheet,
    required this.profil,
    required this.activated,
    required this.notifiable,
    required this.telephone,
    // this.subscriptions,
    this.company,
    required this.createdAt,
    required this.funds,
    required this.note,
    this.photo,
    this.idCard,
    required this.accountNonExpired,
    required this.credentialsNonExpired,
    required this.accountNonLocked,
    required this.username,
    // required this.authorities,
    required this.enabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      adress: json['adress'] ?? '',
      technicalSheet: json['technicalSheet'],
      profil: json['profil'] ?? '',
      activated: json['activated'] ?? false,
      notifiable: json['notifiable'] ?? false,
      telephone: json['telephone'] ?? '',
      // subscriptions:
      //     (json['subscriptions'] as List)
      //         .map((e) => SubscriptionModel.fromJson(e))
      //         .toList(),
      company:
          json['company'] != null
              ? CompanyModel.fromJson(json['company'])
              : null,

      createdAt:
          json['createdAt'] != null
              ? DateTime(
                json['createdAt'][0],
                json['createdAt'][1],
                json['createdAt'][2],
                json['createdAt'][3],
                json['createdAt'][4],
                json['createdAt'][5],
              )
              : DateTime.now(),
      funds: (json['funds'] as num?)?.toDouble() ?? 0.0,
      note: (json['note'] as num?)?.toDouble() ?? 0.0,
      photo: json['photo'],
      idCard: json['idCard'],
      accountNonExpired: json['accountNonExpired'] ?? true,
      credentialsNonExpired: json['credentialsNonExpired'] ?? true,
      accountNonLocked: json['accountNonLocked'] ?? true,
      username: json['username'] ?? '',
      // authorities: (json['authorities'] as List)
      //     .map((e) => AuthorityModel.fromJson(e))
      //     .toList(),
      enabled: json['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "password": password,
      "adress": adress,
      "technicalSheet": technicalSheet,
      "profil": profil,
      "activated": activated,
      "notifiable": notifiable,
      "telephone": telephone,
      // "subscriptions": subscriptions.map((e) => e.toJson()).toList(),
      "company": company?.toJson(),

      "createdAt": createdAt.toIso8601String(),
      "funds": funds,
      "note": note,
      "photo": photo,
      "idCard": idCard,
      "accountNonExpired": accountNonExpired,
      "credentialsNonExpired": credentialsNonExpired,
      "accountNonLocked": accountNonLocked,
      "username": username,
      // "authorities": authorities.map((e) => e.toJson()).toList(),
      "enabled": enabled,
    };
  }
}
