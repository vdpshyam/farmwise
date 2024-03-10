import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';

class SellerPasswordResetScreen extends StatefulWidget {
  const SellerPasswordResetScreen({super.key});

  @override
  State<SellerPasswordResetScreen> createState() =>
      _SellerPasswordResetScreenState();
}

class _SellerPasswordResetScreenState extends State<SellerPasswordResetScreen> {
  late Uri updatePasswordUrl;
  late String confirmNewPasswordChecker;

  late TextEditingController _sellerCurrentPasswordController;
  late TextEditingController _sellerNewPasswordController;
  late TextEditingController _sellerConfirmNewPasswordController;

  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();

    updatePasswordUrl = Uri.http(
      authority,
      'api/common/updateUserPassword',
    );

    confirmNewPasswordChecker = '';

    _sellerCurrentPasswordController = TextEditingController();
    _sellerNewPasswordController = TextEditingController();
    _sellerConfirmNewPasswordController = TextEditingController();

    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _sellerCurrentPasswordController.dispose();
    _sellerNewPasswordController.dispose();
    _sellerConfirmNewPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reset Password",
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25,
              ),
              child: TextFormField(
                obscureText: true,
                controller: _sellerCurrentPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  labelText: 'Current Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter correct password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25,
              ),
              child: TextFormField(
                obscureText: true,
                controller: _sellerNewPasswordController,
                onChanged: (value) {
                  confirmNewPasswordChecker = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  labelText: 'New Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter correct password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25,
              ),
              child: TextFormField(
                obscureText: true,
                controller: _sellerConfirmNewPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  labelText: 'Confirm New Password',
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      confirmNewPasswordChecker != value) {
                    return 'Please enter correct password';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        var updatedData = {
                          "mobile": loggedInUserDetails.mobile,
                          "currentPassword":
                              _sellerCurrentPasswordController.text,
                          "newPassword": _sellerNewPasswordController.text,
                        };
                        var updatedPasswordSent = json.encode(updatedData);
                        var response = await http.put(
                          updatePasswordUrl,
                          headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
                          body: updatedPasswordSent,
                        );
                        var updatedPasswordresp = json.decode(response.body);
                        if (updatedPasswordresp['Message'] ==
                            'User password updated') {
                          // ignore: use_build_context_synchronously
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Password succesfully updated',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Okay'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (updatedPasswordresp['Message'] ==
                            'User passowrd not updated') {
                          // ignore: use_build_context_synchronously
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Column(
                                  children: [
                                    Text(
                                      'Could not update password.',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Please try again later.',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Okay'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (updatedPasswordresp['Message'] ==
                            'Current password wrong') {
                          // ignore: use_build_context_synchronously
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Current password wrong.',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                content: const Text(
                                  'Please enter current password correctly.',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Okay'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
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
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Color.fromARGB(255, 252, 96, 85),
                    ),
                    label: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 252, 96, 85),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
