import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/PointageService.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool isScanning = true;
  bool isLoading = false;
  String? errorMessage;
  final _pointageService = PointageService();

  // Variables pour stocker les données
  String? _qrCode;
  double? _latitude;
  double? _longitude;
  final TextEditingController _nameController = TextEditingController();

  // État du flux
  int _currentStep = 0; // 0: Scan QR, 1: Saisie nom, 2: Confirmation

  @override
  void dispose() {
    controller?.dispose();
    _nameController.dispose();
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
    print('🚀 [AddAddress] ===== DÉBUT AJOUT ADRESSE =====');
    print('🔍 [AddAddress] Code QR scanné: "$qrCode"');

    setState(() {
      _qrCode = qrCode;
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Récupérer la position GPS
      print('📍 [AddAddress] Récupération de la position GPS...');
      final position = await _getCurrentPosition();

      if (position == null) {
        _showError('Impossible de récupérer votre position GPS');
        return;
      }

      print('✅ [AddAddress] Position GPS récupérée:');
      print('   📍 Latitude: ${position.latitude}');
      print('   📍 Longitude: ${position.longitude}');

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentStep = 1; // Passer à l'étape de saisie du nom
        isLoading = false;
      });
    } catch (e) {
      print('💥 [AddAddress] EXCEPTION: ${e.toString()}');
      _showError('Erreur: ${e.toString()}');
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

      // Récupérer la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      print('✅ [GPS] Position récupérée avec succès:');
      print('   📍 Latitude: ${position.latitude}');
      print('   📍 Longitude: ${position.longitude}');

      return position;
    } catch (e) {
      print('💥 [GPS] EXCEPTION lors de la récupération de la position: $e');
      return null;
    }
  }

  Future<void> _createAddress() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Veuillez saisir un nom pour l\'adresse');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('🏗️ [AddAddress] Création de l\'adresse...');

      final result = await _pointageService.creerAdressePointage(
        latitude: _latitude!,
        longitude: _longitude!,
        name: _nameController.text.trim(),
        qrcode: _qrCode!,
      );

      if (result['success']) {
        print('🎉 [AddAddress] Adresse créée avec succès !');
        _showSuccess('Adresse créée avec succès !');
      } else {
        print('❌ [AddAddress] ÉCHEC: ${result['message']}');
        _showError(result['message'] ?? 'Erreur lors de la création');
      }
    } catch (e) {
      print('💥 [AddAddress] EXCEPTION: ${e.toString()}');
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        elevation: 0,
        title: const Text(
          'Ajouter une adresse',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _currentStep == 0 ? _buildQRScanner() : _buildNameInput(),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: Color(0xFFFF5C02),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scanner le QR Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scannez le QR Code de l\'adresse à ajouter',
                style: TextStyle(fontSize: 16, color: Color(0xFF8A98A8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Scanner QR
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF5C02), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: const Color(0xFFFF5C02),
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250,
                ),
              ),
            ),
          ),
        ),

        // Indicateur de chargement
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5C02)),
                ),
                SizedBox(height: 16),
                Text(
                  'Récupération de la position GPS...',
                  style: TextStyle(fontSize: 16, color: Color(0xFF8A98A8)),
                ),
              ],
            ),
          ),

        // Message d'erreur
        if (errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNameInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations scannées
          Container(
            width: double.infinity,
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
                const Text(
                  'Informations scannées',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.qr_code,
                      color: Color(0xFFFF5C02),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'QR Code: $_qrCode',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A98A8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      color: Color(0xFFFF5C02),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Position: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A98A8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Saisie du nom
          const Text(
            'Nom de l\'adresse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saisissez le nom de cette adresse de pointage',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A98A8)),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ex: Bureau principal, Chantier A, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5C02),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 32),

          // Bouton de création
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C02),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child:
                  isLoading
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Création en cours...'),
                        ],
                      )
                      : const Text(
                        'Créer l\'adresse',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),

          // Message d'erreur
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
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
}
