import 'package:flutter/material.dart';
import 'dart:html';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart' as ImagePickerForWeb;

class FileUploadApp extends StatefulWidget {
  @override
  createState() => _FileUploadAppState();
}

class _FileUploadAppState extends State {

  Uint8List uploadedImage;
  final picker = ImagePicker();
  PickedFile pickedFile;
  String imagePath;
  File _image;
  Io.File _image2;
  String base64image;


  _startFilePicker() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        File file = files[0];
        FileReader reader =  FileReader();
        reader.onLoadEnd.listen((e) async{
          setState(() {
            uploadedImage = reader.result;
            print(e.toString());
            print(file.name);
            print(file.size);
            print(file.relativePath);
            print(files);
            String base64Image = base64Encode(uploadedImage);
            print(base64Image);
          });
          //final bytes = await Io.File().readAsBytes();
        });
        reader.onError.listen((fileEvent) {
          setState(() {
            print("Some Error occured while reading the file");
          });
        });

        reader.readAsArrayBuffer(file);

      }
    });
  }

  // Future getImage() async {
  //   //_startFilePicker();
  //   pickedFile = await picker.getImage(source: ImageSource.gallery);
  //
  //     if (pickedFile != null) {
  //       setState((){
  //         imagePath = pickedFile.path;
  //         print(imagePath);
  //         //base64image = base64Encode(pickedFile.readAsBytesSync());
  //         //print(base64image);
  //         _image2 = Io.File(pickedFile.path);
  //         print(Uri.encodeFull(_image2.path.substring(5)));
  //         print(_image2.uri);
  //         //print(_image2.readAsBytesSync().toString());
  //         // base64image = base64Encode(_image.readAsBytesSync());
  //         // print(base64image);
  //
  //       });
  //       //print(await _image2.readAsBytes());
  //     } else {
  //       print('No image selected.');
  //     }
  // }
  //


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('A Flutter Web file picker'),
        ),
        body: Container(
          child: new Form(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 28),
              child: new Container(
                  width: 350,
                  child: Column(
                      children: [
                        MaterialButton(
                          color: Colors.pink,
                          elevation: 8,
                          highlightElevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          textColor: Colors.white,
                          child: Text('Select a file'),
                          onPressed: () {
                            //getImage();
                            _startFilePicker();
                          },
                        ),
                        uploadedImage == null
                            ? Container(color: Colors.green, height: 200,)
                            : Image.memory(uploadedImage),
                      ]
                  )
              ),
            ),
          ),
        ),
      ),
    );
  } }