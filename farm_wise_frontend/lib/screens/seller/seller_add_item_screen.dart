import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_wise_frontend/providers/https_provider.dart';
import 'package:farm_wise_frontend/providers/user_details_provider.dart';

import '../loading_screen.dart';

class SellerAddItemScreen extends StatefulWidget {
  const SellerAddItemScreen({super.key, required this.refreshFunc, });

  final Function refreshFunc;

  @override
  State<SellerAddItemScreen> createState() => _SellerAddItemScreenState();
}

class _SellerAddItemScreenState extends State<SellerAddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  File? image;

  late Uri addProductUrl;

  late DateTime prodDate, avlbFromDate;

  late TextEditingController _itemNameController;
  late TextEditingController _basePriceController;
  late TextEditingController _qntUnitController;
  late TextEditingController _qntPerLotController;
  late TextEditingController _minLotsController;
  late TextEditingController _prodDateController;
  late TextEditingController _avlbFromDateController;
  late TextEditingController _itemDescController;

  late FocusNode _basePriceFocusNode;
  late FocusNode _qntUnitFocusNode;
  late FocusNode _qntPerLotFocusNode;
  late FocusNode _minLotsFocusNode;
  late FocusNode _prodDateFocusNode;
  late FocusNode _avlbFromDateFocusNode;
  late FocusNode _itemDescFocusNode;

  Future pickImage(source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to pick Image: $e");
    }
  }

  Future<String> uploadImage(imageFile) async {
    const url =
        'https://api.imgbb.com/1/upload?key=e045e2fffae70141ef3857d1f362d1e1';

    final mimeType = mime(imageFile.path);
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path,
        contentType: MediaType.parse(mimeType!)));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final uploadedData = jsonDecode(responseData);
      return uploadedData['data']['url'];
    } else {
      throw Exception('Failed to upload image to ImageBB');
    }
  }

  void addItem() async {
    Navigator.of(context).push(PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        }));
    var imageUploadedUrl = await uploadImage(image);
    debugPrint("imageUploadedUrl : $imageUploadedUrl");

    var updatedDataSent = json.encode({
      "userId": loggedInUserDetails.userId,
      "productName": _itemNameController.text,
      "basePrice": int.parse(_basePriceController.text),
      "quantityPerLot": int.parse(_qntPerLotController.text),
      "quantityUnit": _qntUnitController.text,
      "minNoLot": int.parse(_minLotsController.text),
      "productDesc": _itemDescController.text,
      "productImages": [imageUploadedUrl].toList(),
      "producedDate": prodDate.toUtc().toString(),
      "availableFrom": avlbFromDate.toUtc().toString(),
      "reviews": [].toList(),
      "ratings": 0,
      "ratedUser": [].toList(),
      "location": "Tolgate",
      "availStatus": true
    });
    http
        .post(
      addProductUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
      body: updatedDataSent,
    )
        .then((response) {
      var addProductResp = json.decode(response.body);
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        if (addProductResp['msg'] == 'Product Added successfully') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Product added succesfully',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('okay'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  "Couldn't add product.",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                content: const Text("Try again later."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Something went wrong.',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              content: const Text("Please try again later."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('okay'),
                ),
              ],
            );
          },
        );
      }
      widget.refreshFunc();
    });
  }

  @override
  void initState() {
    super.initState();

    addProductUrl = Uri.http(
      authority,
      "api/farmer/addproduct",
    );

    _itemNameController = TextEditingController();
    _basePriceController = TextEditingController();
    _qntUnitController = TextEditingController();
    _qntPerLotController = TextEditingController();
    _minLotsController = TextEditingController();
    _prodDateController = TextEditingController();
    _avlbFromDateController = TextEditingController();
    _itemDescController = TextEditingController();

    _basePriceFocusNode = FocusNode();
    _qntUnitFocusNode = FocusNode();
    _qntPerLotFocusNode = FocusNode();
    _minLotsFocusNode = FocusNode();
    _prodDateFocusNode = FocusNode();
    _avlbFromDateFocusNode = FocusNode();
    _itemDescFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _itemNameController.dispose();
    _basePriceController.dispose();
    _qntPerLotController.dispose();
    _minLotsController.dispose();
    _prodDateController.dispose();
    _avlbFromDateController.dispose();
    _itemDescController.dispose();

    _basePriceFocusNode.dispose();
    _qntUnitFocusNode.dispose();
    _qntPerLotFocusNode.dispose();
    _minLotsFocusNode.dispose();
    _prodDateFocusNode.dispose();
    _avlbFromDateFocusNode.dispose();
    _itemDescFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 26),
            child: Column(
              children: [
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _itemNameController,
                  autofocus: true,
                  onFieldSubmitted: (value) =>
                      _basePriceFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Item Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _basePriceController,
                  focusNode: _basePriceFocusNode,
                  onFieldSubmitted: (value) => _qntUnitFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Base Price',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _qntUnitController,
                  focusNode: _qntUnitFocusNode,
                  onFieldSubmitted: (value) => _minLotsFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Quantity unit',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid quantity unit';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _qntPerLotController,
                  focusNode: _qntPerLotFocusNode,
                  onFieldSubmitted: (value) => _minLotsFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Quantity per lot',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _minLotsController,
                  focusNode: _minLotsFocusNode,
                  onFieldSubmitted: (value) =>
                      _prodDateFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Minimum no. of Lot(s)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid no. of lots';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _prodDateController,
                  focusNode: _prodDateFocusNode,
                  readOnly: true,
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    ).then(
                      (value) {
                        if (value != null) {
                          prodDate = value;
                          setState(() {
                            _prodDateController.text =
                                "${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}";
                          });
                        }
                      },
                    );
                  },
                  onFieldSubmitted: (value) =>
                      _prodDateFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Produced Date',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid date';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _avlbFromDateController,
                  focusNode: _avlbFromDateFocusNode,
                  readOnly: true,
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    ).then(
                      (value) {
                        if (value != null) {
                          avlbFromDate = value;
                          setState(() {
                            _avlbFromDateController.text =
                                "${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}";
                          });
                        }
                      },
                    );
                  },
                  onFieldSubmitted: (value) =>
                      _itemDescFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Available for orders from',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid date';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _itemDescController,
                  focusNode: _itemDescFocusNode,
                  maxLines: 4,
                  minLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    labelText: 'Item description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid comment';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    debugPrint("Add Image");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Pick Image from"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                pickImage(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.photo),
                              label: const Text("Gallery"),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                pickImage(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                              icon:
                                  const Icon(Icons.photo_camera_back_outlined),
                              label: const Text("Camera"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(81, 160, 159, 159),
                      borderRadius: BorderRadius.circular(15),
                      border: const Border(
                        top: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    width: 353,
                    height: 263,
                    child: image == null
                        ? const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Add Image",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Color.fromARGB(255, 252, 96, 85),
                      ),
                      label: const Text(
                        "Discard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 252, 96, 85),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addItem();
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                      ),
                      label: const Text(
                        "Finish",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
