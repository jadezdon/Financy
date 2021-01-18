import 'dart:io';

import 'package:Financy/config/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TakePicturePage extends StatefulWidget {
  final String imgUrl;
  TakePicturePage({Key key, this.imgUrl}) : super(key: key);

  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.imgUrl != "") _image = File(widget.imgUrl);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  Widget _displayImg() {
    if (_image != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: FileImage(_image),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          ),
          SizedBox(height: 20),
          FlatButton.icon(
            onPressed: () async {
              await _image.delete();
              setState(() {
                _image = null;
              });
            },
            icon: Icon(
              Icons.delete_outline_outlined,
              color: AppColor.red,
            ),
            label: Text(
              tr("delete"),
              style: TextStyle(color: AppColor.red),
            ),
          )
        ],
      );
    }

    return Text('No image selected.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a picture'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _image?.path);
          },
        ),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: Center(
        child: _displayImg(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
