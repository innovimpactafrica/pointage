import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/UserModel.dart';
import '../../services/AuthService.dart';
import '../../services/PointageService.dart';
import '../../utils/constants.dart';

class QRScannerPage extends StatefulWidget {
  final int workerId;

  const QRScannerPage({Key? key, required this.workerId}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool isScanning = true;
  bool isLoading = false;
  String? errorMessage;
  final _authService = AuthService();
  final _pointageService = PointageService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.connectedUser();
      if (userData != null) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && scanData.code != null) {
        setState(() {
          result = scanData;
          isScanning = false;
        });
        _handleQRCode(scanData.code!);
      }
    });
  }

  Future<void> _handleQRCode(String qrCode) async {
    print('🚀 [QRScanner] ===== DÉBUT DU SCAN QR CODE =====');
    print('🔍 [QRScanner] Code QR scanné: "$qrCode"');
    print('🔍 [QRScanner] Longueur du code: ${qrCode.length}');
    print('🔍 [QRScanner] Type du code: ${qrCode.runtimeType}');

    if (_currentUser == null) {
      print('❌ [QRScanner] ERREUR: Utilisateur non trouvé');
      _showError('Utilisateur non trouvé');
      return;
    }

    print('✅ [QRScanner] Utilisateur trouvé: ID=${_currentUser!.id}');

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('📍 [QRScanner] Récupération de la position GPS...');

      // Récupérer la position GPS
      final position = await _getCurrentPosition();

      if (position == null) {
        print('❌ [QRScanner] ERREUR: Impossible de récupérer la position GPS');
        _showError('Impossible de récupérer votre position GPS');
        return;
      }

      print('✅ [QRScanner] Position GPS récupérée:');
      print('   📍 Latitude: ${position.latitude}');
      print('   📍 Longitude: ${position.longitude}');
      print('   📍 Précision: ${position.accuracy}m');
      print('   📍 Timestamp: ${position.timestamp}');

      print('🔄 [QRScanner] Préparation de l\'appel API...');
      print('   👤 User ID: ${_currentUser!.id}');
      print('   📱 QR Code: $qrCode');
      print('   📍 Latitude: ${position.latitude}');
      print('   📍 Longitude: ${position.longitude}');

      // Déterminer le type de pointage (entrée ou sortie)
      print('🔍 [QRScanner] Détermination du type de pointage...');
      final statutPointage = await _pointageService.getStatutPointageDuJour(
        _currentUser!.id,
      );
      final typePointage =
          statutPointage['peutArrivee']
              ? PointageConstants.ARRIVEE
              : PointageConstants.DEPART;
      final typePointageText =
          statutPointage['peutArrivee'] ? 'Entrée' : 'Sortie';

      print('📋 [QRScanner] Type de pointage déterminé: $typePointageText');
      print(
        '📋 [QRScanner] Peut pointer arrivée: ${statutPointage['peutArrivee']}',
      );
      print(
        '📋 [QRScanner] Peut pointer départ: ${statutPointage['peutDepart']}',
      );

      // Effectuer le pointage avec le QR code scanné
      print('🌐 [QRScanner] Appel de l\'API de pointage...');
      final result = await _pointageService.enregistrerPointage(
        userId: _currentUser!.id,
        typePointage: typePointage,
        latitude: position.latitude,
        longitude: position.longitude,
        qrCodeText: qrCode, // Utiliser le QR code scanné directement
        commentaire: 'Pointage via QR Code: $qrCode',
      );

      print('📥 [QRScanner] Réponse de l\'API reçue:');
      print('   ✅ Success: ${result['success']}');
      print('   📝 Message: ${result['message']}');
      print('   📊 Data: ${result['data']}');

      if (result['success']) {
        print(
          '🎉 [QRScanner] SUCCÈS: $typePointageText effectuée avec succès !',
        );
        _showSuccess('$typePointageText effectuée avec succès !');
      } else {
        print(
          '❌ [QRScanner] ÉCHEC: ${result['message'] ?? 'Erreur lors du pointage'}',
        );
        _showError(result['message'] ?? 'Erreur lors du pointage');
      }
    } catch (e) {
      print('💥 [QRScanner] EXCEPTION: ${e.toString()}');
      print('💥 [QRScanner] Stack trace: ${StackTrace.current}');
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('🏁 [QRScanner] ===== FIN DU SCAN QR CODE =====');
    }
  }

  /// Récupérer la position GPS
  Future<Position?> _getCurrentPosition() async {
    try {
      print('📍 [GPS] Vérification des permissions de localisation...');

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 [GPS] Permission actuelle: $permission');

      if (permission == LocationPermission.denied) {
        print('📍 [GPS] Permission refusée, demande d\'autorisation...');
        permission = await Geolocator.requestPermission();
        print('📍 [GPS] Nouvelle permission: $permission');

        if (permission == LocationPermission.denied) {
          print('❌ [GPS] Permission définitivement refusée');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ [GPS] Permission définitivement refusée pour toujours');
        return null;
      }

      print('✅ [GPS] Permission accordée, récupération de la position...');
      print('📍 [GPS] Précision demandée: LocationAccuracy.high');

      // Récupérer la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15), // Timeout de 15 secondes
      );

      print('✅ [GPS] Position récupérée avec succès:');
      print('   📍 Latitude: ${position.latitude}');
      print('   📍 Longitude: ${position.longitude}');
      print('   📍 Précision: ${position.accuracy}m');
      print('   📍 Altitude: ${position.altitude}m');
      print('   📍 Vitesse: ${position.speed}m/s');
      print('   📍 Timestamp: ${position.timestamp}');

      return position;
    } catch (e) {
      print('💥 [GPS] EXCEPTION lors de la récupération de la position: $e');
      print('💥 [GPS] Type d\'erreur: ${e.runtimeType}');

      if (e.toString().contains('LocationServiceDisabledException')) {
        print('📍 [GPS] Service de localisation désactivé');
      } else if (e.toString().contains('PermissionDeniedException')) {
        print('📍 [GPS] Permission de localisation refusée');
      } else if (e.toString().contains('TimeoutException')) {
        print('📍 [GPS] Timeout lors de la récupération de la position');
      }

      return null;
    }
  }

  /// Afficher le message de succès
  void _showSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Succès'),
              ],
            ),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialog
                  Navigator.of(
                    context,
                  ).pop(true); // Retourner true pour indiquer le succès
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C02),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Erreur'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isScanning = true;
                    errorMessage = null;
                  });
                },
                child: const Text('Réessayer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C02),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retour'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scanner QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Scanner QR Code
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: const Color(0xFFFF5C02),
              borderRadius: 20,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),

          // Instructions
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFFFF5C02),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Positionnez le QR Code dans le cadre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Le scan se fera automatiquement',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(
                        0x33FF5C02,
                      ), // Version constante de withOpacity(0.2)
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0xFFFF5C02), width: 1),
                      ),
                    ),
                    child: const Text(
                      'Scannez n\'importe quel QR Code',
                      style: TextStyle(
                        color: Color(0xFFFF5C02),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton de retour manuel
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (isLoading) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF5C02),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Traitement en cours...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ] else if (errorMessage != null) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Icon(
                      Icons.flash_on,
                      color: Color(0xFFFF5C02),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scanner actif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bouton retour
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C02),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'Retour',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
