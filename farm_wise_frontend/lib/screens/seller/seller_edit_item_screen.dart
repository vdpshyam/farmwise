import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

import 'package:image_picker/image_picker.dart';
import 'package:farm_wise_frontend/providers/https_provider.dart';

// import '../../models/product.dart';
import '../../providers/user_details_provider.dart';
import '../loading_screen.dart';

class SellerEditItemScreen extends StatefulWidget {
  const SellerEditItemScreen({super.key, required this.productId});

  final String productId;

  @override
  State<SellerEditItemScreen> createState() => _SellerEditItemScreenState();
}

class _SellerEditItemScreenState extends State<SellerEditItemScreen> {
  //get product details variables
  late String productId, productName, quantityUnit, productDesc;
  late DateTime producedDate, availableFrom;
  late num basePrice, quantityPerLot, minNoLot;
  late bool availStatus;
  late List productImages = [];

  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  File? image;
  late Uri productUpdateUrl, getProductDetailsUrl;
  bool anyDataChanged = false, isImageChanged = false, isImageDeleted = false;
  late DateTime prodDate, availFromDate;

  late TextEditingController _itemNameController;
  late TextEditingController _basePriceController;
  late TextEditingController _qntUnitController;
  late TextEditingController _qntPerLotController;
  late TextEditingController _minLotsController;
  late TextEditingController _prodDateController;
  late TextEditingController _avlbFromDateController;
  late TextEditingController _itemDescController;

  void getProductDetails() {
    http.get(
      getProductDetailsUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductDetailsResp = json.decode(response.body);
        if (getProductDetailsResp["message"] == "Product details found") {
          if (getProductDetailsResp["productDetails"].length > 0) {
            productId = getProductDetailsResp["productDetails"][0]["_id"];
            productName =
                getProductDetailsResp["productDetails"][0]["productName"];
            quantityUnit =
                getProductDetailsResp["productDetails"][0]["quantityUnit"];
            productDesc =
                getProductDetailsResp["productDetails"][0]["productDesc"];
            producedDate = DateTime.parse(
                getProductDetailsResp["productDetails"][0]["producedDate"]);
            availableFrom = DateTime.parse(
                getProductDetailsResp["productDetails"][0]["availableFrom"]);
            basePrice = getProductDetailsResp["productDetails"][0]["basePrice"];
            quantityPerLot =
                getProductDetailsResp["productDetails"][0]["quantityPerLot"];
            minNoLot = getProductDetailsResp["productDetails"][0]["minNoLot"];
            availStatus =
                getProductDetailsResp["productDetails"][0]["availStatus"];
            productImages =
                getProductDetailsResp["productDetails"][0]["productImages"];

            setState(() {
              _itemNameController = TextEditingController(text: productName);
              _basePriceController =
                  TextEditingController(text: basePrice.toString());
              _qntUnitController =
                  TextEditingController(text: quantityUnit.toString());
              _qntPerLotController =
                  TextEditingController(text: quantityPerLot.toString());
              _minLotsController =
                  TextEditingController(text: minNoLot.toString());
              _prodDateController = TextEditingController(
                  text:
                      "${producedDate.toLocal().day}/${producedDate.toLocal().month}/${producedDate.toLocal().year}");
              _avlbFromDateController = TextEditingController(
                  text:
                      "${availableFrom.toLocal().day}/${availableFrom.toLocal().month}/${availableFrom.toLocal().year}");
              _itemDescController = TextEditingController(text: productDesc);
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No item found!'),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not load item details.Try again later.'),
            action: SnackBarAction(
              label: 'okay',
              onPressed: () {},
            ),
          ),
        );
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future pickImage(source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        isImageChanged = true;
        anyDataChanged = true;
        isImageDeleted = false;
      });
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

  void updateProduct() async {
    String updateData;
    Navigator.of(context).push(PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        }));
    if (isImageChanged) {
      var imageUploadedUrl = await uploadImage(image);
      debugPrint("imageUploadedUrl : $imageUploadedUrl");
      updateData = json.encode({
        "productId": widget.productId,
        "quantityPerLot": _qntPerLotController.text,
        "basePrice": _basePriceController.text,
        "quantityUnit": _qntUnitController.text,
        "productImages": [imageUploadedUrl].toList(),
        "minNoLot": _minLotsController.text,
        "productDesc": _itemDescController.text,
        "producedDate": producedDate.toUtc().toString(),
        "availableFrom": availableFrom.toUtc().toString(),
        "availStatus": true,
      });
    } else {
      updateData = json.encode({
        "productId": widget.productId,
        "quantityPerLot": _qntPerLotController.text,
        "basePrice": _basePriceController.text,
        "quantityUnit": _qntUnitController.text,
        "minNoLot": _minLotsController.text,
        "productDesc": _itemDescController.text,
        "producedDate": producedDate.toUtc().toString(),
        "availableFrom": availableFrom.toUtc().toString(),
        "availStatus": true,
      });
    }

    http
        .post(productUpdateUrl,
            headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'}, body: updateData)
        .then((response) {
      if (response.statusCode == 200) {
        var productUpdateResp = json.decode(response.body);
        if (productUpdateResp["msg"] == "Product Updated Successfully") {
          isImageChanged = false;
          isImageDeleted = false;
          anyDataChanged = false;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Product details successfully updated"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("okay"),
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
                title: const Text("Could not update product details"),
                content: const Text("Try again later"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("okay"),
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
              title: const Text("Something went wrong."),
              content: const Text("Try again later"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text("okay"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void deleteImage() {
    var updateData = json.encode({
      "productId": widget.productId,
      "productImages": [""].toList(),
    });

    http
        .post(productUpdateUrl,
            headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'}, body: updateData)
        .then((response) {
      if (response.statusCode == 200) {
        var productUpdateResp = json.decode(response.body);
        if (productUpdateResp["msg"] == "Product Updated Successfully") {
          isImageDeleted = true;
          setState(() {
            productImages = [""];
          });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Could not delete image"),
                content: const Text("Try again later"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("okay"),
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
              title: const Text("Something went wrong."),
              content: const Text("Try again later"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("okay"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getProductDetailsUrl = Uri.https(
      authority,
      "api/farmer/getProductDetails",
      {
        "productId": widget.productId,
      },
    );

    productUpdateUrl = Uri.https(
      authority,
      'api/farmer/updateproduct',
    );
    _itemNameController = TextEditingController();
    _basePriceController = TextEditingController();
    _qntUnitController = TextEditingController();
    _qntPerLotController = TextEditingController();
    _minLotsController = TextEditingController();
    _prodDateController = TextEditingController();
    _avlbFromDateController = TextEditingController();
    _itemDescController = TextEditingController();

    getProductDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _itemNameController.dispose();
    _basePriceController.dispose();
    _qntUnitController.dispose();
    _qntPerLotController.dispose();
    _minLotsController.dispose();
    _prodDateController.dispose();
    _avlbFromDateController.dispose();
    _itemDescController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Item"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 26),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _itemNameController,
                        readOnly: true,
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
                        onChanged: (value) {
                          anyDataChanged = true;
                        },
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
                        onChanged: (value) {
                          anyDataChanged = true;
                        },
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
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _qntPerLotController,
                        onChanged: (value) {
                          anyDataChanged = true;
                        },
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
                        onChanged: (value) {
                          anyDataChanged = true;
                        },
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
                                producedDate = value;
                                anyDataChanged = true;
                                setState(() {
                                  _prodDateController.text =
                                      "${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}";
                                });
                              }
                            },
                          );
                        },
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
                                availFromDate = value;
                                anyDataChanged = true;
                                availableFrom = value;
                                setState(() {
                                  _avlbFromDateController.text =
                                      "${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}";
                                });
                              }
                            },
                          );
                        },
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
                        onChanged: (value) {
                          anyDataChanged = true;
                        },
                        maxLines: 5,
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
                            return 'Please enter a valid description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Images',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 155,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: productImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Container(
                                      height: 155,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.7,
                                          color: isImageDeleted
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: isImageDeleted &&
                                              productImages[index] == '' &&
                                              !isImageChanged
                                          ? const Center(
                                              child: Text("No image"),
                                            )
                                          : isImageChanged
                                              ? Image.file(
                                                  image!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  productImages[index],
                                                  fit: BoxFit.cover,
                                                ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          color: const Color.fromARGB(
                                              224, 255, 255, 255),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        "Delete image?",
                                                      ),
                                                      content: const Text(
                                                        "This action can't be undone.",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteImage();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Delete image",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: const Icon(Icons.close),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
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
                                        icon: const Icon(
                                            Icons.photo_camera_back_outlined),
                                        label: const Text("Camera"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                            ),
                            label: const Text(
                              "Add Image",
                            ),
                          ),
                        ],
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
                              if (isImageDeleted) {
                                final snackBar = SnackBar(
                                  content: const Text('Please add and image.'),
                                  action: SnackBarAction(
                                    label: 'okay',
                                    onPressed: () {},
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else if (anyDataChanged) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Discard changes?"),
                                      content: const Text(
                                        "Some details have be changed but aren't updated yet. You sure you want to discard them?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            anyDataChanged = false;
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Discard"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                Navigator.of(context).pop();
                              }
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
                              updateProduct();
                            },
                            icon: const Icon(
                              Icons.check,
                            ),
                            label: const Text(
                              "Update",
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
