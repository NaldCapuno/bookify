import 'package:flutter/material.dart';

class InventoryView extends StatefulWidget {
  final String actionType; // 'Acquire' or 'Produce'
  const InventoryView({super.key, required this.actionType});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  @override
  Widget build(BuildContext context) {
    final bool isAcquire = widget.actionType == 'Acquire';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          "${widget.actionType} Inventory",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(
              title: isAcquire ? "Raw Materials Cost" : "Production Cost",
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 24),
            _buildInputGroup([
              _buildTextField(
                label: "Item Name",
                icon: Icons.category_outlined,
              ),
              const Divider(),
              _buildTextField(
                label: "Quantity",
                icon: Icons.add_box_outlined,
                isNumber: true,
              ),
              const Divider(),
              _buildTextField(
                label: "Warehouse / Storage Location",
                icon: Icons.location_on_outlined,
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(context, Colors.blue.shade700),
    );
  }

  // Reuse these helper builders across all views for a consistent UI
  Widget _buildInfoCard({required String title, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "\$ 0.00",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, Color color) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Confirm & Save",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
