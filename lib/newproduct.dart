import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midtermstiw2044myshop/main.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';

// ignore: must_be_immutable
class NewProduct extends StatefulWidget {
  String base64Image, name, type, price, qty;
  NewProduct({
    this.base64Image,
    this.name,
    this.type,
    this.price,
    this.qty,
  });
  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  File _image;
  final _picker = ImagePicker();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _typeController = new TextEditingController();
  TextEditingController _qtyController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 200, 0),
                child: ElevatedButton(
                  child: Text('Back'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProductList()));
                  },
                ),
              ),
              Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 20),
                elevation: 8,
                shadowColor: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 13, 0, 0),
                        child: Text('Product Details Form',
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      Text('Take a picture from',
                          style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_camera, size: 20),
                            onPressed: () async => _pickImageFromCamera(),
                          ),
                          Text('Camera'),
                          IconButton(
                            icon: const Icon(Icons.photo, size: 20),
                            onPressed: () async => _pickImageFromGallery(),
                          ),
                          Text('Gallery'),
                        ],
                      ),
                      _image == null
                          ? Text('No image selected.')
                          : Image.file(_image),
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _typeController,
                        decoration: InputDecoration(
                          labelText: 'Product Type',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          labelText: 'Product Price',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          labelText: 'Quantity of Product',
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          minWidth: 150,
                          color: Colors.blueAccent,
                          child: Text('Add',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          onPressed: _confirmDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDialog() {
    String name = _nameController.text.toString();
    String type = _typeController.text.toString();
    String price = _priceController.text.toString();
    String qty = _qtyController.text.toString();
    String base64Image = base64Encode(_image.readAsBytesSync());
    if (base64Image == null ||
        name == "" ||
        price == "" ||
        type == "" ||
        qty == "") {
      Fluttertoast.showToast(
          msg: "Please fill in the product's information",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.black,
          fontSize: 16);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text("Add Product "),
            content: new Container(
              height: 40,
              child: Text("Are you sure you want to add this product?"),
            ),
            actions: [
              TextButton(
                  child: Text("Confirm",
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addProduct(name, type, price, qty, base64Image);
                  }),
              TextButton(
                  child: Text("Cancel",
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  Future _pickImageFromCamera() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      maxHeight: 400,
      maxWidth: 400,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
    _cropImage();
  }

  _pickImageFromGallery() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
    _cropImage();
  }

  Future<void> _addProduct(String name, String type, String price, String qty,
      String base64Image) async {
    http.post(Uri.parse("http://yck99.com/myshop/php/newproduct.php"), body: {
      "name": name,
      "type": type,
      "price": price,
      "qty": qty,
      "encoded_string": base64Image,
    }).then((response) {
      print(response.body);

      if (response.body == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.greenAccent,
            textColor: Colors.black,
            fontSize: 16);
        setState(() {
          _image = null;
          _nameController.text = "";
          _typeController.text = "";
          _priceController.text = "";
          _qtyController.text = "";
        });

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProductList()));
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.greenAccent,
            textColor: Colors.black,
            fontSize: 16);
      }
    });
  }

  _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop your image',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {});
    }
  }
} //end newproduct
