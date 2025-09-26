import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/equipment.dart';
import '../../utils/theme.dart';
import 'add_equipment_screen.dart';

class EquipmentManagementScreen extends StatefulWidget {
  const EquipmentManagementScreen({super.key});

  @override
  State<EquipmentManagementScreen> createState() => _EquipmentManagementScreenState();
}

class _EquipmentManagementScreenState extends State<EquipmentManagementScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  bool _showMaintenanceOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<Equipment>>(
              stream: FirebaseFirestore.instance
                  .collection('equipment')
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => Equipment.fromFirestore(doc))
                      .toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No equipment found'));
                }
                
                final equipment = _filterEquipment(snapshot.data!);
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: equipment.length,
                  itemBuilder: (context, index) {
                    return _buildEquipmentCard(equipment[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Store context and messenger for async use
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          
          // Show feedback immediately
          
          // Navigate immediately without delay
          try {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const AddEquipmentScreen(),
              ),
            );
          } catch (e) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Error opening Add Equipment: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Equipment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        tooltip: 'Add New Equipment',
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
                      Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('All Categories',)),
                      const DropdownMenuItem(value: 'Audio/Visual', child: Text('Audio/Visual')),
                      const DropdownMenuItem(value: 'Computers', child: Text('Computers')),
                      const DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
                      const DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('All Status')),
                      const DropdownMenuItem(value: 'Available', child: Text('Available')),
                      const DropdownMenuItem(value: 'In Use', child: Text('In Use')),
                      const DropdownMenuItem(value: 'Under Maintenance', child: Text('Under Maintenance')),
                      const DropdownMenuItem(value: 'Disabled', child: Text('Disabled')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _showMaintenanceOnly,
                onChanged: (value) {
                  setState(() {
                    _showMaintenanceOnly = value!;
                  });
                },
              ),
              const Text('Show maintenance items only'),
            ],
          ),
        ],
      ),
    );
  }

  List<Equipment> _filterEquipment(List<Equipment> equipment) {
    return equipment.where((eq) {
      // Category filter
      if (_selectedCategory != 'All' && eq.category != _selectedCategory) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus != 'All') {
        final status = eq.usageStatus;
        if (_selectedStatus == 'Available' && status != 'Available') return false;
        if (_selectedStatus == 'In Use' && status != 'In Use') return false;
        if (_selectedStatus == 'Under Maintenance' && status != 'Under Maintenance') return false;
        if (_selectedStatus == 'Disabled' && status != 'Disabled') return false;
      }
      
      // Maintenance filter
      if (_showMaintenanceOnly && !eq.maintenanceMode) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildEquipmentCard(Equipment equipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipment.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(equipment),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    switch (value) {
                      case 'details':
                        _showEquipmentDetails(equipment);
                        break;
                      case 'edit':
                        _showEditEquipmentDialog(equipment);
                        break;
                      case 'delete':
                        _showDeleteEquipmentDialog(equipment);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Total',
                    '${equipment.totalQuantity}',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Available',
                    '${equipment.availableQuantity}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'In Use',
                    '${equipment.totalQuantity - equipment.availableQuantity}',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: equipment.availabilityPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                equipment.availabilityPercentage > 50 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${equipment.availabilityPercentage.toStringAsFixed(1)}% Available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Equipment equipment) {
    Color color;
    IconData icon;
    
    switch (equipment.usageStatus) {
      case 'Available':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'In Use':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'Under Maintenance':
        color = Colors.red;
        icon = Icons.build;
        break;
      case 'Disabled':
        color = Colors.grey;
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                equipment.usageStatus,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: color.withAlpha(204),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }



  void _showEquipmentDetails(Equipment equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(equipment.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${equipment.category}'),
              Text('Total Quantity: ${equipment.totalQuantity}'),
              Text('Available Quantity: ${equipment.availableQuantity}'),
              Text('Status: ${equipment.usageStatus}'),
              if (equipment.description != null)
                Text('Description: ${equipment.description}'),
              const SizedBox(height: 16),

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }





  void _showEditEquipmentDialog(Equipment equipment) {
    final nameController = TextEditingController(text: equipment.name);
    final descriptionController = TextEditingController(text: equipment.description ?? '');
    final totalQuantityController = TextEditingController(text: equipment.totalQuantity.toString());
    final availableQuantityController = TextEditingController(text: equipment.availableQuantity.toString());
    String selectedCategory = equipment.category;
    bool isEnabled = equipment.isEnabled;
    bool maintenanceMode = equipment.maintenanceMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${equipment.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Equipment Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: 'Audio/Visual', child: Text('Audio/Visual')),
                  const DropdownMenuItem(value: 'Computers', child: Text('Computers')),
                  const DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
                  const DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: totalQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Total Quantity',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: availableQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Available Quantity',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Equipment Enabled'),
                subtitle: Text(isEnabled 
                  ? 'Equipment is enabled and can be used'
                  : 'Equipment is disabled and cannot be used'),
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    isEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Maintenance Mode'),
                subtitle: Text(maintenanceMode 
                  ? 'Equipment is currently under maintenance'
                  : 'Equipment is available for use'),
                value: maintenanceMode,
                onChanged: (value) {
                  setState(() {
                    maintenanceMode = value;
                  });
                },
              ),
              

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final totalQuantity = int.tryParse(totalQuantityController.text.trim()) ?? 0;
              final availableQuantity = int.tryParse(availableQuantityController.text.trim()) ?? 0;
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              if (name.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Please enter equipment name')),
                );
                return;
              }

              if (totalQuantity <= 0) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Total quantity must be greater than 0')),
                );
                return;
              }

              if (availableQuantity > totalQuantity) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Available quantity cannot exceed total quantity')),
                );
                return;
              }

              // Check if reducing total quantity would affect current bookings
              final totalBooked = equipment.totalQuantity - equipment.availableQuantity;
              if (totalQuantity < totalBooked) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Cannot reduce total quantity below currently booked amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final equipmentData = {
                  'name': name,
                  'category': selectedCategory,
                  'description': description.isEmpty ? null : description,
                  'totalQuantity': totalQuantity,
                  'availableQuantity': availableQuantity,
                  'isEnabled': isEnabled,
                  'maintenanceMode': maintenanceMode,
                  'lastUpdated': Timestamp.now(),
                };

                await FirebaseFirestore.instance
                    .collection('equipment')
                    .doc(equipment.id)
                    .update(equipmentData);

                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Equipment updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating equipment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }



  void _showDeleteEquipmentDialog(Equipment equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${equipment.name}"?'),
            const SizedBox(height: 16),

            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              try {
                await FirebaseFirestore.instance
                    .collection('equipment')
                    .doc(equipment.id)
                    .delete();

                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Equipment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting equipment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}