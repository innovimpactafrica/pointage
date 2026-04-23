import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  final MobileScannerController _scannerController = MobileScannerController();
  final FlutterTts flutterTts = FlutterTts();

  bool isScanning = true;
  bool isLoading = false;
  String? errorMessage;

  final _authService = AuthService();
  final _pointageService = PointageService();
  UserModel? _currentUser;

  Future<void> speakText(String text) async {
    try {
      // 1. Définir la langue
      await flutterTts.setLanguage("fr-FR");

      // 2. Définir la vitesse de parole (0.0 à 1.0)
      await flutterTts.setSpeechRate(0.5);

      // 3. Définir le pitch (tonalité)
      await flutterTts.setPitch(1.0);

      // 4. Lancer la synthèse vocale
      await flutterTts.speak(text);
    } catch (e) {
      print("Erreur TTS : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
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
      print('❌ Erreur chargement utilisateur: $e');
    }
  }

  /// =============================
  /// 📸 QR CODE DÉTECTÉ
  /// =============================
  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final barcode = capture.barcodes.first;
    final qrCode = barcode.rawValue;

    if (qrCode == null || qrCode.isEmpty) return;

    setState(() {
      isScanning = false;
    });

    _handleQRCode(qrCode);
  }

  /// =============================
  /// 🚀 TRAITEMENT DU QR CODE
  /// =============================
  Future<void> _handleQRCode(String qrCode) async {
    print('🚀 ===== DÉBUT SCAN QR =====');
    print('📱 QR Code: $qrCode');

    if (_currentUser == null) {
      _showError('Utilisateur non trouvé');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 📍 GPS
      final position = await _getCurrentPosition();
      if (position == null) {
        _showError('Impossible de récupérer la position GPS');
        return;
      }

      // 🔍 Type de pointage
      final statut = await _pointageService.getStatutPointageDuJour(
        _currentUser!.id,
      );

      final typePointage =
          statut['peutArrivee']
              ? PointageConstants.ARRIVEE
              : PointageConstants.DEPART;

      final typeLabel = statut['peutArrivee'] ? 'Entrée' : 'Sortie';
      final encodedQrCode = Uri.encodeComponent(qrCode);
      // 🌐 API
      final result = await _pointageService.enregistrerPointage(
        userId: _currentUser!.id,
        typePointage: typePointage,
        latitude: position.latitude,
        longitude: position.longitude,
        qrCodeText: qrCode,
        commentaire: 'Pointage via QR Code: $qrCode',
      );

      if (result['success']) {
        _showSuccess(result['message']);
      //  speakText(result['message']);

      } else {
        print(result);
       _showError(result['message'] ?? 'Erreur de pointage');

      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
     // _showError(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// =============================
  /// 📍 GPS
  /// =============================
  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      print('❌ GPS error: $e');
      return null;
    }
  }

  /// =============================
  /// ✅ SUCCÈS
  /// =============================
  void _showSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Succès'),
              ],
            ),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C02),
                ),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  /// =============================
  /// ❌ ERREUR
  /// =============================
  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Text('Erreur'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isScanning = true;
                    errorMessage = null;
                  });
                },
                child: Text('Réessayer', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C02),
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  /// =============================
  /// 🎨 UI
  /// =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pointer via QR code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5C02)),
            ),

          /* Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_rounded,color: Colors.white,),
              label: Text('Retour',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C02),
                padding:
                const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
