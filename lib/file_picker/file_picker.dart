import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as file_picker;

enum PickerOptions {
  takePhoto,
  gallery,
  file,
}

class FilePicker extends StatefulWidget {
  final Widget child;
  final bool enableCrop;
  final Function(File) onSelect;
  final List<PickerOptions> options;

  const FilePicker(
      {Key? key,
      required this.child,
      required this.options,
      this.enableCrop = false,
      required this.onSelect})
      : super(key: key);

  @override
  State<FilePicker> createState() => _FilePickerState();
}

class _FilePickerState extends State<FilePicker> {
  ImagePicker imagePicker = ImagePicker();

  // Image upload functions

  selectDocument() async {
    FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      widget.onSelect(file);
    }
  }

  void handleImageSelection(PickerOptions option) {
    try {
      switch (option) {
        case PickerOptions.takePhoto:
          uploadImageFromGalleryOrCamera(option);
        case PickerOptions.gallery:
          uploadImageFromGalleryOrCamera(option);
          break;

        case PickerOptions.file:
          selectDocument();
          break;
        default:
          uploadImageFromGalleryOrCamera(PickerOptions.gallery);
      }
    } catch (err) {
      log(err.toString());
    }
  }

  Future<File?> cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  void uploadImageFromGalleryOrCamera(PickerOptions option) async {
    XFile? file = await imagePicker.pickImage(
        source: option == PickerOptions.takePhoto
            ? ImageSource.camera
            : ImageSource.gallery);

    if (file != null) {
      File? croppedFile = File(file.path);
      if (widget.enableCrop) {
        croppedFile = await cropImage(File(file.path));
      }
      if (croppedFile != null) {
        widget.onSelect(croppedFile);
      }
    }
  }

  void _showOptions(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            actions: _buildCupertinoActions(context),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildMaterialOptions(context),
            ),
          );
        },
      );
    }
  }

  List<Widget> _buildMaterialOptions(BuildContext context) {
    return widget.options.map((option) {
      return ListTile(
        title: Row(
          children: [
            Icon(getOptionIcon(option)),
            const SizedBox(width: 10),
            Text(getOptionText(option)),
          ],
        ),
        onTap: () {
          handleImageSelection(option);
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> _buildCupertinoActions(BuildContext context) {
    return widget.options.map((option) {
      return CupertinoActionSheetAction(
        onPressed: () {
          handleImageSelection(option);
          Navigator.pop(context);
        },
        child: Text(getOptionText(option)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOptions(context);
      },
      child: widget.child,
    );
  }
}

String getOptionText(PickerOptions option) {
  switch (option) {
    case PickerOptions.takePhoto:
      return "Take Photo";
    case PickerOptions.gallery:
      return "Choose from Gallery";
    case PickerOptions.file:
      return "Select Document";
  }
}

IconData getOptionIcon(PickerOptions option) {
  switch (option) {
    case PickerOptions.takePhoto:
      return Icons.camera_alt;
    case PickerOptions.gallery:
      return Icons.photo;
    case PickerOptions.file:
      return Icons.folder;
  }
}
