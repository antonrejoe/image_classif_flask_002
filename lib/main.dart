import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:html/parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerDemo(),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var result = "";

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      result = "";
      setState(() {
        _image = image;
        file = image != null ? File(image.path) : null;
      });
      if (file != null) {
        await uploadImage();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    print('Image picked successfully: $_image');
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    var uri = Uri.parse('https://cat-breed-classifer-c2zvybgmgq-uc.a.run.app/upload');
    var request = http.MultipartRequest('POST', uri);

    String? mimeType = lookupMimeType(_image!.path) ?? 'application/octet-stream';
    var mimeTypeData = mimeType.split('/');
    
    request.files.add(await http.MultipartFile.fromPath(
      'photo',
      _image!.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      setState(() {
        var resultData = json.decode(responseBody);
        var label = resultData['result'];
        var probability = resultData['probability'];
        result = "Label: $label, Probability: $probability";
      });
    } else {
      setState(() {
        result = 'Failed to upload image';
      });
      print('Failed to upload image');
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Cat breed classifier'),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           if (_image != null)
  //             Image.file(
  //               File(_image!.path),
  //               height: 500,
  //               width: 500,
  //               fit: BoxFit.cover,
  //             )
  //           else
  //             Text('No image selected'),
  //           SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: _pickImage,
  //             child: Text('Pick Image from Gallery'),
  //           ),
  //           SizedBox(height: 20),
  //           Text(parse(result).body?.text ?? '',
  //            style: TextStyle(
  //           // Define your text style properties here
  //         fontSize: 16, // Example font size
  //         fontWeight: FontWeight.bold, // Example font weight
  //         fontStyle: FontStyle.italic, // Example font style
  //         color: Colors.blue, // Example text color
  //         // Add more properties as needed
  //       )),],
  //       ),
  //     ),
  //   );
  // }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Cat breed classifier'),
    ),
    body: Container(
      color: Colors.black, // Dark background color
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 500,
                width: 500,
                fit: BoxFit.cover,
              )
            else
              Text(
                'No image selected',
                style: TextStyle(
                  color: Colors.white, // Text color for dark background
                  fontSize: 20, // Adjusted font size for visibility
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            Text(
              parse(result).body?.text ?? '',
              style: TextStyle(
                color: Colors.white, // Text color for dark background
                fontSize: 16, // Adjusted font size for visibility
                fontWeight: FontWeight.bold, // Example font weight
                fontStyle: FontStyle.italic, // Example font style
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
