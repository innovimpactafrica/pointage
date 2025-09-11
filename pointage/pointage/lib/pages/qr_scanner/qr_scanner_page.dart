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
    if (_currentUser == null) {
      _showError('Utilisateur non trouvé');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('🔍 [QRScanner] Code scanné: "$qrCode"');

      // Récupérer la position GPS
      final position = await _getCurrentPosition();

      if (position == null) {
        _showError('Impossible de récupérer votre position GPS');
        return;
      }

      print(
        '📍 [QRScanner] Position GPS: ${position.latitude}, ${position.longitude}',
      );

      // Effectuer le pointage avec le QR code scanné
      final result = await _pointageService.enregistrerPointage(
        userId: _currentUser!.id,
        typePointage: PointageConstants.ARRIVEE,
        latitude: position.latitude,
        longitude: position.longitude,
        qrCodeText: qrCode, // Utiliser le QR code scanné directement
        commentaire: 'Pointage via QR Code: $qrCode',
      );

      if (result['success']) {
        _showSuccess('Pointage effectué avec succès !');
      } else {
        _showError(result['message'] ?? 'Erreur lors du pointage');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Récupérer la position GPS
  Future<Position?> _getCurrentPosition() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Récupérer la position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ Erreur GPS: $e');
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
