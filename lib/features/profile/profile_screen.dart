import 'package:bookkeeping/features/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/users_dao.dart';
import 'package:bookkeeping/core/database/tables/user_table.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserService _userService;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  // Added state variable for the dropdown
  BusinessType? _selectedBusinessType;

  bool _isLoading = true;
  int? _userId;

  String _headerUsername = '';
  String _headerEmail = '';

  @override
  void initState() {
    super.initState();
    _userService = UserService(UsersDao(appDb));
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getUserProfile();

    if (user != null) {
      setState(() {
        _userId = user.id;

        _headerUsername = user.username;
        _headerEmail = user.email;

        _usernameController.text = user.username;
        _emailController.text = user.email;
        _businessNameController.text = user.business ?? '';
        _businessAddressController.text = user.businessAddress ?? '';
        _contactNumberController.text = user.contactNumber ?? '';

        // Load the existing business type
        _selectedBusinessType = user.businessType;

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_userId == null) return;

    final success = await _userService.saveProfileUpdates(
      id: _userId!,
      username: _usernameController.text,
      email: _emailController.text,
      businessName: _businessNameController.text,
      businessType: _selectedBusinessType, // Pass the selected enum
      businessAddress: _businessAddressController.text,
      contactNumber: _contactNumberController.text,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _headerUsername = _usernameController.text;
          _headerEmail = _emailController.text;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated successfully!'
                : 'Failed to update profile.',
          ),
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        _buildFieldLabel('Username'),
                        _buildTextField(
                          'Enter your username',
                          controller: _usernameController,
                        ),

                        _buildFieldLabel('Email Address'),
                        _buildTextField(
                          'Enter your email address',
                          controller: _emailController,
                        ),

                        _buildFieldLabel('Business Name'),
                        _buildTextField(
                          'Enter your business name',
                          controller: _businessNameController,
                        ),

                        // Added Business Type Dropdown
                        _buildFieldLabel('Business Type'),
                        _buildDropdownField(),

                        _buildFieldLabel('Business Address'),
                        _buildTextField(
                          'Enter your business address',
                          controller: _businessAddressController,
                        ),

                        _buildFieldLabel('Contact Number'),
                        _buildTextField(
                          '+63 912 345 6789',
                          controller: _contactNumberController,
                        ),

                        const SizedBox(height: 32),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Extracted Dropdown builder
  Widget _buildDropdownField() {
    return DropdownButtonFormField<BusinessType>(
      value: _selectedBusinessType,
      decoration: InputDecoration(
        hintText: 'Select Business Type',
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: BusinessType.values.map((BusinessType type) {
        return DropdownMenuItem<BusinessType>(
          value: type,
          child: Text(type.displayName), // Uses the extension created earlier
        );
      }).toList(),
      onChanged: (BusinessType? newValue) {
        setState(() {
          _selectedBusinessType = newValue;
        });
      },
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: const Color(0xFF232D3F),
          child: Text(
            _getInitials(_headerUsername),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _headerUsername,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _headerEmail,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(
    String hint, {
    bool isDropdown = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: isDropdown,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _saveChanges,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save Changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1C1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
