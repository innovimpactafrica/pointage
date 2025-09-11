import 'package:flutter/material.dart';
import 'package:pointage/models/PointageModel.dart';
import '../services/PointageService.dart';
import 'package:intl/intl.dart';

class PointageHistoriquePage extends StatefulWidget {
  final int? userId; // ID de l'utilisateur pour récupérer l'historique

  const PointageHistoriquePage({Key? key, this.userId}) : super(key: key);

  @override
  State<PointageHistoriquePage> createState() => _PointageHistoriquePageState();
}

class _PointageHistoriquePageState extends State<PointageHistoriquePage> {
  final _pointageService = PointageService();

  List<PointageModel> _pointages = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'Mois';

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    if (widget.userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DateTime dateDebut;
      DateTime dateFin;

      switch (_selectedFilter) {
        case 'Semaine':
          dateDebut = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday - 1),
          );
          dateFin = dateDebut.add(const Duration(days: 6));
          break;
        case 'Mois':
          dateDebut = DateTime(_selectedDate.year, _selectedDate.month, 1);
          dateFin = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
          break;
        case 'Année':
          dateDebut = DateTime(_selectedDate.year, 1, 1);
          dateFin = DateTime(_selectedDate.year, 12, 31);
          break;
        default:
          dateDebut = _selectedDate;
          dateFin = _selectedDate;
      }

      final pointages = await _pointageService.getHistoriquePointages(
        userId: widget.userId!,
        dateDebut: dateDebut,
        dateFin: dateFin,
      );

      setState(() {
        _pointages = pointages;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement de l\'historique: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        elevation: 0,
        title: const Text(
          'Historique des pointages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Sélecteur de période
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        items:
                            ['Jour', 'Semaine', 'Mois', 'Année'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                            _loadHistorique();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sélecteur de date
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des pointages
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _pointages.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucun pointage trouvé',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pointages.length,
                      itemBuilder: (context, index) {
                        final pointage = _pointages[index];
                        return _buildPointageCard(pointage);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointageCard(PointageModel pointage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(pointage.datePointage),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              _buildStatutBadge(pointage),
            ],
          ),

          const SizedBox(height: 12),

          // Heures
          Row(
            children: [
              Expanded(
                child: _buildHeureInfo(
                  'Arrivée',
                  pointage.heureArrivee,
                  Icons.login,
                  const Color(0xFF27AE60),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHeureInfo(
                  'Départ',
                  pointage.heureDepart,
                  Icons.logout,
                  const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),

          if (pointage.dureeTravail != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C02).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Durée: ${pointage.dureeTravailFormatee}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF5C02),
                ),
              ),
            ),
          ],

          if (pointage.commentaire != null &&
              pointage.commentaire!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Commentaire: ${pointage.commentaire}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeureInfo(
    String label,
    DateTime? heure,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 2),
          Text(
            heure != null ? DateFormat('HH:mm').format(heure) : '--:--',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: heure != null ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutBadge(PointageModel pointage) {
    String statut;
    Color color;

    if (pointage.heureArrivee != null && pointage.heureDepart != null) {
      statut = 'Complet';
      color = const Color(0xFF27AE60);
    } else if (pointage.heureArrivee != null) {
      statut = 'En cours';
      color = const Color(0xFFF39C12);
    } else {
      statut = 'Incomplet';
      color = const Color(0xFFE74C3C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statut,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadHistorique();
    }
  }
}
