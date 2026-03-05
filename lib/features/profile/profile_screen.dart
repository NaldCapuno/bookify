import 'package:bookkeeping/core/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/users_dao.dart';
import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';

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
  final TextEditingController _businessTypeController =
      TextEditingController(); // Added for the bottom sheet
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

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

        _selectedBusinessType = user.businessType;
        _businessTypeController.text = user.businessType.displayName;
      
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- NEW: Confirmation Bottom Sheet for Saving ---
  Future<void> _handleSaveWithConfirmation() async {
    FocusScope.of(context).unfocus(); // Close keyboard

    final bool? shouldSave = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return const AppConfirmationSheet(
          title: 'Save Changes?',
          message: 'Are you sure you want to update your profile information?',
          confirmLabel: 'Save',
          confirmColor: Color(0xFF1A1C1E),
          icon: Icons.save_outlined,
        );
      },
    );

    if (shouldSave == true) {
      await _saveChanges();
    }
  }

  Future<void> _saveChanges() async {
    if (_userId == null) return;

    // 1. Pre-submission Validation
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();

    if (username.isEmpty || email.isEmpty) {
      if (mounted) {
        AppToast.show(
          context,
          message:
              'Failed to update profile. Username and Email cannot be empty.',
          isError: true,
        );
      }
      return; // Stop here and don't call the service
    }

    // 2. Proceed with update if validation passes
    final success = await _userService.saveProfileUpdates(
      id: _userId!,
      username: username,
      email: email,
      businessName: _businessNameController.text,
      businessType: _selectedBusinessType,
      businessAddress: _businessAddressController.text,
      contactNumber: _contactNumberController.text,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _headerUsername = username;
          _headerEmail = email;
        });
      }

      AppToast.show(
        context,
        message: success
            ? 'Profile updated successfully!'
            : 'Failed to update profile.',
        isError: !success,
      );
    }
  }

  // --- NEW: Bottom Sheet for Business Type Selection ---
  Future<void> _showBusinessTypePicker() async {
    FocusScope.of(context).unfocus(); // Close keyboard before opening sheet

    final BusinessType? picked = await showModalBottomSheet<BusinessType>(
      context: context,
      isScrollControlled: true, // Allows the sheet to size properly with lists
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Select Business Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: BusinessType.values.map((type) {
                        final isSelected = _selectedBusinessType == type;
                        return ListTile(
                          title: Text(
                            type.displayName,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1A1C1E),
                                )
                              : null,
                          onTap: () => Navigator.pop(context, type),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // If the user picked a value, update the state and text field
    if (picked != null) {
      setState(() {
        _selectedBusinessType = picked;
        _businessTypeController.text = picked.displayName;
      });
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
    _businessTypeController.dispose();
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

                        _buildFieldLabel('Contact Number'),
                        _buildTextField(
                          '+63 912 345 6789',
                          controller: _contactNumberController,
                        ),

                        _buildFieldLabel('Business Name'),
                        _buildTextField(
                          'Enter your business name',
                          controller: _businessNameController,
                        ),

                        _buildFieldLabel('Business Type'),
                        // Updated to use the text field with an onTap handler
                        _buildTextField(
                          'Select Business Type',
                          controller: _businessTypeController,
                          isDropdown: true,
                          onTap: _showBusinessTypePicker,
                        ),

                        _buildFieldLabel('Business Address'),
                        _buildTextField(
                          'Enter your business address',
                          controller: _businessAddressController,
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

  // --- UPDATED: Added onTap parameter ---
  Widget _buildTextField(
    String hint, {
    bool isDropdown = false,
    TextEditingController? controller,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly:
          isDropdown, // Makes it uneditable if it's meant to trigger a bottom sheet
      onTap: onTap,
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
        onPressed:
            _handleSaveWithConfirmation, // Wires to the confirmation sheet
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

// ==========================================
// APP CONFIRMATION SHEET WIDGET
// ==========================================
class AppConfirmationSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final IconData icon;

  const AppConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(icon, color: confirmColor, size: 50),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    confirmLabel,
                    style: const TextStyle(color: Colors.white),
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
