import 'dart:ui';

import 'package:flutter/material.dart';

Color getRoleColor(String? role) {
  if (role == "Approved") {
    return Colors.green;
  } else if (role == "Reject") {
    return Colors.red;
  } else if (role == "Pending") {
    return Colors.blueAccent;
  } else if (role == "Cancelled") {
    return Colors.cyanAccent;
  } else if (role == "Project Manager") {
    return Colors.cyanAccent;
  } else if (role == "Business Analyst") {
    return Colors.deepPurpleAccent;
  } else if (role == "UI/UX Designer") {
    return Colors.indigoAccent;
  }
  return Colors.black38;
}
