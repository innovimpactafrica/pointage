import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/PointageService.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final MobileScannerController _scannerController =
  MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  bool isScanning = true;
  bool isLoading = false;
  String? errorMessage;

  final _pointageService = PointageService();

  String? _qrCode;
  double? _latitude;
  double? _longitude;
  final TextEditingController _nameController = TextEditingController();

  int _currentStep = 0; // 0: Scan QR, 1: Saisie nom

  @override
  void dispose() {
    _scannerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      isScanning = false;
    });

    _handleQRCode(code);
  }

  Future<void> _handleQRCode(String qrCode) async {
    print('🚀 [AddAddress] QR Code scanné: $qrCode');

    setState(() {
      _qrCode = qrCode;
      isLoading = true;
      errorMessage = null;
    });

    try {
      final position = await _getCurrentPosition();

      if (position == null) {
        _showError('Impossible de récupérer votre position GPS');
        return;
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentStep = 1;
        isLoading = false;
      });
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  Future<Position?> _getCurrentPosition() async {
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
  }

  Future<void> _createAddress() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Veuillez saisir un nom pour l\'adresse');
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await _pointageService.creerAdressePointage(
        latitude: _latitude!,
        longitude: _longitude!,
        name: _nameController.text.trim(),
        qrcode: _qrCode!,
      );

      if (result['success']) {
        _showSuccess('Adresse créée avec succès !');
      } else {
        _showError(result['message'] ?? 'Erreur lors de la création');
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
      isScanning = true;
    });
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
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
        title:  Text('Ajouter une adresse,',style: TextStyle(color: Colors.white,),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _currentStep == 0 ? _buildQRScanner() : _buildNameInput(),
    );
  }

  /// ------------------ UI SCAN ------------------
  Widget _buildQRScanner() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: const Column(
            children: [
              Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFFFF5C02)),
              SizedBox(height: 16),
              Text(
                'Scanner le QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Scannez le QR Code de l\'adresse à ajouter',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF5C02), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),
            ),
          ),
        ),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFFFF5C02)),
            ),
          ),

        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  /// ------------------ UI FORM ------------------
  Widget _buildNameInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nom de l\'adresse',
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ex: Bureau principal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C02),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  :  Text('Ajouter l\'adresse',style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
