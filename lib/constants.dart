import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kTextFieldDecoration = InputDecoration(
  hintText: "Enter the value",
  labelStyle: TextStyle(color: Colors.black),
  border: OutlineInputBorder(),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2),
  ),
);
