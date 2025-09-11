import 'package:flutter/material.dart';
import '../../services/AuthService.dart';
import '../../models/UserModel.dart';
import '../../services/PointageService.dart';
// import '../../utils/constants.dart';
import '../qr_scanner/qr_scanner_page.dart';

class ModernPointagePage extends StatefulWidget {
  const ModernPointagePage({Key? key}) : super(key: key);

  @override
  State<ModernPointagePage> createState() => _ModernPointagePageState();
}

class _ModernPointagePageState extends State<ModernPointagePage> {
  int _selectedTab = 0;

  void _goToHistorique() {
    setState(() {
      _selectedTab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PointageHeaderTabs(
            selected: _selectedTab,
            onChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(
            child:
                _selectedTab == 0
                    ? _PointageDuJourCard(onVoirPlus: _goToHistorique)
                    : const _HistoriqueTab(),
          ),
        ],
      ),
    );
  }
}

class _PointageHeaderTabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _PointageHeaderTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A365D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
            child: Text(
              'Pointage',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            color:
                                selected == 0
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pointage du jour',
                            style: TextStyle(
                              color:
                                  selected == 0
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          color:
                              selected == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color:
                                selected == 1
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Historiques',
                            style: TextStyle(
                              color:
                                  selected == 1
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          color:
                              selected == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointageDuJourCard extends StatefulWidget {
  final VoidCallback onVoirPlus;

  const _PointageDuJourCard({required this.onVoirPlus});

  @override
  State<_PointageDuJourCard> createState() => _PointageDuJourCardState();
}

class _PointageDuJourCardState extends State<_PointageDuJourCard> {
  final _authService = AuthService();
  final _pointageService = PointageService();
  UserModel? _currentUser;
  bool _isLoading = true;
  String _lastPointageTime = '--:--';
  String _totalWorkedTime = '0h 00min';
  String _checkOutTime = '--:--';

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
      final userData = await _authService.connectedUser();
      if (userData != null) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
        _loadTodayPointage();
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodayPointage() async {
    if (_currentUser == null) return;

    try {
      // Récupérer l'historique complet
      final historique = await _pointageService.getHistoriquePointage(
        userId: _currentUser!.id,
      );

      if (historique.isNotEmpty) {
        // Trouver le pointage d'aujourd'hui
        final today = DateTime.now();
        final todayPointage =
            historique.where((pointage) {
              return pointage.datePointage.year == today.year &&
                  pointage.datePointage.month == today.month &&
                  pointage.datePointage.day == today.day;
            }).toList();

        if (todayPointage.isNotEmpty) {
          final pointage = todayPointage.first;
          setState(() {
            // Formater l'heure d'arrivée
            if (pointage.heureArrivee != null) {
              _lastPointageTime =
                  '${pointage.heureArrivee!.hour.toString().padLeft(2, '0')}:${pointage.heureArrivee!.minute.toString().padLeft(2, '0')}';
            }

            // Formater l'heure de départ
            if (pointage.heureDepart != null) {
              _checkOutTime =
                  '${pointage.heureDepart!.hour.toString().padLeft(2, '0')}:${pointage.heureDepart!.minute.toString().padLeft(2, '0')}';
            }

            // Calculer le temps total travaillé
            if (pointage.dureeTravail != null) {
              _totalWorkedTime = pointage.dureeTravailFormatee;
            }
          });
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du pointage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        children: [
          const Text(
            'Pointage du jour',
            style: TextStyle(
              color: Color(0xFF1A365D),
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF1A365D),
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _lastPointageTime == '--:--'
                        ? "Pas encore pointé aujourd'hui"
                        : "Pointé aujourd'hui à $_lastPointageTime",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8A98A8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 260,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    QRScannerPage(workerId: _currentUser!.id),
                          ),
                        );

                        // Recharger les données après le pointage
                        if (result == true) {
                          _loadTodayPointage();
                        }
                      },
                      icon: const Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'Scanner QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Section Historiques de présence
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historiques de présence',
                      style: TextStyle(
                        color: Color(0xFF1A365D),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onVoirPlus,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5C02),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Voir plus',
                        style: TextStyle(
                          color: Color(0xFFFF5C02),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFFF5C02), width: 4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTodayDateString(),
                          style: const TextStyle(
                            color: Color(0xFF1A365D),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_lastPointageTime == '--:--')
                          const Text(
                            'Pas encore de pointage aujourd\'hui',
                            style: TextStyle(
                              color: Color(0xFF8A98A8),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          _SessionCard(
                            entree: _lastPointageTime,
                            sortie: _checkOutTime,
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total: $_totalWorkedTime',
                              style: const TextStyle(
                                color: Color(0xFF1A365D),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    final months = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    final weekDays = ['Dim.', 'Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.'];
    return '${weekDays[now.weekday % 7]} ${now.day.toString().padLeft(2, '0')} ${months[now.month]} ${now.year}';
  }
}

class _SessionCard extends StatelessWidget {
  final String? entree;
  final String? sortie;

  const _SessionCard({this.entree, this.sortie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, size: 20, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 4),
                    const Text(
                      'Entrée:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entree ?? '--:--',
                      style: const TextStyle(
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      size: 20,
                      color: Color(0xFFFF5C02),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Sortie:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sortie ?? '--:--',
                      style: const TextStyle(
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F9ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Présent',
              style: TextStyle(
                color: Color(0xFF3DD598),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoriqueTab extends StatelessWidget {
  const _HistoriqueTab();

  @override
  Widget build(BuildContext context) {
    // Données d'exemple pour l'historique
    final historiques = [
      {
        'mois': 'Juillet 2025',
        'total': '87h 26',
        'jours': [
          {'date': 'Mer. 16 juil. 2025', 'total': '11h 20min'},
          {'date': 'Mar. 15 juil. 2025', 'total': '8h 40min'},
          {'date': 'Lun. 14 juil. 2025', 'total': '8h 30min'},
          {'date': 'Ven. 11 juil. 2025', 'total': '8h 45min'},
          {'date': 'Jeu. 10 juil. 2025', 'total': '8h 00min'},
          {'date': 'Mer. 09 juil. 2025', 'total': '09h 04min'},
        ],
      },
      {
        'mois': 'Juin 2025',
        'total': '151h 36',
        'jours': [
          {'date': 'Lun. 30 juin 2025', 'total': '8h 58min'},
          {'date': 'Ven. 27 juin 2025', 'total': '8h 30min'},
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final mois in historiques) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mois['mois'] as String,
                    style: const TextStyle(
                      color: Color(0xFF1A365D),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    mois['total'] as String,
                    style: const TextStyle(
                      color: Color(0xFF8A98A8),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            for (final jour in (mois['jours'] as List))
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jour['date'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF1A365D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total: ${jour['total']}',
                                  style: const TextStyle(
                                    color: Color(0xFF8A98A8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFBFC5D2),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
