import 'dart:convert';

import 'package:campusmarket/constant/uni_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UniversitySearchField extends StatefulWidget {
  final TextEditingController controller;

  const UniversitySearchField({
    super.key,
    required this.controller,
  });

  @override
  State<UniversitySearchField> createState() => _UniversitySearchFieldState();
}

class _UniversitySearchFieldState extends State<UniversitySearchField> {
  List<String> universities = [];
  List<String> filteredUniversities = [];

  bool isLoading = false;
  bool showDropdown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final searchText = widget.controller.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        filteredUniversities = universities;
      });
    } else {
      setState(() {
        filteredUniversities = universities
            .where(
              (university) => university.toLowerCase().contains(searchText),
            )
            .toList();
      });
    }
  }

  void _showDropdown() {
    setState(() {
      showDropdown = true;

      if (widget.controller.text.trim().isEmpty) {
        filteredUniversities = universities;
      }
    });
  }

  void _selectUniversity(String university) {
    widget.controller.text = university;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(
        offset: widget.controller.text.length,
      ),
    );
    setState(() {
      showDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          onTap: _showDropdown,
          decoration: InputDecoration(
            hintText: 'Search your university',
            prefixIcon: const Icon(Icons.school_outlined),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.controller.clear();

                          setState(() {
                            showDropdown = true;
                            filteredUniversities = universities;
                          });
                        },
                      )
                    : const Icon(Icons.keyboard_arrow_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Dropdown
        if (showDropdown && filteredUniversities.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            constraints: const BoxConstraints(
              maxHeight: 250,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: filteredUniversities.length,
              itemBuilder: (context, index) {
                final university = filteredUniversities[index];

                return InkWell(
                  onTap: () {
                    _selectUniversity(university);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            university,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // No results
        if (showDropdown &&
            !isLoading &&
            widget.controller.text.isNotEmpty &&
            filteredUniversities.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: const Text(
              'No university found',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
