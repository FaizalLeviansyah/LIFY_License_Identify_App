import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_license_plate/constant/route.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/firestore_services_new.dart';
import '../../utilities/dialogs/error_dialog.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  User? user;
  String? uid;
  File? imageFile;
  bool isCameraSelected = true;
  String ocrResult = '';
  bool? isResultInDatabase;
  bool isResultLoading = false;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    uid = user!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: imageFile == null
                        ? EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.4)
                        : const EdgeInsets.only(top: 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        Map<Permission, PermissionStatus> statuses = await [
                          Permission.storage,
                          Permission.camera,
                        ].request();
                        if (statuses[Permission.storage]!.isGranted &&
                            statuses[Permission.camera]!.isGranted) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: const Text('Choose to Scan'),
                                children: [
                                  SimpleDialogOption(
                                    child: const Text('Scan'),
                                    onPressed: () async {
                                      await _imgFromCamera();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  SimpleDialogOption(
                                    child: const Text('Upload'),
                                    onPressed: () async {
                                      await _imgFromGallery();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          print('no permission provided');
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Take Photo',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              imageFile == null
                  ? const Text(
                      '\nNo photo selected yet',
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Image.file(
                            imageFile!,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 39, 39, 39),
                                side: const BorderSide(
                                  width: 3,
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () async {
                                setState(
                                  () {
                                    isResultLoading = true;
                                  },
                                );
                                try {
                                  await _scanImageFlask();
                                  if (ocrResult != '') {
                                    var checker = await resultChecker(
                                        uid: uid!, result: ocrResult);
                                    setState(
                                      () {
                                        isResultInDatabase = checker;
                                      },
                                    );
                                  }
                                } finally {
                                  setState(
                                    () {
                                      isResultLoading = false;
                                    },
                                  );
                                }
                              },
                              child: isResultLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        color: Color.fromRGBO(248, 215, 166, 1),
                                      ),
                                    )
                                  : const Text(
                                      'Scan photo',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(248, 215, 166, 1),
                                          fontSize: 15),
                                    ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _scanImageMlkit();
                                if (ocrResult != '') {
                                  var checker = await resultChecker(
                                      uid: uid!, result: ocrResult);
                                  setState(
                                    () {
                                      isResultInDatabase = checker;
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 39, 39, 39),
                                side: const BorderSide(
                                  width: 3,
                                  color: Color.fromRGBO(248, 215, 166, 1),
                                ),
                              ),
                              child: const Text(
                                'Scan Photo Offline',
                                style: TextStyle(
                                    color: Color.fromRGBO(248, 215, 166, 1),
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                ocrResult,
                style: const TextStyle(color: Colors.white),
              ),
              ocrResult == ''
                  ? const SizedBox(
                      height: 20.0,
                    )
                  : isResultInDatabase == false
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (user != null) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    );
                                    try {
                                      String? filePath = await uploadImage(
                                          uid: uid!,
                                          image: imageFile!,
                                          result: ocrResult);
                                      await createResult(
                                          uid: uid!,
                                          textResult: ocrResult,
                                          filePath: filePath!);
                                      final snackBar = SnackBar(
                                        content: const Text(
                                            'Plate parked successfully'),
                                        action: SnackBarAction(
                                          label: 'OK',
                                          onPressed: () {},
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      print('Error $e');
                                      Navigator.of(context).pop();
                                    }
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            plateRoute, (route) => false);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Enter Parking',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (user != null) {
                                    await deleteResult(
                                        uid: uid!, textResult: ocrResult);
                                    await deleteImage(
                                        uid: uid!, result: ocrResult);
                                    await createHistory(
                                        uid: uid!, textResult: ocrResult);
                                    final snackBar = SnackBar(
                                      content: const Text(
                                          'Plate exited and added to history'),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {},
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            plateRoute, (route) => false);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Exit Parking',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
            ],
          ),
        ),
      ),
    );
  }

  final picker = ImagePicker();

  _imgFromGallery() async {
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50).then(
      (value) {
        if (value != null) {
          _cropImage(File(value.path));
        }
      },
    );
  }

  _imgFromCamera() async {
    await picker.pickImage(source: ImageSource.camera, imageQuality: 50).then(
      (value) {
        if (value != null) {
          _cropImage(File(value.path));
        }
      },
    );
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: "Image Cropper",
            toolbarColor: Color.fromRGBO(248, 215, 166, 1),
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: "Image Cropper",
        )
      ],
    );

    if (croppedFile != null) {
      imageCache.clear();
      setState(
        () {
          imageFile = File(croppedFile.path);
        },
      );
      // reload();
    }
  }

  Future<void> _scanImageFlask() async {
    if (imageFile == null) {
      return await showErrorDialog(context, 'No photo yet, can not scan');
    }
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://ikmalfaris50.pythonanywhere.com/'));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile!.path));
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.toBytes();
        var resultJson = json.decode(utf8.decode(responseBody));
        var resultText = resultJson['result'];
        setState(
          () {
            ocrResult = resultText;
          },
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error : $e');
    }
  }

  Future<void> _scanImageMlkit() async {
    if (imageFile == null) {
      return await showErrorDialog(context, 'No photo yet, can not scan');
    }
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile!);
    final resultText = await textRecognizer.processImage(inputImage);
    setState(
      () {
        ocrResult = resultText.text.replaceAll('\n', ' ');
      },
    );
  }
}
