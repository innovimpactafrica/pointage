import 'package:flutter/material.dart';
import '../../services/AuthService.dart';
import '../../services/PointageService.dart';
import '../../models/UserModel.dart';
import '../../utils/constants.dart';
import '../compte_page.dart';
import '../historique_page.dart';

class PointageHomePage extends StatefulWidget {
  const PointageHomePage({Key? key}) : super(key: key);

  @override
  State<PointageHomePage> createState() => _PointageHomePageState();
}

class _PointageHomePageState extends State<PointageHomePage> {
  final _authService = AuthService();
  final _pointageService = PointageService();

  UserModel? _currentUser;
  Map<String, dynamic> _statutPointage = {
    'peutArrivee': true,
    'peutDepart': false,
    'statut': 'Aucun pointage',
    'heureArrivee': null,
    'heureDepart': null,
  };

  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les données utilisateur
      final userData = await _authService.connectedUser();
      if (userData != null) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
      }

      // Charger le statut de pointage du jour
      if (_currentUser != null) {
        await _loadStatutPointage();
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatutPointage() async {
    try {
      if (_currentUser != null) {
        final statut = await _pointageService.getStatutPointageDuJour(
          _currentUser!.id,
        );
        setState(() {
          _statutPointage = statut;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du statut: $e');
    }
  }

  Future<void> _pointer(String typePointage) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _pointageService.enregistrerPointage(
        userId: _currentUser!.id,
        typePointage: typePointage,
        latitude: null, // Pas de géolocalisation pour l'instant
        longitude: null,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger le statut
        await _loadStatutPointage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Déconnecter',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildHomeTab(), _buildHistoriqueTab(), _buildCompteTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF5C02),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec informations utilisateur
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5C02),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentUser?.prenom ?? ''} ${_currentUser?.nom ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? 'Utilisateur'
                                : '${_currentUser?.prenom ?? ''} ${_currentUser?.nom ?? ''}'
                                    .trim(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.profil ?? 'Employé',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                          if (_currentUser?.username.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Username: ${_currentUser!.username}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C02).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5C02),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section pointage
          const Text(
            'Pointage du jour',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),

          // Boutons de pointage
          Row(
            children: [
              Expanded(
                child: _buildPointageButton(
                  'Arrivée',
                  Icons.login,
                  const Color(0xFF27AE60),
                  _statutPointage['peutArrivee']!,
                  () => _pointer(PointageConstants.ARRIVEE),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPointageButton(
                  'Départ',
                  Icons.logout,
                  const Color(0xFFE74C3C),
                  _statutPointage['peutDepart']!,
                  () => _pointer(PointageConstants.DEPART),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Informations du jour
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Heure d\'arrivée',
                  _statutPointage['heureArrivee'] != null
                      ? 'Pointé'
                      : 'Non pointé',
                ),
                _buildInfoRow(
                  'Heure de départ',
                  _statutPointage['heureDepart'] != null
                      ? 'Pointé'
                      : 'Non pointé',
                ),
                _buildInfoRow('Statut', _getStatutJour()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointageButton(
    String title,
    IconData icon,
    Color color,
    bool isDisabled,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade300 : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey : Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDisabled ? Colors.grey : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isDisabled ? 'Déjà pointé' : 'Pointer',
              style: TextStyle(
                fontSize: 12,
                color: isDisabled ? Colors.grey : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatutJour() {
    if (_statutPointage['heureArrivee'] != null &&
        _statutPointage['heureDepart'] != null) {
      return 'Journée complète';
    } else if (_statutPointage['heureArrivee'] != null) {
      return 'En cours';
    } else {
      return 'Non commencé';
    }
  }

  Widget _buildHistoriqueTab() {
    return PointageHistoriquePage(userId: _currentUser?.id);
  }

  Widget _buildCompteTab() {
    return PointageComptePage(currentUser: _currentUser, onLogout: _logout);
  }
}
