import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _hasValidationError = false;
  bool _hasPasswordValidationError = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showToast(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);

    // Extract query parameters safely
    final String? adminId = state.uri.queryParameters['adminId'];
    final String? groupId = state.uri.queryParameters['groupId'];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fetchApiModel = Provider.of<FetchApiModel>(context, listen: false);

    return Consumer<FetchApiModel>(builder: (context, fetchApiModel, child) {
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      Text(
                        "Hello Again!",
                        style: TextStyle(
                            fontSize: screenWidth * 0.1,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Wellcome back you've",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        "been missed!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      // Email TextField
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: screenHeight * 0.08,
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
                                
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                   color: Colors.blueAccent, fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15),
                                  prefixIcon: Icon(Icons.person_2_outlined,
                                      color: Colors.grey),
                                  hintText: "Email Id",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(() {
                                      _hasValidationError = true;
                                    });
                                    return null;
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    setState(() {
                                      _hasValidationError = true;
                                    });
                                    return null;
                                  }
                                  setState(() {
                                    _hasValidationError = false;
                                  });
                                  return null;
                                },
                              ),
                            ),
                            if (_hasValidationError) // Show error only when there’s a validation error
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 15),
                                child: Text(
                                  "Please enter a valid email",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: screenHeight *
                                  0.08, // Adjust height dynamically
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
                                controller: passwordController,
                                style: TextStyle(
                                color: Colors.blueAccent, fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15),
                                  prefixIcon: Icon(Icons.password_sharp,
                                      color: Colors.grey),
                                  hintText: "Password",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(() {
                                      _hasPasswordValidationError = true;
                                    });
                                    return null;
                                  }
                                  if (value.length < 5) {
                                    setState(() {
                                      _hasPasswordValidationError = true;
                                    });
                                    return null;
                                  }
                                  setState(() {
                                    _hasPasswordValidationError = false;
                                  });
                                  return null;
                                },
                               ),
                            ),
                            if (_hasPasswordValidationError) // Display error dynamically
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 15),
                                child: Text(
                                  "Password must be at least 6 characters long",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () {
                                context.go('/register');
                              },
                              child: Text(
                                "Register Now",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.blueAccent),
                              )),
                          TextButton(
                              onPressed: () {},
                              child: Text(
                                "Recovery Password",
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String email = emailController.text;
                            String password = passwordController.text;
                            if (!fetchApiModel.isLoading) {
                              try {
                                // Perform login
                                await Provider.of<FetchApiModel>(context,
                                        listen: false)
                                    .login(email, password);

                                // Ensure the widget is still mounted before using `context`
                                if (!mounted) return;

                                // Navigate based on redirect after login
                                if (state.uri.path.startsWith('/login') &&
                                    (adminId != null || groupId != null)) {
                                  context.go(
                                      '/join?groupId=$groupId&adminId=$adminId');
                                } else if (state.uri.path
                                        .startsWith('/login') &&
                                    adminId == null &&
                                    groupId == null) {
                                  context.go('/');
                                } else {
                                  String? errorMsg = "Login Screen Error";
                                  context.go('/error?errorMsg=$errorMsg');
                                }

                                // Show success message
                                showToast('Login successful!');
                              } catch (e) {
                                // Handle login error
                                showToast('Login failed');
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
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Scaffold(

      //   body: SingleChildScrollView(
      //     padding: EdgeInsets.symmetric(
      //       horizontal: screenWidth * 0.1,
      //       vertical: screenHeight * 0.05,
      //     ),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         Text(
      //           'Welcome Back!',
      //           style: TextStyle(
      //             fontSize: screenWidth * 0.07,
      //             fontWeight: FontWeight.bold,
      //           ),
      //           textAlign: TextAlign.center,
      //         ),
      //         SizedBox(height: screenHeight * 0.05),
      //
      //         TextField(
      //           controller: emailController,
      //           decoration: InputDecoration(
      //             labelText: 'Email',
      //             border: OutlineInputBorder(),
      //             contentPadding: EdgeInsets.symmetric(
      //               horizontal: screenWidth * 0.04,
      //               vertical: screenHeight * 0.02,
      //             ),
      //           ),
      //           keyboardType: TextInputType.emailAddress,
      //         ),
      //         SizedBox(height: screenHeight * 0.02),
      //         TextField(
      //           controller: passwordController,
      //           decoration: InputDecoration(
      //             labelText: 'Password',
      //             border: OutlineInputBorder(),
      //             contentPadding: EdgeInsets.symmetric(
      //               horizontal: screenWidth * 0.04,
      //               vertical: screenHeight * 0.02,
      //             ),
      //           ),
      //           obscureText: true,
      //         ),
      //         SizedBox(height: screenHeight * 0.03),
      //         SizedBox(
      //           width: double.infinity,
      //           child: ElevatedButton(
      // onPressed: () async {
      //   String email = emailController.text;
      //   String password = passwordController.text;
      //   if (!fetchApiModel.isLoading) {
      //     try {
      //       // Perform login
      //       await Provider.of<FetchApiModel>(context, listen: false)
      //           .login(email, password);

      //       // Ensure the widget is still mounted before using `context`
      //       if (!mounted) return;

      //       // Navigate based on redirect after login
      //       if (state.uri.path.startsWith('/login') &&
      //           (adminId != null || groupId != null)) {
      //         context.go('/join?groupId=$groupId&adminId=$adminId');
      //       } else if (state.uri.path.startsWith('/login') &&
      //           adminId == null &&
      //           groupId == null) {
      //         context.go('/');
      //       } else {
      //         String? errorMsg = "Login Screen Error";
      //         context.go('/error?errorMsg=$errorMsg');
      //       }

      //       // Show success message
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text('Login successful!')),
      //       );
      //     } catch (e) {
      //       // Handle login error
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text('Login failed: $e')),
      //       );
      //     }
      //   }
      // },
      //             child: fetchApiModel.getLoading
      //                 ? CircularProgressIndicator(color: Colors.white)
      //                 : Text('Login'),
      //           ),
      //         ),
      //         SizedBox(height: screenHeight * 0.02),
      //         TextButton(
      //           onPressed: () {
      //             context.push('/register');
      //           },
      //           child: const Text('Register Now'),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
    });
  }
}
