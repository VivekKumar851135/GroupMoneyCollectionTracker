// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:travel_expense_manager_dev/Utility/Constant.dart';
// import 'package:travel_expense_manager_dev/Utility/FetchApi.dart';
// import 'package:travel_expense_manager_dev/main.dart';

// class UserProfileScreen extends StatefulWidget {
//   @override
//   _UserProfileScreenState createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends State<UserProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for user fields
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   bool _isPasswordVisible = false;
//   final String passwordPattern =
//       r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

//   @override
//   void initState() {
//     super.initState();

//     // Populate text controllers after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final fetchApiModel = Provider.of<FetchApiModel>(context, listen: false);

//       if (fetchApiModel.user != null) {
//         _nameController.text =
//             '${fetchApiModel.user!.firstName} ${fetchApiModel.user!.lastName}';
//         _emailController.text = fetchApiModel.user!.email.toString();
//         _phoneController.text = fetchApiModel.user!.phone.toString();
//         _dobController.text = DateFormat('dd-MM-yyyy')
//             .format(DateTime.parse(fetchApiModel.user!.dateOfBirth.toString()));
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _dobController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final fetchApiModel = Provider.of<FetchApiModel>(context, listen: false);
// // Check if the user is null
//     if (fetchApiModel.user == null) {
//       return Center(child: Text('No user logged in.'));
//     }
//     // Get screen size for responsiveness
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     // Calculate padding and font sizes based on screen size
//     double horizontalPadding = screenWidth * 0.05;
//     double verticalPadding = screenHeight * 0.02;
//     double fontSize = screenWidth < 400 ? 14 : 16;

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: true
//                 ? [
//                     Color(0xFF142A24),
//                     Color(0xFF1E262D),
//                     Color(0xFF614B3A),
//                     Color(0xFF142A24)
//                   ]
//                 : [Color(0xFFFFC0CB), Color(0xFFFFA07A)],
//           ),
//         ),
//         child: SafeArea(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: true
//                     ? [
//                         Color(0xFF2E3236).withOpacity(0.5),
//                         Color(0xFF1D1F23).withOpacity(0.3),
//                       ]
//                     : [
//                         Color(0xFFFFA07A).withOpacity(0.9),
//                         Color(0xFFFFC0CB).withOpacity(0.7),
//                       ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.4),
//                   spreadRadius: 2,
//                   blurRadius: 8,
//                   offset: const Offset(2, 4),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                   horizontal: horizontalPadding, vertical: verticalPadding),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Profile Picture
//                       CircleAvatar(
//                         radius: screenWidth * 0.15,
//                         backgroundColor: Colors.grey[
//                             200], // Optional background color for the avatar
//                         child: ClipOval(
//                           child: Image.network(
//                             '${Constant.userProfile}',
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Icon(
//                                 Icons.person, // Default fallback icon
//                                 size: screenWidth *
//                                     0.15, // Adjust size to fit the CircleAvatar
//                                 color: Colors.grey, // Icon color
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: verticalPadding),
//                       // Name Field
//                       _buildTextField(
//                         controller: _nameController,
//                         label: 'Full Name',
//                         keyboardType: TextInputType.name,
//                         fontSize: fontSize,
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Full name cannot be empty';
//                           } else if (!value.contains(' ')) {
//                             return 'Please enter both first and last name';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: verticalPadding / 2),
//                       // Email Field
//                       _buildTextField(
//                         controller: _emailController,
//                         label: 'Email',
//                         keyboardType: TextInputType.emailAddress,
//                         fontSize: fontSize,
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Email cannot be empty';
//                           }
//                           String emailPattern =
//                               r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
//                           if (!RegExp(emailPattern).hasMatch(value)) {
//                             return 'Please enter a valid email address';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: verticalPadding / 2),
//                       // Password Field
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText:
//                             !_isPasswordVisible, // Hide text when _isPasswordVisible is false
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           labelStyle: TextStyle(color: Colors.purpleAccent),
//                           border: OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _isPasswordVisible
//                                   ? Icons.visibility
//                                   : Icons.visibility_off,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _isPasswordVisible =
//                                     !_isPasswordVisible; // Toggle visibility
//                               });
//                             },
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Password cannot be empty';
//                           }
//                           if (!RegExp(passwordPattern).hasMatch(value)) {
//                             return 'Password must be at least 8 characters, include an uppercase letter, a lowercase letter, a number, and a special character.';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: verticalPadding / 2),
//                       // Phone Field
//                       _buildTextField(
//                         controller: _phoneController,
//                         label: 'Phone',
//                         keyboardType: TextInputType.phone,
//                         fontSize: fontSize,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Phone number is required';
//                           } else if (!value.startsWith('+91')) {
//                             return 'Phone number must start with +91';
//                           } else if (value.length != 13) {
//                             return 'Enter a valid phone number';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: verticalPadding / 2),
//                       // Date of Birth Field
//                       _buildTextField(
//                         controller: _dobController,
//                         label: 'Date of Birth',
//                         keyboardType: TextInputType.datetime,
//                         fontSize: fontSize,
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.calendar_today),
//                           onPressed: () async {
//                             DateTime? pickedDate = await showDatePicker(
//                               context: context,
//                               initialDate: DateTime.now(),
//                               firstDate: DateTime(1900),
//                               lastDate: DateTime.now(),
//                             );
//                             if (pickedDate != null) {
//                               setState(() {
//                                 _dobController.text =
//                                     DateFormat('dd-MM-yyyy').format(pickedDate);
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                       SizedBox(height: verticalPadding),
//                       // Save Button
//                       ElevatedButton(
                        // onPressed: () async {
                        //   if (_formKey.currentState!.validate()) {
                        //     List<String> userName =
                        //         _nameController.text.split(" ");
                        //     String firstName =
                        //         userName.isNotEmpty ? userName[0] : '';
                        //     String lastName =
                        //         userName.length > 1 ? userName[1] : '';
                        //     String email = _emailController.text;
                        //     String phoneNumber = _phoneController.text;
                        //     String dateOfBirth = _dobController.text;
                        //     String password = _passwordController.text;

                        //     if (!fetchApiModel.isLoading) {
                        //       try {
                        //         fetchApiModel.getLoading;

                        //         DateTime? parsedDate;
                        //         try {
                        //           parsedDate = DateFormat('dd-MM-yyyy')
                        //               .parseStrict(dateOfBirth);
                        //         } catch (e) {
                        //           ScaffoldMessenger.of(context).showSnackBar(
                        //             SnackBar(
                        //                 content: Text(
                        //                     'Invalid Date of Birth format')),
                        //           );
                        //           return;
                        //         }

                        //         await fetchApiModel.updateUser(
                        //           email: email,
                        //           password: password,
                        //           firstName: firstName,
                        //           lastName: lastName,
                        //           phone: phoneNumber,
                        //           selectedDateOfBirth: parsedDate,
                        //         );

                        //         ScaffoldMessenger.of(context).showSnackBar(
                        //           SnackBar(
                        //               content: Text(
                        //                   'Profile updated successfully!')),
                        //         );
                        //       } catch (e) {
                        //         ScaffoldMessenger.of(context).showSnackBar(
                        //           SnackBar(
                        //               content:
                        //                   Text('Failed to update profile.')),
                        //         );
                        //       } finally {
                        //         fetchApiModel.getLoading;
                        //       }
                        //     }
                        //   }
                        // },
//                         child: fetchApiModel.isLoading
//                             ? CircularProgressIndicator(color: Colors.white)
//                             : Text('Save Changes'),
//                       ),

//                       ElevatedButton(
//                         onPressed: () {
//                           fetchApiModel.logout();

//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             context.go('/login');
//                           });
//                         },
//                         child: Text('Logout'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required TextInputType keyboardType,
//     required double fontSize,
//     Widget? suffixIcon,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: TextStyle(fontSize: fontSize, color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.purpleAccent),
//         border: OutlineInputBorder(),
//         suffixIcon: suffixIcon,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';


class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _hasNameValidationError = false;
  bool _hasEmailValidationError = false;
  bool _hasPasswordValidationError = false;
  bool _hasPhoneValidationError = false;
  bool _hasDobValidationError = false;

  @override
  void initState() {
    super.initState();

    // Populate fields if user data exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fetchApiModel = Provider.of<FetchApiModel>(context, listen: false);
      if (fetchApiModel.user != null) {
        _nameController.text =
            '${fetchApiModel.user!.firstName} ${fetchApiModel.user!.lastName}';
        _emailController.text = fetchApiModel.user!.email!;
        _phoneController.text = fetchApiModel.user!.phone!;
        _dobController.text = DateFormat('dd-MM-yyyy')
            .format(DateTime.parse(fetchApiModel.user!.dateOfBirth.toString()));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool obscureText = false,
    required String errorMsg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black87.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              prefixIcon: Icon(prefixIcon, color: Colors.grey),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
        ),
        const SizedBox(height: 8), // Add spacing between fields
         if (_hasPasswordValidationError) // Display error dynamically
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 15),
                                child: Text(
                                  errorMsg,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
      ],
    );
    
  }

  @override
  Widget build(BuildContext context) {
    final fetchApiModel = Provider.of<FetchApiModel>(context);
       final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
    if (fetchApiModel.user == null) {
      return Center(child: Text('No user logged in.'));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: true
                  ? [
                      Color(0xFF142A24),
                      Color(0xFF1E262D),
                      Color(0xFF614B3A),
                      Color(0xFF142A24)
                    ]
                  : [Color(0xFFFFC0CB), Color(0xFFFFA07A)],
            ),
          ),
        child: Container(
           decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: true
                      ? [
                          Color(0xFF2E3236).withOpacity(0.5),
                          Color(0xFF1D1F23).withOpacity(0.3)
                        ]
                      : [
                          Color(0xFFFFA07A).withOpacity(0.9),
                          Color(0xFFFFC0CB).withOpacity(0.7)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Full Name
                    _buildCustomTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      prefixIcon: Icons.person,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _hasNameValidationError=true;
                          });
                          return null;
                        }
                        if (!value.contains(' ')) {
                           setState(() {
                            _hasNameValidationError=true;
                          });
                          return null;
                        }
                        setState(() {
                            _hasNameValidationError=false;
                          });
                        return null;
                      },
                      errorMsg: "Full name must have first name and last name with space in between"
                    ),
                      SizedBox(height: 16),
                    // Email
                    _buildCustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _hasEmailValidationError=true;
                          });
                          return null;
                        }
                        final emailPattern =
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
                        if (!RegExp(emailPattern).hasMatch(value)) {
                           setState(() {
                            _hasEmailValidationError=true;
                          });
                          return null;
                        }
                         setState(() {
                            _hasEmailValidationError=false;
                          });
                        return null;
                      },
                       errorMsg: "Please entre a vaild email address"
                    ),
                     SizedBox(height: 16),
                    // Password
                    _buildCustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _hasPasswordValidationError=true;
                          });
                          return null;
                        }
                         setState(() {
                            _hasPasswordValidationError=false;
                          });
                        return null;
                      },
                       errorMsg: "Password must be 6- digit long"
                    ),
                     SizedBox(height: 16),
                    // Phone
                    _buildCustomTextField(
                      controller: _phoneController,
                      hintText: 'Phone',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                           setState(() {
                           _hasPhoneValidationError=true;
                          });
                          return null;
                        }
                        if (!value.startsWith('+91')) {
                           setState(() {
                             _hasPhoneValidationError=true;
                          });
                          return null;
                        }
                        if (value.length != 13) {
                           setState(() {
                            _hasPhoneValidationError=true;
                          });
                          return null;
                        }
                        setState(() {
                            _hasPhoneValidationError=false;
                          });
                        return null;
                      },
                       errorMsg: "Phone number must have +91 and 10 digit"
                    ),
                     SizedBox(height: 16),
                    // Date of Birth
                    _buildCustomTextField(
                      controller: _dobController,
                      hintText: 'Date of Birth',
                      prefixIcon: Icons.calendar_today,
                      keyboardType: TextInputType.datetime,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dobController.text =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                            });
                          }
                        },
                      ),
                      
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                           _hasDobValidationError=true;
                          });
                          return null;
                        }
                          setState(() {
                           _hasDobValidationError=false;
                          });
                        return null;
                      },
                       errorMsg: "DOB must be in this format dd-MM-yyyy"
                    ),
                    SizedBox(height: 16),


                    ElevatedButton(
                         onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            List<String> userName =
                                _nameController.text.split(" ");
                            String firstName =
                                userName.isNotEmpty ? userName[0] : '';
                            String lastName =
                                userName.length > 1 ? userName[1] : '';
                            String email = _emailController.text;
                            String phoneNumber = _phoneController.text;
                            String dateOfBirth = _dobController.text;
                            String password = _passwordController.text;

                            if (!fetchApiModel.isLoading) {
                              try {
                                fetchApiModel.getLoading;

                                DateTime? parsedDate;
                                try {
                                  parsedDate = DateFormat('dd-MM-yyyy')
                                      .parseStrict(dateOfBirth);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Invalid Date of Birth format')),
                                  );
                                  return;
                                }

                                await fetchApiModel.updateUser(
                                  email: email,
                                  password: password,
                                  firstName: firstName,
                                  lastName: lastName,
                                  phone: phoneNumber,
                                  selectedDateOfBirth: parsedDate,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Profile updated successfully!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to update profile.')),
                                );
                              } finally {
                                fetchApiModel.getLoading;
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                          ),
                          padding: EdgeInsets
                              .zero, // Ensures the gradient covers the entire button
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade900, // Dark navy blue
                                Colors.blue.shade700, // Lighter navy blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: screenHeight * 0.08,
                            width: screenWidth * 0.7,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                            child: fetchApiModel.isLoading
                                ? CircularProgressIndicator(color: Colors.white, )
                                : Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    // Logout Button
                    ElevatedButton(
                      onPressed: () {
                        fetchApiModel.logout();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go('/login');
                        }); 
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
