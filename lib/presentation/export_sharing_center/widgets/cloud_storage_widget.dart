import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class CloudStorageWidget extends StatefulWidget {
  final Function(String) onCloudServiceTap;

  const CloudStorageWidget({super.key, required this.onCloudServiceTap});

  @override
  State<CloudStorageWidget> createState() => _CloudStorageWidgetState();
}

class _CloudStorageWidgetState extends State<CloudStorageWidget> {
  String _selectedPath = '/DreamDecoder/Exports';
  bool _createFolder = true;
  Map<String, bool> _serviceStatus = {
    'Google Drive': true,
    'iCloud': false,
    'Dropbox': false,
    'OneDrive': false,
  };

  final List<Map<String, dynamic>> _cloudServices = [
    {
      'name': 'Google Drive',
      'icon': Icons.cloud,
      'color': Color(0xFF4285F4),
      'description': 'Save to your Google Drive account',
      'storage': '15 GB free',
      'connected': true,
    },
    {
      'name': 'iCloud',
      'icon': Icons.cloud,
      'color': Color(0xFF007AFF),
      'description': 'Save to your iCloud Drive',
      'storage': '5 GB free',
      'connected': false,
    },
    {
      'name': 'Dropbox',
      'icon': Icons.cloud_upload,
      'color': Color(0xFF0061FF),
      'description': 'Save to your Dropbox account',
      'storage': '2 GB free',
      'connected': false,
    },
    {
      'name': 'OneDrive',
      'icon': Icons.cloud_queue,
      'color': Color(0xFF0078D4),
      'description': 'Save to your Microsoft OneDrive',
      'storage': '5 GB free',
      'connected': false,
    },
  ];

  final List<String> _folderPaths = [
    '/DreamDecoder/Exports',
    '/Documents/DreamDecoder',
    '/Health/Dream Analysis',
    '/Personal/Dreams',
    'Custom Path...',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      height: 80.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Cloud Storage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Storage Path Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF312E81),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4C1D95)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.folder, color: Color(0xFF8B5CF6), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Storage Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Folder Path Selection
                const Text(
                  'Save to folder:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPath,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: const Color(0xFF1E1B4B),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      if (value == 'Custom Path...') {
                        _showCustomPathDialog();
                      } else {
                        setState(() {
                          _selectedPath = value!;
                        });
                      }
                    },
                    items: _folderPaths.map((path) {
                      return DropdownMenuItem(
                        value: path,
                        child: Text(path),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Create Folder Option
                SwitchListTile(
                  title: const Text(
                    'Create dated subfolder',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Organize exports by date (e.g., /Exports/2024-01)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _createFolder,
                  onChanged: (value) {
                    setState(() {
                      _createFolder = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF8B5CF6),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Available Services
          const Text(
            'Available Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _cloudServices.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(_cloudServices[index]);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Storage Usage Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4C1D95)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storage, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Storage Summary',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStorageStat('Connected', '1'),
                    const SizedBox(width: 20),
                    _buildStorageStat('Available', '15 GB'),
                    const SizedBox(width: 20),
                    _buildStorageStat('Used Today', '23 MB'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isConnected = service['connected'] as bool;

    return GestureDetector(
      onTap: () => _handleServiceTap(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF312E81),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected ? service['color'] : const Color(0xFF4C1D95),
            width: isConnected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: service['color'].withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: service['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        service['name'],
                        style: TextStyle(
                          color: isConnected ? Colors.white : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Connected',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['storage'],
                    style: TextStyle(
                      color: service['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                if (isConnected) ...[
                  IconButton(
                    onPressed: () => _selectService(service['name']),
                    icon: const Icon(
                      Icons.cloud_upload,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const Text(
                    'Upload',
                    style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 10),
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () => _connectService(service['name']),
                    icon: const Icon(
                      Icons.add_link,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                  const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  void _handleServiceTap(Map<String, dynamic> service) {
    if (service['connected']) {
      _selectService(service['name']);
    } else {
      _connectService(service['name']);
    }
  }

  void _selectService(String serviceName) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload,
                color: _getServiceColor(serviceName),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Upload to $serviceName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your export will be saved to:\n$_selectedPath${_createFolder ? '/2024-01' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(
                          context,
                        ); // Close the cloud storage sheet
                        widget.onCloudServiceTap(serviceName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getServiceColor(serviceName),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _connectService(String serviceName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link,
                color: _getServiceColor(serviceName),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect $serviceName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You will be redirected to $serviceName to authorize access. Your credentials are never stored by DreamDecoder.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Simulate connection
                        setState(() {
                          _serviceStatus[serviceName] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Connected to $serviceName successfully',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getServiceColor(serviceName),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Connect'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomPathDialog() {
    final pathController = TextEditingController(text: _selectedPath);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Custom Folder Path',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pathController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '/path/to/folder',
                  hintStyle: TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Color(0xFF312E81),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPath = pathController.text.isNotEmpty
                              ? pathController.text
                              : '/DreamDecoder/Exports';
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getServiceColor(String serviceName) {
    switch (serviceName) {
      case 'Google Drive':
        return const Color(0xFF4285F4);
      case 'iCloud':
        return const Color(0xFF007AFF);
      case 'Dropbox':
        return const Color(0xFF0061FF);
      case 'OneDrive':
        return const Color(0xFF0078D4);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}
