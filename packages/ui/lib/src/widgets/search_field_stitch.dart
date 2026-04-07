import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchFieldStitch extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hintText;
  final Widget? trailingWidget;

  const SearchFieldStitch({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hintText = 'Buscar lugares, calles...',
    this.trailingWidget,
  });

  @override
  State<SearchFieldStitch> createState() => _SearchFieldStitchState();
}

class _SearchFieldStitchState extends State<SearchFieldStitch> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF599265).withOpacity(0.6)
              : Colors.white.withOpacity(0.08),
          width: _isFocused ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(
              CupertinoIcons.search,
              color: _isFocused ? const Color(0xFF599265) : Colors.grey[500],
              size: 20,
            ),
          ),
          Expanded(
            child: Focus(
              onFocusChange: (focused) => setState(() => _isFocused = focused),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
          if (widget.trailingWidget != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: widget.trailingWidget!,
            ),
        ],
      ),
    );
  }
}
