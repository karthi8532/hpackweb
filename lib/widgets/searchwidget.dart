import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Stateless Search Box Widget
class Searchbar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const Searchbar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              CupertinoIcons.search,
              color: Colors.grey,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              onChanged: onSearch,
            ),
          ),
          controller.text.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: controller.text.isNotEmpty ? onClear : null,
                    child: Icon(
                      CupertinoIcons.clear_circled,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );

    // Container(
    //   margin: EdgeInsets.all(12),
    //   child: TextField(
    //     controller: controller,
    //     decoration: InputDecoration(
    //       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    //       hintText: "Search...",
    //       prefixIcon: Icon(Icons.search),
    //       suffixIcon: controller.text.isNotEmpty
    //           ? IconButton(
    //               icon: Icon(Icons.clear),
    //               onPressed: onClear, // Clear input
    //             )
    //           : null,
    //       border: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(8.0),
    //       ),
    //     ),
    //     onChanged: onSearch,
    //   ),
    // );
  }
}
