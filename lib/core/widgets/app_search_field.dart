import 'package:flutter/material.dart';

/// The search input used on Explore and Stays.
///
/// Owns its controller so callers only deal with the text, and shows a clear
/// button once there is something to clear.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.initialValue = '',
    this.autofocus = false,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged(value);
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _handleChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: _handleChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _controller.text.isEmpty
                ? null
                : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                  tooltip: 'Clear search',
                ),
      ),
    );
  }
}

/// A read-only field that behaves like a button — tapping it takes the user
/// to the screen that owns the real search box.
class SearchFieldButton extends StatelessWidget {
  const SearchFieldButton({
    super.key,
    required this.hintText,
    required this.onTap,
  });

  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
