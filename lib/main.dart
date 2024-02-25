import 'dart:developer';
import 'dart:io';

import 'package:file_picker_example/file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
        title: const Text("File Picker"),
      ),
      body: Center(
        child: FilePicker(
          onSelect: (File p0) {
            log("File selected");
          },
          enableCrop: true,
          options: const [
            PickerOptions.takePhoto,
            PickerOptions.file,
            PickerOptions.gallery,
          ],
          child: const Text(
            "Click here",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
