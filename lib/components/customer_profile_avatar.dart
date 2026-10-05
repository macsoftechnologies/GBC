import 'package:flutter/material.dart';

class CustomerProfileAvatar extends StatefulWidget {
  final String? profile;
  final double size;
  final Widget? fallback;

  const CustomerProfileAvatar({
    super.key,
    required this.profile,
    required this.size,
    this.fallback,
  });

  @override
  State<CustomerProfileAvatar> createState() => _CustomerProfileAvatarState();
}

class _CustomerProfileAvatarState extends State<CustomerProfileAvatar> {
  int _attemptIndex = 0;
  List<String> _candidates = [];

  @override
  void initState() {
    super.initState();
    _computeCandidates();
  }

  @override
  void didUpdateWidget(covariant CustomerProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _attemptIndex = 0;
      _computeCandidates();
    }
  }

  void _computeCandidates() {
    final raw = widget.profile;
    if (raw == null) {
      _candidates = [];
      return;
    }
    String clean = raw.trim().replaceAll(r'\', '/');
    if (clean.isEmpty || clean == 'null' || clean == 'undefined') {
      _candidates = [];
      return;
    }

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      _candidates = [clean];
      return;
    }

    while (clean.startsWith('/')) {
      clean = clean.substring(1);
    }

    final Set<String> urls = {};

    if (clean.startsWith('assets/images/')) {
      urls.add("https://dev.gobuddyindia.com/$clean");
      urls.add("https://dev.gobuddyindia.com/$clean");
    } else if (clean.startsWith('uploads/')) {
      urls.add("https://dev.gobuddyindia.com/$clean");
      urls.add("https://dev.gobuddyindia.com/$clean");
    } else {
      urls.add("https://dev.gobuddyindia.com/assets/images/$clean");
      urls.add("https://dev.gobuddyindia.com/uploads/$clean");
      urls.add("https://dev.gobuddyindia.com/uploads/customer/$clean");
      urls.add("https://dev.gobuddyindia.com/uploads/profiles/$clean");
      urls.add("https://dev.gobuddyindia.com/$clean");
      urls.add("https://dev.gobuddyindia.com/assets/images/$clean");
      urls.add("https://dev.gobuddyindia.com/$clean");
    }

    _candidates = urls.toList();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackWidget =
        widget.fallback ??
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: widget.size * 0.6,
            color: Colors.grey.shade600,
          ),
        );

    if (_candidates.isEmpty || _attemptIndex >= _candidates.length) {
      return fallbackWidget;
    }

    final currentUrl = _candidates[_attemptIndex];

    return Image.network(
      currentUrl,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _attemptIndex < _candidates.length) {
            setState(() {
              _attemptIndex++;
            });
          }
        });
        return fallbackWidget;
      },
    );
  }
}
