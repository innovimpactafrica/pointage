import 'package:flutter/material.dart';
import '../../services/AuthService.dart';
import '../../models/UserModel.dart';
import '../../models/PointageModel.dart';
import '../../services/PointageService.dart';
import '../qr_scanner/qr_scanner_page.dart';
import '../addresses/add_address_page.dart';

class ModernPointagePage extends StatefulWidget {
  const ModernPointagePage({Key? key}) : super(key: key);

  @override
  State<ModernPointagePage> createState() => _ModernPointagePageState();
}

class _ModernPointagePageState extends State<ModernPointagePage> {
  int _selectedTab = 0;
  final _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.connectedUser();
      if (userData != null && mounted) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  void _goToHistorique() {
    setState(() {
      _selectedTab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppHeader(currentUser: _currentUser),
            _PointageHeaderTabs(
              selected: _selectedTab,
              onChanged: (i) => setState(() => _selectedTab = i),
            ),
            Expanded(
              child:
                  _selectedTab == 0
                      ? _PointageDuJourCard(onVoirPlus: _goToHistorique)
                      : _selectedTab == 1
                      ? _HistoriqueTab(userId: _currentUser?.id)
                      : const _AdressesTab(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final UserModel? currentUser;

  const _AppHeader({required this.currentUser});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1A365D)),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Barre supérieure avec logo
            const Text(
              'Pointage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Section utilisateur avec photo et message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Photo de profil
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child:
                        currentUser?.photo != null &&
                                currentUser!.photo!.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                currentUser!.photo!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  );
                                },
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                  ),
                  const SizedBox(width: 16),
                  // Message de bienvenue
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${_getGreeting()} ${currentUser?.prenom ?? 'Utilisateur'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('👋', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
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
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pointage',
                            style: TextStyle(
                              color:
                                  selected == 0
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 40,
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
              Flexible(
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
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Historique',
                            style: TextStyle(
                              color:
                                  selected == 1
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 40,
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
              Flexible(
                child: GestureDetector(
                  onTap: () => onChanged(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color:
                                selected == 2
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Adresses',
                            style: TextStyle(
                              color:
                                  selected == 2
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color:
                              selected == 2 ? Colors.white : Colors.transparent,
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
  List<PointageModel> _todayPointages =
      []; // Nouvelle variable pour stocker tous les pointages d'aujourd'hui

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.connectedUser();
      if (userData != null && mounted) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
        await _loadTodayPointage();
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTodayPointage() async {
    if (!mounted) return;
    if (_currentUser == null) return;

    try {
      print('🔄 [PointagePage] Chargement des pointages d\'aujourd\'hui...');

      // Utiliser la nouvelle méthode pour récupérer TOUS les pointages d'aujourd'hui
      final todayPointages = await _pointageService.getTousPointagesDuJour(
        _currentUser!.id,
      );

      print(
        '📊 [PointagePage] ${todayPointages.length} pointages d\'aujourd\'hui récupérés',
      );

      if (todayPointages.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _todayPointages = todayPointages;

          // Prendre le premier pointage pour l'affichage principal (compatibilité)
          final firstPointage = todayPointages.first;

          // Formater l'heure d'arrivée
          if (firstPointage.heureArrivee != null) {
            _lastPointageTime =
                '${firstPointage.heureArrivee!.hour.toString().padLeft(2, '0')}:${firstPointage.heureArrivee!.minute.toString().padLeft(2, '0')}';
          }

          // Formater l'heure de départ (prendre le dernier départ s'il y en a un)
          final lastPointage = todayPointages.last;
          if (lastPointage.heureDepart != null) {}

          // Calculer le temps total travaillé de TOUTES les sessions
          _totalWorkedTime = _calculateTotalWorkedTime(todayPointages);
        });
      } else {
        if (mounted) {
          setState(() {
            _todayPointages = [];
            _lastPointageTime = '--:--';
            _totalWorkedTime = '0h 00min';
          });
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du pointage: $e');
    }
  }

  /// Calcule le temps total travaillé de toutes les sessions d'aujourd'hui
  String _calculateTotalWorkedTime(List<PointageModel> pointages) {
    if (pointages.isEmpty) return '0h 00min';

    int totalMinutes = 0;

    for (final pointage in pointages) {
      if (pointage.heureArrivee != null && pointage.heureDepart != null) {
        // Calculer la durée de cette session
        final arrivee = pointage.heureArrivee!;
        final depart = pointage.heureDepart!;

        // Calculer la différence en minutes
        final difference = depart.difference(arrivee);
        totalMinutes += difference.inMinutes;

        print(
          '⏱️ [PointagePage] Session: ${arrivee.hour}:${arrivee.minute.toString().padLeft(2, '0')} - ${depart.hour}:${depart.minute.toString().padLeft(2, '0')} = ${difference.inMinutes}min',
        );
      }
    }

    // Convertir en heures et minutes
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final result = '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    print(
      '⏱️ [PointagePage] Temps total calculé: $result (${totalMinutes} minutes)',
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      child: Column(
        children: [
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
                        if (_todayPointages.isEmpty)
                          const Text(
                            'Pas encore de pointage aujourd\'hui',
                            style: TextStyle(
                              color: Color(0xFF8A98A8),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Column(
                            children:
                                _todayPointages.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final pointage = entry.value;
                                  return Column(
                                    children: [
                                      if (index > 0) const SizedBox(height: 12),
                                      _SessionCard(
                                        entree:
                                            pointage.heureArrivee != null
                                                ? '${pointage.heureArrivee!.hour.toString().padLeft(2, '0')}:${pointage.heureArrivee!.minute.toString().padLeft(2, '0')}'
                                                : '--:--',
                                        sortie:
                                            pointage.heureDepart != null
                                                ? '${pointage.heureDepart!.hour.toString().padLeft(2, '0')}:${pointage.heureDepart!.minute.toString().padLeft(2, '0')}'
                                                : '--:--',
                                      ),
                                    ],
                                  );
                                }).toList(),
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
                // Numéro de session si multiple
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

class _HistoriqueTab extends StatefulWidget {
  final int? userId;

  const _HistoriqueTab({this.userId});

  @override
  State<_HistoriqueTab> createState() => _HistoriqueTabState();
}

class _HistoriqueTabState extends State<_HistoriqueTab> {
  final _pointageService = PointageService();
  bool _isLoading = true;
  Map<String, dynamic> _monthlyData = {
    'dailySummaries': [],
    'totalWorkedTime': '0h 00min',
  };

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadHistorique();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHistorique() async {
    if (widget.userId == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _pointageService.getMonthlySummary(widget.userId!);
      if (mounted) {
        setState(() {
          _monthlyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement de l\'historique: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Formate une date du format "03-11-2025" vers "Mer. 03 nov. 2025"
  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      final weekdays = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
      final months = [
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

      final weekday = weekdays[date.weekday - 1];
      final monthName = months[month - 1];

      return '$weekday $day $monthName $year';
    } catch (e) {
      return dateStr;
    }
  }

  /// Groupe les données par mois
  Map<String, Map<String, dynamic>> _groupByMonth() {
    final Map<String, Map<String, dynamic>> grouped = {};
    final List<dynamic> summaries = _monthlyData['dailySummaries'] ?? [];

    for (final summary in summaries) {
      final day = summary['day'] as String;
      final hoursWorked = summary['hoursWorked'] as String;

      try {
        final parts = day.split('-');
        if (parts.length == 3) {
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          final months = [
            'Janvier',
            'Février',
            'Mars',
            'Avril',
            'Mai',
            'Juin',
            'Juillet',
            'Août',
            'Septembre',
            'Octobre',
            'Novembre',
            'Décembre',
          ];

          final monthKey = '${months[month - 1]} $year';
          if (!grouped.containsKey(monthKey)) {
            grouped[monthKey] = {
              'mois': monthKey,
              'total': '0h 00min',
              'jours': <Map<String, dynamic>>[],
            };
          }

          grouped[monthKey]!['jours'].add({
            'date': _formatDate(day),
            'dateOriginal': day, // Garder la date originale pour le tri
            'total': hoursWorked,
          });
        }
      } catch (e) {
        print('❌ Erreur lors du formatage de la date: $e');
      }
    }

    // Calculer le total par mois
    for (final monthData in grouped.values) {
      int totalMinutes = 0;
      for (final jour in monthData['jours'] as List) {
        final hoursWorked = jour['total'] as String;
        final match = RegExp(r'(\d+)h\s*(\d+)min').firstMatch(hoursWorked);
        if (match != null) {
          final hours = int.parse(match.group(1)!);
          final minutes = int.parse(match.group(2)!);
          totalMinutes += hours * 60 + minutes;
        }
      }
      final totalHours = totalMinutes ~/ 60;
      final remainingMinutes = totalMinutes % 60;
      monthData['total'] =
          '${totalHours}h ${remainingMinutes.toString().padLeft(2, '0')}min';
    }

    // Trier par mois (du plus récent au plus ancien)
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          // Extraire l'année et le mois pour trier
          final aParts = a.split(' ');
          final bParts = b.split(' ');
          if (aParts.length == 2 && bParts.length == 2) {
            final aYear = int.tryParse(aParts[1]) ?? 0;
            final bYear = int.tryParse(bParts[1]) ?? 0;
            if (aYear != bYear) return bYear.compareTo(aYear);

            final months = [
              'Janvier',
              'Février',
              'Mars',
              'Avril',
              'Mai',
              'Juin',
              'Juillet',
              'Août',
              'Septembre',
              'Octobre',
              'Novembre',
              'Décembre',
            ];
            final aMonth = months.indexOf(aParts[0]);
            final bMonth = months.indexOf(bParts[0]);
            return bMonth.compareTo(aMonth);
          }
          return b.compareTo(a);
        });

    final sortedGrouped = <String, Map<String, dynamic>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
      // Trier les jours du mois (du plus récent au plus ancien) en utilisant la date originale
      (sortedGrouped[key]!['jours'] as List).sort((a, b) {
        final aDateStr = a['dateOriginal'] as String;
        final bDateStr = b['dateOriginal'] as String;

        try {
          // Parser les dates au format "03-11-2025"
          final aParts = aDateStr.split('-');
          final bParts = bDateStr.split('-');

          if (aParts.length == 3 && bParts.length == 3) {
            final aDate = DateTime(
              int.parse(aParts[2]),
              int.parse(aParts[1]),
              int.parse(aParts[0]),
            );
            final bDate = DateTime(
              int.parse(bParts[2]),
              int.parse(bParts[1]),
              int.parse(bParts[0]),
            );
            // Du plus récent au plus ancien
            return bDate.compareTo(aDate);
          }
        } catch (e) {
          print('❌ Erreur lors du tri des dates: $e');
        }

        return bDateStr.compareTo(aDateStr);
      });
    }

    return sortedGrouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final historiques = _groupByMonth();

    if (historiques.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Aucun historique disponible',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 100, left: 0, right: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final mois in historiques.values) ...[
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
            for (final jour in (mois['jours'] as List<Map<String, dynamic>>))
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
                                  jour['date'] ?? '',
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

class _AdressesTab extends StatefulWidget {
  const _AdressesTab();

  @override
  State<_AdressesTab> createState() => _AdressesTabState();
}

class _AdressesTabState extends State<_AdressesTab> {
  final _pointageService = PointageService();
  List<Map<String, dynamic>> _adresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdresses();
  }

  Future<void> _loadAdresses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 [AdressesTab] Chargement des adresses depuis l\'API...');

      // Utiliser l'ID du projet 22 (vous pouvez le rendre dynamique plus tard)
      const int projectId = 22;
      final adressesApi = await _pointageService.getAdressesPointage(projectId);

      // Transformer les données de l'API pour correspondre à notre format d'affichage
      if (mounted) {
        setState(() {
          _adresses =
              adressesApi.map((adresse) {
                return {
                  'id': adresse['id'],
                  'nom': adresse['name'],
                  'latitude': adresse['latitude'],
                  'longitude': adresse['longitude'],
                  'type': _determinerTypeAdresse(adresse['name']),
                  'isActive':
                      true, // Par défaut, toutes les adresses sont actives
                };
              }).toList();
        });
      }

      print(
        '✅ [AdressesTab] ${_adresses.length} adresses chargées depuis l\'API',
      );
    } catch (e) {
      print('❌ [AdressesTab] Erreur lors du chargement des adresses: $e');
      // En cas d'erreur, utiliser des données d'exemple
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Détermine le type d'adresse basé sur le nom
  String _determinerTypeAdresse(String nom) {
    final nomLower = nom.toLowerCase();
    if (nomLower.contains('chantier') || nomLower.contains('construction')) {
      return 'Chantier';
    } else if (nomLower.contains('entrepôt') || nomLower.contains('stockage')) {
      return 'Entrepôt';
    } else if (nomLower.contains('bureau') || nomLower.contains('siège')) {
      return 'Bureau';
    } else {
      return 'Bureau'; // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5C02)),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Liste des adresses
              ..._adresses
                  .map((adresse) => _buildAdresseCard(adresse))
                  .toList(),
            ],
          ),
        ),
        // FloatingActionButton positionné en bas à droite
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddAddressPage()),
              );

              // Recharger les adresses si une nouvelle a été créée
              if (result == true) {
                _loadAdresses();
              }
            },
            backgroundColor: const Color(0xFFFF5C02),
            icon: const Icon(Icons.add_location, color: Colors.white),
            label: const Text(
              'Ajouter une adresse',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdresseCard(Map<String, dynamic> adresse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(adresse['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(adresse['type']),
                  color: _getTypeColor(adresse['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adresse['nom'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adresse['type'],
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(adresse['type']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      adresse['isActive']
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  adresse['isActive'] ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color:
                        adresse['isActive']
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE74C3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.gps_fixed, size: 16, color: Color(0xFF8A98A8)),
              const SizedBox(width: 8),
              Text(
                '${adresse['latitude'].toStringAsFixed(6)}, ${adresse['longitude'].toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A98A8),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bureau':
        return const Color(0xFF2196F3);
      case 'chantier':
        return const Color(0xFFFF5C02);
      case 'entrepôt':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF8A98A8);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bureau':
        return Icons.business;
      case 'chantier':
        return Icons.construction;
      case 'entrepôt':
        return Icons.warehouse;
      default:
        return Icons.location_on;
    }
  }
}
