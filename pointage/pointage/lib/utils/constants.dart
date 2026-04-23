class PointageConstants {
  // API Endpoints - Utilise les mêmes que le profil ouvrier
  static const String BASE_URL = 'https://innov.sn/pointage/api';
  static const String BASE_URL_FILE = 'https://innov.sn/pointage/repertoire_u/';
  static const String LOGIN_ENDPOINT = '/v1/auth/signin';
  static const String REGISTER_ENDPOINT = '/v1/auth/signup';
  static const String USER_PROFILE_ENDPOINT = '/v1/user/me';
  static const String POINTAGE_ENDPOINT =
      '/workers'; // Base pour les endpoints de pointage
  static const String POINTAGE_HISTORY_ENDPOINT =
      '/workers'; // Base pour l'historique

  // Storage Keys - Utilise les mêmes que le profil ouvrier
  static const String AUTH_TOKEN = 'gestionchantier_token';
  static const String REFRESH_TOKEN = 'newgestionchantier_token';
  static const String USER_DATA = 'pointage_user_data';
  static const String REMEMBER_ME = 'pointage_remember_me';
  static const String LAST_ACTIVITY_DATE = 'pointage_last_activity_date';
  
  // Session
  static const int SESSION_EXPIRY_DAYS = 20; // Expiration après 20 jours d'inactivité

  // Pointage Types
  static const String ARRIVEE = 'ARRIVEE';
  static const String DEPART = 'DEPART';

  // Statuts
  static const String PRESENT = 'PRESENT';
  static const String ABSENT = 'ABSENT';
  static const String RETARD = 'RETARD';
  static const String CONGE = 'CONGE';

  // Heures de travail
  static const int HEURE_DEBUT_TRAVAIL = 8; // 8h00
  static const int HEURE_FIN_TRAVAIL = 17; // 17h00
  static const int MINUTES_TOLERANCE_RETARD = 15; // 15 minutes de tolérance

  // Messages
  static const String LOGIN_SUCCESS = 'Connexion réussie';
  static const String LOGIN_ERROR = 'Erreur de connexion';
  static const String REGISTER_SUCCESS = 'Inscription réussie';
  static const String REGISTER_ERROR = 'Erreur d\'inscription';
  static const String POINTAGE_SUCCESS = 'Pointage enregistré';
  static const String POINTAGE_ERROR = 'Erreur lors du pointage';

  // Validation
  static const int MIN_PASSWORD_LENGTH = 6;
  static const String EMAIL_REGEX = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';



  static const String PRIMARY_COLOR="#123556";
}
