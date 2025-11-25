// profile_page.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();

  String? _selectedGender;
  String _currentFlag = "🇮🇳";

  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;

  // keys for SharedPreferences
  static const _kUsername = 'profile_username';
  static const _kName = 'profile_name';
  static const _kContact = 'profile_contact';
  static const _kDob = 'profile_dob';
  static const _kBio = 'profile_bio';
  static const _kCountryCode = 'profile_country_code';
  static const _kFlag = 'profile_flag';
  static const _kGender = 'profile_gender';
  static const _kImage = 'profile_image_base64';

  final List<Map<String, String>> _countries = [
    {"name": "Afghanistan", "code": "+93", "flag": "🇦🇫"},
    {"name": "Albania", "code": "+355", "flag": "🇦🇱"},
    {"name": "Algeria", "code": "+213", "flag": "🇩🇿"},
    {"name": "Andorra", "code": "+376", "flag": "🇦🇩"},
    {"name": "Angola", "code": "+244", "flag": "🇦🇴"},
    {"name": "Antigua and Barbuda", "code": "+1-268", "flag": "🇦🇬"},
    {"name": "Argentina", "code": "+54", "flag": "🇦🇷"},
    {"name": "Armenia", "code": "+374", "flag": "🇦🇲"},
    {"name": "Australia", "code": "+61", "flag": "🇦🇺"},
    {"name": "Austria", "code": "+43", "flag": "🇦🇹"},
    {"name": "Azerbaijan", "code": "+994", "flag": "🇦🇿"},
    {"name": "Bahamas", "code": "+1-242", "flag": "🇧🇸"},
    {"name": "Bahrain", "code": "+973", "flag": "🇧🇭"},
    {"name": "Bangladesh", "code": "+880", "flag": "🇧🇩"},
    {"name": "Barbados", "code": "+1-246", "flag": "🇧🇧"},
    {"name": "Belarus", "code": "+375", "flag": "🇧🇾"},
    {"name": "Belgium", "code": "+32", "flag": "🇧🇪"},
    {"name": "Belize", "code": "+501", "flag": "🇧🇿"},
    {"name": "Benin", "code": "+229", "flag": "🇧🇯"},
    {"name": "Bhutan", "code": "+975", "flag": "🇧🇹"},
    {"name": "Bolivia", "code": "+591", "flag": "🇧🇴"},
    {"name": "Bosnia and Herzegovina", "code": "+387", "flag": "🇧🇦"},
    {"name": "Botswana", "code": "+267", "flag": "🇧🇼"},
    {"name": "Brazil", "code": "+55", "flag": "🇧🇷"},
    {"name": "Brunei", "code": "+673", "flag": "🇧🇳"},
    {"name": "Bulgaria", "code": "+359", "flag": "🇧🇬"},
    {"name": "Burkina Faso", "code": "+226", "flag": "🇧🇫"},
    {"name": "Burundi", "code": "+257", "flag": "🇧🇮"},
    {"name": "Cabo Verde", "code": "+238", "flag": "🇨🇻"},
    {"name": "Cambodia", "code": "+855", "flag": "🇰🇭"},
    {"name": "Cameroon", "code": "+237", "flag": "🇨🇲"},
    {"name": "Canada", "code": "+1", "flag": "🇨🇦"},
    {"name": "Central African Republic", "code": "+236", "flag": "🇨🇫"},
    {"name": "Chad", "code": "+235", "flag": "🇹🇩"},
    {"name": "Chile", "code": "+56", "flag": "🇨🇱"},
    {"name": "China", "code": "+86", "flag": "🇨🇳"},
    {"name": "Colombia", "code": "+57", "flag": "🇨🇴"},
    {"name": "Comoros", "code": "+269", "flag": "🇰🇲"},
    {"name": "Congo (Congo-Brazzaville)", "code": "+242", "flag": "🇨🇬"},
    {"name": "Costa Rica", "code": "+506", "flag": "🇨🇷"},
    {"name": "Croatia", "code": "+385", "flag": "🇭🇷"},
    {"name": "Cuba", "code": "+53", "flag": "🇨🇺"},
    {"name": "Cyprus", "code": "+357", "flag": "🇨🇾"},
    {"name": "Czechia", "code": "+420", "flag": "🇨🇿"},
    {"name": "Denmark", "code": "+45", "flag": "🇩🇰"},
    {"name": "Djibouti", "code": "+253", "flag": "🇩🇯"},
    {"name": "Dominica", "code": "+1-767", "flag": "🇩🇲"},
    {"name": "Dominican Republic", "code": "+1-809", "flag": "🇩🇴"},
    {"name": "Ecuador", "code": "+593", "flag": "🇪🇨"},
    {"name": "Egypt", "code": "+20", "flag": "🇪🇬"},
    {"name": "El Salvador", "code": "+503", "flag": "🇸🇻"},
    {"name": "Equatorial Guinea", "code": "+240", "flag": "🇬🇶"},
    {"name": "Eritrea", "code": "+291", "flag": "🇪🇷"},
    {"name": "Estonia", "code": "+372", "flag": "🇪🇪"},
    {"name": "Eswatini", "code": "+268", "flag": "🇸🇿"},
    {"name": "Ethiopia", "code": "+251", "flag": "🇪🇹"},
    {"name": "Fiji", "code": "+679", "flag": "🇫🇯"},
    {"name": "Finland", "code": "+358", "flag": "🇫🇮"},
    {"name": "France", "code": "+33", "flag": "🇫🇷"},
    {"name": "Gabon", "code": "+241", "flag": "🇬🇦"},
    {"name": "Gambia", "code": "+220", "flag": "🇬🇲"},
    {"name": "Georgia", "code": "+995", "flag": "🇬🇪"},
    {"name": "Germany", "code": "+49", "flag": "🇩🇪"},
    {"name": "Ghana", "code": "+233", "flag": "🇬🇭"},
    {"name": "Greece", "code": "+30", "flag": "🇬🇷"},
    {"name": "Grenada", "code": "+1-473", "flag": "🇬🇩"},
    {"name": "Guatemala", "code": "+502", "flag": "🇬🇹"},
    {"name": "Guinea", "code": "+224", "flag": "🇬🇳"},
    {"name": "Guinea-Bissau", "code": "+245", "flag": "🇬🇼"},
    {"name": "Guyana", "code": "+592", "flag": "🇬🇾"},
    {"name": "Haiti", "code": "+509", "flag": "🇭🇹"},
    {"name": "Honduras", "code": "+504", "flag": "🇭🇳"},
    {"name": "Hungary", "code": "+36", "flag": "🇭🇺"},
    {"name": "Iceland", "code": "+354", "flag": "🇮🇸"},
    {"name": "India", "code": "+91", "flag": "🇮🇳"},
    {"name": "Indonesia", "code": "+62", "flag": "🇮🇩"},
    {"name": "Iran", "code": "+98", "flag": "🇮🇷"},
    {"name": "Iraq", "code": "+964", "flag": "🇮🇶"},
    {"name": "Ireland", "code": "+353", "flag": "🇮🇪"},
    {"name": "Israel", "code": "+972", "flag": "🇮🇱"},
    {"name": "Italy", "code": "+39", "flag": "🇮🇹"},
    {"name": "Jamaica", "code": "+1-876", "flag": "🇯🇲"},
    {"name": "Japan", "code": "+81", "flag": "🇯🇵"},
    {"name": "Jordan", "code": "+962", "flag": "🇯🇴"},
    {"name": "Kazakhstan", "code": "+7", "flag": "🇰🇿"},
    {"name": "Kenya", "code": "+254", "flag": "🇰🇪"},
    {"name": "Kiribati", "code": "+686", "flag": "🇰🇮"},
    {"name": "Kuwait", "code": "+965", "flag": "🇰🇼"},
    {"name": "Kyrgyzstan", "code": "+996", "flag": "🇰🇬"},
    {"name": "Laos", "code": "+856", "flag": "🇱🇦"},
    {"name": "Latvia", "code": "+371", "flag": "🇱🇻"},
    {"name": "Lebanon", "code": "+961", "flag": "🇱🇧"},
    {"name": "Lesotho", "code": "+266", "flag": "🇱🇸"},
    {"name": "Liberia", "code": "+231", "flag": "🇱🇷"},
    {"name": "Libya", "code": "+218", "flag": "🇱🇾"},
    {"name": "Liechtenstein", "code": "+423", "flag": "🇱🇮"},
    {"name": "Lithuania", "code": "+370", "flag": "🇱🇹"},
    {"name": "Luxembourg", "code": "+352", "flag": "🇱🇺"},
    {"name": "Madagascar", "code": "+261", "flag": "🇲🇬"},
    {"name": "Malawi", "code": "+265", "flag": "🇲🇼"},
    {"name": "Malaysia", "code": "+60", "flag": "🇲🇾"},
    {"name": "Maldives", "code": "+960", "flag": "🇲🇻"},
    {"name": "Mali", "code": "+223", "flag": "🇲🇱"},
    {"name": "Malta", "code": "+356", "flag": "🇲🇹"},
    {"name": "Marshall Islands", "code": "+692", "flag": "🇲🇭"},
    {"name": "Mauritania", "code": "+222", "flag": "🇲🇷"},
    {"name": "Mauritius", "code": "+230", "flag": "🇲🇺"},
    {"name": "Mexico", "code": "+52", "flag": "🇲🇽"},
    {"name": "Micronesia", "code": "+691", "flag": "🇫🇲"},
    {"name": "Moldova", "code": "+373", "flag": "🇲🇩"},
    {"name": "Monaco", "code": "+377", "flag": "🇲🇨"},
    {"name": "Mongolia", "code": "+976", "flag": "🇲🇳"},
    {"name": "Montenegro", "code": "+382", "flag": "🇲🇪"},
    {"name": "Morocco", "code": "+212", "flag": "🇲🇦"},
    {"name": "Mozambique", "code": "+258", "flag": "🇲🇿"},
    {"name": "Myanmar", "code": "+95", "flag": "🇲🇲"},
    {"name": "Namibia", "code": "+264", "flag": "🇳🇦"},
    {"name": "Nauru", "code": "+674", "flag": "🇳🇷"},
    {"name": "Nepal", "code": "+977", "flag": "🇳🇵"},
    {"name": "Netherlands", "code": "+31", "flag": "🇳🇱"},
    {"name": "New Zealand", "code": "+64", "flag": "🇳🇿"},
    {"name": "Nicaragua", "code": "+505", "flag": "🇳🇮"},
    {"name": "Niger", "code": "+227", "flag": "🇳🇪"},
    {"name": "Nigeria", "code": "+234", "flag": "🇳🇬"},
    {"name": "North Korea", "code": "+850", "flag": "🇰🇵"},
    {"name": "North Macedonia", "code": "+389", "flag": "🇲🇰"},
    {"name": "Norway", "code": "+47", "flag": "🇳🇴"},
    {"name": "Oman", "code": "+968", "flag": "🇴🇲"},
    {"name": "Pakistan", "code": "+92", "flag": "🇵🇰"},
    {"name": "Palau", "code": "+680", "flag": "🇵🇼"},
    {"name": "Palestine", "code": "+970", "flag": "🇵🇸"},
    {"name": "Panama", "code": "+507", "flag": "🇵🇦"},
    {"name": "Papua New Guinea", "code": "+675", "flag": "🇵🇬"},
    {"name": "Paraguay", "code": "+595", "flag": "🇵🇾"},
    {"name": "Peru", "code": "+51", "flag": "🇵🇪"},
    {"name": "Philippines", "code": "+63", "flag": "🇵🇭"},
    {"name": "Poland", "code": "+48", "flag": "🇵🇱"},
    {"name": "Portugal", "code": "+351", "flag": "🇵🇹"},
    {"name": "Qatar", "code": "+974", "flag": "🇶🇦"},
    {"name": "Romania", "code": "+40", "flag": "🇷🇴"},
    {"name": "Russia", "code": "+7", "flag": "🇷🇺"},
    {"name": "Rwanda", "code": "+250", "flag": "🇷🇼"},
    {"name": "Saint Kitts and Nevis", "code": "+1-869", "flag": "🇰🇳"},
    {"name": "Saint Lucia", "code": "+1-758", "flag": "🇱🇨"},
    {"name": "Saint Vincent and the Grenadines", "code": "+1-784", "flag": "🇻🇨"},
    {"name": "Samoa", "code": "+685", "flag": "🇼🇸"},
    {"name": "San Marino", "code": "+378", "flag": "🇸🇲"},
    {"name": "Sao Tome and Principe", "code": "+239", "flag": "🇸🇹"},
    {"name": "Saudi Arabia", "code": "+966", "flag": "🇸🇦"},
    {"name": "Senegal", "code": "+221", "flag": "🇸🇳"},
    {"name": "Serbia", "code": "+381", "flag": "🇷🇸"},
    {"name": "Seychelles", "code": "+248", "flag": "🇸🇨"},
    {"name": "Sierra Leone", "code": "+232", "flag": "🇸🇱"},
    {"name": "Singapore", "code": "+65", "flag": "🇸🇬"},
    {"name": "Slovakia", "code": "+421", "flag": "🇸🇰"},
    {"name": "Slovenia", "code": "+386", "flag": "🇸🇮"},
    {"name": "Solomon Islands", "code": "+677", "flag": "🇸🇧"},
    {"name": "Somalia", "code": "+252", "flag": "🇸🇴"},
    {"name": "South Africa", "code": "+27", "flag": "🇿🇦"},
    {"name": "South Korea", "code": "+82", "flag": "🇰🇷"},
    {"name": "South Sudan", "code": "+211", "flag": "🇸🇸"},
    {"name": "Spain", "code": "+34", "flag": "🇪🇸"},
    {"name": "Sri Lanka", "code": "+94", "flag": "🇱🇰"},
    {"name": "Sudan", "code": "+249", "flag": "🇸🇩"},
    {"name": "Suriname", "code": "+597", "flag": "🇸🇷"},
    {"name": "Sweden", "code": "+46", "flag": "🇸🇪"},
    {"name": "Switzerland", "code": "+41", "flag": "🇨🇭"},
    {"name": "Syria", "code": "+963", "flag": "🇸🇾"},
    {"name": "Taiwan", "code": "+886", "flag": "🇹🇼"},
    {"name": "Tajikistan", "code": "+992", "flag": "🇹🇯"},
    {"name": "Tanzania", "code": "+255", "flag": "🇹🇿"},
    {"name": "Thailand", "code": "+66", "flag": "🇹🇭"},
    {"name": "Timor-Leste", "code": "+670", "flag": "🇹🇱"},
    {"name": "Togo", "code": "+228", "flag": "🇹🇬"},
    {"name": "Tonga", "code": "+676", "flag": "🇹🇴"},
    {"name": "Trinidad and Tobago", "code": "+1-868", "flag": "🇹🇹"},
    {"name": "Tunisia", "code": "+216", "flag": "🇹🇳"},
    {"name": "Turkey", "code": "+90", "flag": "🇹🇷"},
    {"name": "Turkmenistan", "code": "+993", "flag": "🇹🇲"},
    {"name": "Tuvalu", "code": "+688", "flag": "🇹🇻"},
    {"name": "Uganda", "code": "+256", "flag": "🇺🇬"},
    {"name": "Ukraine", "code": "+380", "flag": "🇺🇦"},
    {"name": "United Arab Emirates", "code": "+971", "flag": "🇦🇪"},
    {"name": "United Kingdom", "code": "+44", "flag": "🇬🇧"},
    {"name": "United States", "code": "+1", "flag": "🇺🇸"},
    {"name": "Uruguay", "code": "+598", "flag": "🇺🇾"},
    {"name": "Uzbekistan", "code": "+998", "flag": "🇺🇿"},
    {"name": "Vanuatu", "code": "+678", "flag": "🇻🇺"},
    {"name": "Vatican City", "code": "+379", "flag": "🇻🇦"},
    {"name": "Venezuela", "code": "+58", "flag": "🇻🇪"},
    {"name": "Vietnam", "code": "+84", "flag": "🇻🇳"},
    {"name": "Yemen", "code": "+967", "flag": "🇾🇪"},
    {"name": "Zambia", "code": "+260", "flag": "🇿🇲"},
    {"name": "Zimbabwe", "code": "+263", "flag": "🇿🇼"},
  ];

  @override
  void initState() {
    super.initState();
    _countryCodeController.text = "+91";
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _usernameController.text = prefs.getString(_kUsername) ?? '';
    _nameController.text = prefs.getString(_kName) ?? '';
    _contactController.text = prefs.getString(_kContact) ?? '';
    _dobController.text = prefs.getString(_kDob) ?? '';
    _bioController.text = prefs.getString(_kBio) ?? '';
    _countryCodeController.text = prefs.getString(_kCountryCode) ?? '+91';
    _selectedGender = prefs.getString(_kGender);
    _currentFlag = prefs.getString(_kFlag) ?? '🇮🇳';

    final imageBase64 = prefs.getString(_kImage);
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        _selectedImageBytes = base64Decode(imageBase64);
      } catch (_) {
        _selectedImageBytes = null;
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, _usernameController.text.trim());
    await prefs.setString(_kName, _nameController.text.trim());
    await prefs.setString(_kContact, _contactController.text.trim());
    await prefs.setString(_kDob, _dobController.text.trim());
    await prefs.setString(_kBio, _bioController.text.trim());
    await prefs.setString(_kCountryCode, _countryCodeController.text.trim());
    if (_selectedGender != null) {
      await prefs.setString(_kGender, _selectedGender!);
    } else {
      await prefs.remove(_kGender);
    }
    await prefs.setString(_kFlag, _currentFlag);

    if (_selectedImageBytes != null) {
      final base64Image = base64Encode(_selectedImageBytes!);
      await prefs.setString(_kImage, base64Image);
    } else {
      await prefs.remove(_kImage);
    }

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved'), duration: Duration(milliseconds: 800)),
    );

    // Navigate to settings page (replacement as before)
    if (mounted) {
      Navigator.pushReplacement(context, _smoothRoute(const SettingsPage()));
    }
  }

  void _updateFlag(String input) {
    final filter = input.trim().toLowerCase();
    final found = _countries.firstWhere(
      (c) =>
          c["code"]!.toLowerCase() == filter ||
          c["name"]!.toLowerCase() == filter ||
          c["code"]!.toLowerCase().contains(filter) ||
          c["name"]!.toLowerCase().contains(filter),
      orElse: () => {},
    );

    if (found.isNotEmpty) {
      setState(() {
        _currentFlag = found["flag"] ?? _currentFlag;
        _countryCodeController.text = found["code"] ?? _countryCodeController.text;
      });
    } else {
      // if user typed e.g. +1-242 or partial, just update flag only if exact match found
      // do nothing otherwise (keep current flag)
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B6B4A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? picked;
      if (kIsWeb) {
        picked = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      } else {
        picked = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );
      }

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() {
            _selectedImageBytes = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image')));
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            if (_selectedImageBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _selectedImageBytes = null);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: label == "Date of Birth",
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Profile",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Photo section
                  InkWell(
                    onTap: _showImageSourceActionSheet,
                    borderRadius: BorderRadius.circular(50),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _selectedImageBytes != null
                                    ? Image.memory(
                                        _selectedImageBytes!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          "Photo",
                                          style: TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ),
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 2, bottom: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: Icon(Icons.camera_alt, size: 16, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "(choose a picture)",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Username
                  _buildTextField("Username", _usernameController),
                  const SizedBox(height: 20),

                  // Name
                  _buildTextField("Name", _nameController),
                  const SizedBox(height: 10),

                  // Country + Contact
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _countryCodeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                            prefixText: _currentFlag.isNotEmpty ? '$_currentFlag ' : null,
                            suffixIcon: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              onSelected: (value) {
                                _updateFlag(value);
                              },
                              itemBuilder: (context) {
                                String filter = _countryCodeController.text.toLowerCase();
                                final filteredCountries = _countries.where(
                                  (c) =>
                                      c["code"]!.toLowerCase().contains(filter) ||
                                      c["name"]!.toLowerCase().contains(filter),
                                ).toList();
                                return filteredCountries.map((c) {
                                  return PopupMenuItem<String>(
                                    value: c["code"]!,
                                    child: Row(
                                      children: [
                                        Text(c["flag"]!, style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Text('${c["name"]} (${c["code"]})'),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (value) => _updateFlag(value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField("Contact No", _contactController, keyboardType: TextInputType.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // DOB
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField("Date of Birth", _dobController),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gender
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Radio<String>(
                              value: "Male",
                              groupValue: _selectedGender,
                              activeColor: const Color(0xFF8B6B4A),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                            const Text("Male"),
                            const SizedBox(width: 20),
                            Radio<String>(
                              value: "Female",
                              groupValue: _selectedGender,
                              activeColor: const Color(0xFF8B6B4A),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                            const Text("Female"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bio
                  _buildTextField("Bio", _bioController, maxLines: 3),
                  const SizedBox(height: 20),

                  // Save
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6B4A),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _saveProfile,
                    child: const Text("Save", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
    );
  }
}
