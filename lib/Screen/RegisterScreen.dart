import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:http/http.dart' as http; // for API requests
import 'package:money_collection_2/Utility/Constant.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';
import 'dart:convert';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController for each field
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController authProviderController = TextEditingController();
  TextEditingController profileUrlController = TextEditingController();

  String? selectedGender;
  DateTime? selectedDateOfBirth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Please enter email" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "Please enter password" : null,
              ),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter first name" : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: authProviderController,
                decoration: InputDecoration(labelText: "Auth Provider"),
              ),
              TextFormField(
                controller: profileUrlController,
                decoration: InputDecoration(labelText: "Profile URL"),
              ),
              ListTile(
                title: Text(
                    "Date of Birth: ${selectedDateOfBirth == null ? "Select" : DateFormat.yMd().format(selectedDateOfBirth!)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDateOfBirth = pickedDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(labelText: "Gender"),
                items: ["Male", "Female", "Other"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select gender" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  debugPrint("Registering user");
                  String email = emailController.text;
                  String password = passwordController.text;
                  String firstName = firstNameController.text;
                  String lastName = lastNameController.text;
                  String phone = phoneController.text;
                  String authProvider = authProviderController.text;
                  String profileUrl =
                      "${Constant.userProfile}";
                  DateTime dateOfBirth = selectedDateOfBirth!;
                  String gender = selectedGender!;
                  try {
                    if (_formKey.currentState!.validate()) {
                      await Provider.of<FetchApiModel>(context, listen: false)
                          .registerUser(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone, selectedDateOfBirth: dateOfBirth, profileUrl: profileUrl, selectedGender: gender );
                    }
                     context.go('/');
                  } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registeration failed: $e')));
                  }
                },
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
