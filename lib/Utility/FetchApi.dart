import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:money_collection_2/Entity/Comment.dart';
import 'package:money_collection_2/Entity/CreateGroup.dart';
import 'package:money_collection_2/Entity/Group.dart';
import 'package:money_collection_2/Entity/Loginrequest.dart';
import 'package:money_collection_2/Entity/User.dart';
import 'package:money_collection_2/Utility/Constant.dart';

class FetchApiModel extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;
  bool isInitialized = false;

  User? _user;
  bool _isAuthenticated = false;
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool? _isNavigaetd = true;
  bool? get isNavigated => _isNavigaetd;
  void setIsNavigated(bool value) {
    _isNavigaetd = value;
  }

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  List<Group>? _data;
  List<Comment>? comment;
  bool isLoading = false;
  
  String _errorMessage = '';

  List<Group>? get data => _data; // Getter for fetched data
  String get errorMessage => _errorMessage; // Error message

  // Loading state
  bool get getLoading => isLoading;

  bool _needsRefresh = false;

  bool get needsRefresh => _needsRefresh;

  

  void setNeedsRefresh(bool value) {
    _needsRefresh = value;
    notifyListeners();
  }

  final storage = FlutterSecureStorage();

  // Function to save the JWT token securely
  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(
        key: 'jwt_token'); // Replace with your storage logic
  }

  Future<void> saveUserDeatils(User user) async {
    await storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  void logout() async {
    try {
      isLoading = true;
      notifyListeners();

      // Deleting the token and user details from storage
      await storage.delete(key: 'jwt_token');
      await storage.delete(key: 'user');

      // Check if data is deleted
      String? token = await storage.read(key: 'jwt_token');
      String? user = await storage.read(key: 'user');
      debugPrint('Token after logout: $token');
      debugPrint('User after logout: $user');

      // Update user and authentication status
    //  _user = null;
      _isAuthenticated = false;
      isInitialized = false;

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> getUser() async {
    String? userJson =
        await storage.read(key: 'user'); // Await to get the actual string
    if (userJson != null) {
      // Decode the JSON string into a Map
      Map<String, dynamic> userMap = json.decode(userJson);
      // Create and return a User object from the decoded map
      return User.fromJson(userMap);
    }
    return null; // Return null if no user data is found
  }

  /*************** Group Details fetching starts here ***********/

  Future<void> fetchGroupDataByUserId(int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      final response = await http.get(
        Uri.parse('${Constant.androidIp}/api/auth/groups/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ); // Replace with your API endpoint

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        _data = jsonResponse.map((group) => Group.fromJson(group)).toList();

        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load data';
      }
    } catch (error) {
      debugPrint('$error');
      _errorMessage = 'Error: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*************** Group Details fetching ends here ***********/

  /*************** Comments fetching starts here ***********/

  Future<void> fetchCommentByGroupId(int groupId) async {
    isLoading = true;
    notifyListeners();

    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      final response = await http.get(
        Uri.parse(
            '${Constant.androidIp}/api/groups/${groupId}/users/10/chat/get-group-comment'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ); // Replace with your API endpoint

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        comment =
            jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load data';
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
      comment = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*************** Comments fetching ends here ***********/

  /*************** Login user start here ***********/

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    Loginrequest user = Loginrequest(
        email: email, password: password); // example user, modify as needed

    // Convert user object to JSON
    String jsonString = jsonEncode(user?.toJson());

    try {
      // API call for authentication
      final response = await http.post(
        Uri.parse(
            '${Constant.androidIp}/api/auth/login'), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonString,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String token = responseData['jwtToken'];
        if (token == null) {
          throw Exception('Token is missing in the response');
        }
        // Convert the 'user' data to a User object
        User user = User.fromJson(
            responseData['user']); // Ensure that this is a valid map

        // Save the user and token
        await saveUserDeatils(user);
        _user = user;
        if (_user == null) {
          throw Exception('user is missing in the response');
        }

        // Save the token securely
        await saveToken(token);

        await fetchGroupDataByUserId(_user!.userId);
        _isAuthenticated = true;
        isInitialized = true;
        notifyListeners();
      } else {
        throw Exception('Failed to authenticate');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to authenticate: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  /*************** Login user End here ***********/

  /*************** Register user Start here ***********/

  Future<void> registerUser(
      {required String email,
      required String password,
      required String firstName,
      required String lastName,
      required String phone,
      required DateTime selectedDateOfBirth,
      required String selectedGender,
      required String profileUrl}) async {
    isLoading = true;
    notifyListeners();
    final url = '${Constant.androidIp}/api/auth/register';

    final body = jsonEncode({
      "email": email,
      "password": password,
      "username": "vivek",
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "authProvider": "email",
      "dateOfBirth": selectedDateOfBirth?.toIso8601String(),
      "gender": selectedGender,
      "profileUrl": profileUrl,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String token = responseData['jwtToken'];
        if (token == null) {
          throw Exception('Token is missing in the response');
        }
        // Save the token securely
        await saveToken(token);
        // Convert the 'user' data to a User object
        User user = User.fromJson(
            responseData['user']); // Ensure that this is a valid map

        // Save the user and token
        await saveUserDeatils(user);
        _user = user;
        if (_user == null) {
          throw Exception('user is missing in the response');
        }

        await fetchGroupDataByUserId(_user!.userId);
        _isAuthenticated = true;
        isInitialized = true;

        notifyListeners();

        debugPrint('User registered successfully!');
      } else {
        debugPrint(
            'Failed to register user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*************** Register user End here ***********/

  /*************** Update user profile Start here ***********/

  Future<void> updateUser(
      {required String email,
      required String password,
      required String firstName,
      required String lastName,
      required String phone,
      required DateTime selectedDateOfBirth}) async {
    isLoading = true;
    notifyListeners();
    final url = '${Constant.androidIp}/api/auth/update-profile';

    final body = jsonEncode({
      "userId":user!.userId,
      "email": email,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "dateOfBirth": selectedDateOfBirth?.toIso8601String(),
    });

    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {
           'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String token = responseData['jwtToken'];
        if (token == null) {
          throw Exception('Token is missing in the response');
        }
        // Save the token securely
        await saveToken(token);
        // Convert the 'user' data to a User object
        User user = User.fromJson(
            responseData['user']); // Ensure that this is a valid map

        // Save the user and token
        await saveUserDeatils(user);
        _user = user;
        if (_user == null) {
          throw Exception('user is missing in the response');
        }

        await fetchGroupDataByUserId(_user!.userId);
        _isAuthenticated = true;
        isInitialized = true;

        notifyListeners();

        debugPrint('User Profile Updated successfully!');
      } else {
        debugPrint(
            'Failed to update user profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during updating profile: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*************** Update user profile End here ***********/

/*************** Verify Jwt Token Start here ***********/

  Future<void> verifyJwtToken() async {
    try {
      // Retrieve the token properly
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      // Perform the HTTP request
      final response = await http.get(
        Uri.parse('${Constant.androidIp}/api/auth/verifyToken'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Handle the response
      if (response.statusCode == 200) {
        User? userDeatils = await getUser();
        if (userDeatils != null) {
          await fetchGroupDataByUserId(userDeatils.userId);
          debugPrint("User Id: ${userDeatils.userId}");
          _user = userDeatils;
          isInitialized = true;
          _isAuthenticated = true;
          notifyListeners();
        } else {
          _isAuthenticated = false;
          notifyListeners();
        }
      } else {
        _isAuthenticated = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error verifying token: $e");
      _isAuthenticated = false;
      notifyListeners();
    } finally {
      isLoading = false; // Reset loading state

      notifyListeners(); // Notify listeners to update UI
    }
  }
/*************** Verify Jwt Token End here ***********/

/*************** Join Group Start here ***********/

  Future<void> joinGroup(
      String groupId, String userId, String adminUserId) async {
    isLoading = true; // Set loading state to true
    notifyListeners(); // Notify listeners that loading has started
    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      final response = await http.get(
        Uri.parse(
            '${Constant.androidIp}/api/groups/$groupId/add-user/?userId=$userId&adminId=$adminUserId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchGroupDataByUserId(_user!.userId);
      } else {
        _errorMessage = 'Failed to load data';
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
    } finally {
      isLoading = false; // Set loading state to false
      notifyListeners(); // Notify listeners that loading has ended
    }
  }

  /*************** Join Group End here ***********/

  /*************** Create Group Start here ***********/

  Future<void> createGroup(String groupName, String groupDescription) async {
    isLoading = true;
    notifyListeners();
    Creategroup newGroup = Creategroup(
        groupName: groupName,
        groupDescription: groupDescription,
        groupProfilePic:
            Constant.groupProfile); // example user, modify as needed

    // Convert user object to JSON
    String jsonString = jsonEncode(newGroup.toJson());

    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }
      // API call for authentication
      final response = await http.post(
        Uri.parse(
            '${Constant.androidIp}/api/groups/create?creatorId=${user!.userId}'), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonString,
      );

      if (response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        await fetchGroupDataByUserId(_user!.userId);
      } else {
        throw Exception('Create group  Error in if');
      }
    } catch (e) {
      throw Exception('Create group  Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  /*************** Create Group End here ***********/

  /*************** Leave Group Start here ***********/

  Future<void> leaveGroup(int groupId, int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      final response = await http.delete(
        Uri.parse(
            '${Constant.androidIp}/api/groups/leave_group/${groupId}/${userId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ); // Replace with your API endpoint

      if (response.statusCode == 200) {
        await fetchGroupDataByUserId(_user!.userId);
        _needsRefresh = true;
        _errorMessage = '';
      } else {
        _errorMessage = 'Something went wrong...';
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
      debugPrint(_errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*************** Leave Group End here ***********/

  /*************** Delete Group Start here ***********/

  Future<void> deleteGroup(int groupId, int creatorId) async {
    isLoading = true;
    notifyListeners();

    try {
      String? token =
          await getToken(); // Assuming getToken is a method that retrieves the token
      debugPrint("Token: $token");
      if (token == null) {
        _isAuthenticated = false;
        isLoading = false;
        notifyListeners();
        throw Exception('Someting went wrong');
      }

      final response = await http.delete(
        Uri.parse(
            '${Constant.androidIp}/api/groups/delete-group/${groupId}/${creatorId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ); // Replace with your API endpoint

      if (response.statusCode == 200) {
        await fetchGroupDataByUserId(_user!.userId);
        _needsRefresh = true;
        debugPrint("Group deleted");
        _errorMessage = '';
      } else {
        _errorMessage = 'Something went wrong...';
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
      debugPrint(_errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*************** Delete Group End here ***********/
}
