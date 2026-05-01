import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/property_model.dart';
import 'package:app_mobil_bayeur/providers/property_provider.dart';
import 'package:app_mobil_bayeur/widgets/image_gallery_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

class PropertyRegistrationScreen extends ConsumerStatefulWidget {
  const PropertyRegistrationScreen({super.key});

  @override
  ConsumerState<PropertyRegistrationScreen> createState() => _PropertyRegistrationScreenState();
}

class _PropertyRegistrationScreenState extends ConsumerState<PropertyRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form State
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rentPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  
  PropertyType _selectedType = PropertyType.APARTMENT;
  PropertyStanding _selectedStanding = PropertyStanding.STANDARD;
  PropertyStatus _selectedStatus = PropertyStatus.FOR_RENT;
  
  double? _latitude;
  double? _longitude;
  List<File> _selectedImages = [];
  File? _verificationDoc;

  bool _isSubmitting = false;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _handleCompleteRegistration();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Coordonnées GPS récupérées avec succès")),
    );
  }

  Future<void> _pickVerificationDoc() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _verificationDoc = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleCompleteRegistration() async {
    if (_selectedImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner au moins 3 images")));
      return;
    }
    if (_verificationDoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez uploader un document de vérification")));
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final propertyData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'type': _selectedType.name,
        'standing': _selectedStanding.name,
        'status': _selectedStatus.name,
        'rent_price': _rentPriceController.text.isNotEmpty ? double.parse(_rentPriceController.text) : null,
        'sale_price': _salePriceController.text.isNotEmpty ? double.parse(_salePriceController.text) : null,
        'latitude': _latitude,
        'longitude': _longitude,
      };

      final property = await ref.read(propertiesProvider.notifier).createProperty(propertyData);
      
      // Upload Images
      await ref.read(propertyServiceProvider).uploadPropertyImages(property.id, _selectedImages);
      
      // Upload Doc
      await ref.read(propertyServiceProvider).uploadVerificationDocument(property.id, _verificationDoc!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bien enregistré avec succès ! En attente de validation admin.")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Enregistrer un bien", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStepContent(0, _buildGeneralInfoStep()),
                _buildStepContent(1, _buildLocationStep()),
                _buildStepContent(2, _buildMediaStep()),
                _buildStepContent(3, _buildVerificationStep()),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Étape ${_currentStep + 1} sur $_totalSteps", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(_getStepTitle(_currentStep), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return "Informations générales";
      case 1: return "Localisation";
      case 2: return "Prix & Galerie";
      case 3: return "Vérification";
      default: return "";
    }
  }

  Widget _buildStepContent(int index, Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: content,
    );
  }

  Widget _buildGeneralInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(controller: _nameController, label: "Nom de l'infrastructure", hint: "Ex: Immeuble Laurier"),
        const SizedBox(height: 20),
        _buildDropdown<PropertyType>(
          label: "Type de bien",
          value: _selectedType,
          items: PropertyType.values,
          onChanged: (v) => setState(() => _selectedType = v!),
          getLabel: (e) => e.name,
        ),
        const SizedBox(height: 20),
        _buildDropdown<PropertyStanding>(
          label: "Standing",
          value: _selectedStanding,
          items: PropertyStanding.values,
          onChanged: (v) => setState(() => _selectedStanding = v!),
          getLabel: (e) => e.name,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _descriptionController,
          label: "Description",
          hint: "Détails sur l'équipement, le nombre de chambres...",
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(controller: _locationController, label: "Adresse complète", hint: "Ville, Quartier, Rue..."),
        const SizedBox(height: 24),
        Text("Coordonnées GPS", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _latitude != null ? "Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}" : "Coordonnées non récupérées",
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
              TextButton(onPressed: _getCurrentLocation, child: const Text("Récupérer")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown<PropertyStatus>(
          label: "État du bien",
          value: _selectedStatus,
          items: PropertyStatus.values,
          onChanged: (v) => setState(() => _selectedStatus = v!),
          getLabel: (e) => e.name,
        ),
        const SizedBox(height: 20),
        if (_selectedStatus == PropertyStatus.FOR_RENT || _selectedStatus == PropertyStatus.OCCUPIED)
          _buildTextField(controller: _rentPriceController, label: "Prix de location mensuel (FCFA)", hint: "Ex: 150000", keyboardType: TextInputType.number),
        if (_selectedStatus == PropertyStatus.FOR_SALE || _selectedStatus == PropertyStatus.SOLD)
          _buildTextField(controller: _salePriceController, label: "Prix de vente (FCFA)", hint: "Ex: 45000000", keyboardType: TextInputType.number),
        const SizedBox(height: 32),
        ImageGalleryPicker(
          onImagesSelected: (images) => setState(() => _selectedImages = images),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Document de vérification",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Veuillez uploader un titre de propriété ou un acte notarié pour valider votre bien.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: _pickVerificationDoc,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(_verificationDoc != null ? Icons.description : Icons.upload_file, size: 48, color: Colors.blue),
                const SizedBox(height: 12),
                Text(
                  _verificationDoc != null ? _verificationDoc!.path.split('/').last : "Cliquer pour uploader",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) getLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(getLabel(e)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Précédent"),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_currentStep == _totalSteps - 1 ? "Terminer" : "Suivant"),
            ),
          ),
        ],
      ),
    );
  }
}
