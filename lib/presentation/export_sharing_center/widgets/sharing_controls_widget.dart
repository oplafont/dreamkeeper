import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class SharingControlsWidget extends StatefulWidget {
  final Function(String) onShareOptionTap;

  const SharingControlsWidget({super.key, required this.onShareOptionTap});

  @override
  State<SharingControlsWidget> createState() => _SharingControlsWidgetState();
}

class _SharingControlsWidgetState extends State<SharingControlsWidget> {
  bool _usePassword = true;
  bool _setExpiration = true;
  bool _trackAccess = false;
  String _expirationPeriod = '7 days';
  String _passwordStrength = 'Medium';

  final List<String> _expirationOptions = [
    '1 day',
    '3 days',
    '7 days',
    '30 days',
    'Never',
  ];
  final List<String> _passwordOptions = ['Low', 'Medium', 'High'];

  final List<Map<String, dynamic>> _shareOptions = [
    {
      'title': 'Secure Link',
      'description': 'Generate password-protected shareable link',
      'icon': Icons.link,
      'color': Color(0xFF8B5CF6),
      'action': 'secure_link',
    },
    {
      'title': 'Email Share',
      'description': 'Send directly to email with encryption',
      'icon': Icons.email,
      'color': Color(0xFF3B82F6),
      'action': 'email',
    },
    {
      'title': 'QR Code',
      'description': 'Generate QR code for quick access',
      'icon': Icons.qr_code,
      'color': Color(0xFF10B981),
      'action': 'qr_code',
    },
    {
      'title': 'Professional Portal',
      'description': 'Share via secure healthcare portal',
      'icon': Icons.medical_services,
      'color': Color(0xFFEF4444),
      'action': 'portal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      height: 85.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Sharing Controls',
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

          // Security Settings
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
                    Icon(Icons.security, color: Color(0xFF8B5CF6), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Security Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Password Protection
                SwitchListTile(
                  title: const Text(
                    'Password Protection',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Require password to access shared content',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _usePassword,
                  onChanged: (value) {
                    setState(() {
                      _usePassword = value;
                    });
                  },
                  activeColor: const Color(0xFF8B5CF6),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),

                if (_usePassword) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Password Strength:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _passwordStrength,
                        dropdownColor: const Color(0xFF1E1B4B),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        underline: const SizedBox.shrink(),
                        onChanged: (value) {
                          setState(() {
                            _passwordStrength = value!;
                          });
                        },
                        items: _passwordOptions.map((strength) {
                          return DropdownMenuItem(
                            value: strength,
                            child: Text(strength),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],

                const Divider(color: Color(0xFF4C1D95)),

                // Expiration Settings
                SwitchListTile(
                  title: const Text(
                    'Set Expiration',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Automatically expire shared links',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _setExpiration,
                  onChanged: (value) {
                    setState(() {
                      _setExpiration = value;
                    });
                  },
                  activeColor: const Color(0xFF8B5CF6),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),

                if (_setExpiration) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Expires in:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _expirationPeriod,
                        dropdownColor: const Color(0xFF1E1B4B),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        underline: const SizedBox.shrink(),
                        onChanged: (value) {
                          setState(() {
                            _expirationPeriod = value!;
                          });
                        },
                        items: _expirationOptions.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],

                const Divider(color: Color(0xFF4C1D95)),

                // Access Tracking
                SwitchListTile(
                  title: const Text(
                    'Track Access',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Monitor when and who accesses the content',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _trackAccess,
                  onChanged: (value) {
                    setState(() {
                      _trackAccess = value;
                    });
                  },
                  activeColor: const Color(0xFF8B5CF6),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Share Options
          const Text(
            'Sharing Methods',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _shareOptions.length,
              itemBuilder: (context, index) {
                return _buildShareOptionCard(_shareOptions[index]);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Active Shares Summary
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
                    Icon(Icons.share, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Active Shares',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildShareStat('3', 'Active Links'),
                    const SizedBox(width: 20),
                    _buildShareStat('12', 'Total Views'),
                    const SizedBox(width: 20),
                    _buildShareStat('2', 'Expiring Soon'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptionCard(Map<String, dynamic> option) {
    return GestureDetector(
      onTap: () => _handleShareOption(option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF312E81),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4C1D95)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: option['color'].withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: option['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: option['color'], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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

  void _handleShareOption(Map<String, dynamic> option) {
    HapticFeedback.lightImpact();

    switch (option['action']) {
      case 'secure_link':
        _generateSecureLink();
        break;
      case 'email':
        _showEmailDialog();
        break;
      case 'qr_code':
        _generateQRCode();
        break;
      case 'portal':
        _shareToPortal();
        break;
    }
  }

  void _generateSecureLink() {
    // Simulate link generation
    const mockLink = 'https://dreamdecoder.app/share/abc123xyz';

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
              const Icon(Icons.link, color: Color(0xFF8B5CF6), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Secure Link Generated',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF312E81),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        mockLink,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(text: mockLink),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_usePassword)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Password: DreamShare2024',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailDialog() {
    final emailController = TextEditingController();

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
              const Icon(Icons.email, color: Color(0xFF3B82F6), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Share via Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter email address',
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
                        Navigator.pop(context);
                        widget.onShareOptionTap(
                          'Email: ${emailController.text}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Send'),
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

  void _generateQRCode() {
    widget.onShareOptionTap('QR Code');
  }

  void _shareToPortal() {
    widget.onShareOptionTap('Professional Portal');
  }
}
