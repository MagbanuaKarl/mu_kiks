import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback? onScanRequested;

  const HomeSearchBar({
    super.key,
    required this.onSearch,
    this.onScanRequested,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search song, playlist, and artist',
        hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: onScanRequested != null
            ? IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white70),
                onPressed: onScanRequested,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      ),
      style: AppTextStyles.body.copyWith(color: Colors.white),
      onChanged: onSearch,
    );
  }
}
