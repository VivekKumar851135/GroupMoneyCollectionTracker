import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:money_collection_2/Entity/Comment.dart';
import 'package:money_collection_2/Entity/User.dart';
import 'package:money_collection_2/Utility/Constant.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:money_collection_2/Utility/PhotoVeiwer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ChatScreen extends StatefulWidget {
  final User? loggedInUser;
  final User chatUser;
  final int groupId;
  final bool isCreator;

  const ChatScreen(
      {super.key, required this.chatUser, required this.groupId, required this.isCreator, required this.loggedInUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Comment>> _dataFuture;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  String? _imageUrl;
  final bool _isLoading = false;
  bool _isUploading = false;
  bool _isCommentExpanded = false;
  bool _isAmountExpanded = false;
  String? _selectedImagePath;
  double currentContribution = 0;
  String? token;

  Future<List<Comment>> fetchData(int groupId) async {
    List<Comment> comments = [];
    try {
      token =
          await Provider.of<FetchApiModel>(context, listen: false).getToken();
      final response = await http.get(
        Uri.parse(
            '${Constant.androidIp}/api/groups/$groupId/users/${widget.chatUser.userId}/chat/get-user-comment'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        comments =
            jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (error) {
      debugPrint('Error fetching comments: $error');
    }
    return comments;
  }

  Future<void> verifyComment(
      int groupId,
      int userId,
      int creatorId,
      int commentId,
      double? amount,
      String contibutorFirstName,
      String contributorLastName) async {
    try {
      setState(() {
        _isUploading = true;
      });
      final response = await http.get(
        Uri.parse(
            '${Constant.androidIp}/api/groups/$groupId/users/$userId/chat/$commentId/verify/$creatorId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        commentVerifiedNotification(
            token!,
            widget.groupId.toString(),
            widget.loggedInUser!.userId.toString(),
            widget.loggedInUser!.firstName.toString(),
            widget.loggedInUser!.lastName.toString(),
            amount!,
            contibutorFirstName,
            contributorLastName);

        _dataFuture = fetchData(widget.groupId);

        debugPrint('Comment verified successfully.');
      } else {
        debugPrint('User is not an admin.');
        throw Exception('User is not an admin.');
      }
    } catch (error) {
      debugPrint('Something went wrong: $error');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> deleteComment(
      int groupId, int userId, int? commentId, String? imageUrl) async {
    await deleteImage(imageUrl);

    try {
      setState(() {
        _isUploading = true;
      });

      final response = await http.delete(
        Uri.parse(
            '${Constant.androidIp}/api/groups/$groupId/users/${widget.chatUser.userId}/chat/$commentId/delete'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        showToast('Failed to delete comments.');
        throw Exception('Failed to delete comments');
      } else {
        _dataFuture = fetchData(widget.groupId);
        _calculateCurrentContribution();
        showToast('Comment deleted successfully.');
      }
    } catch (error) {
      showToast('Failed to delete comments.');
      debugPrint('Error deleting comments: $error');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> deleteImage(String? downloadUrl) async {
    if (downloadUrl != null) {
      try {
        // Extract the file path from the URL
        final storageRef = FirebaseStorage.instance.refFromURL(downloadUrl);
        setState(() {
          _isUploading = true;
        });

        // Delete the file
        await storageRef.delete();
        debugPrint("Image deleted successfully");
      } catch (e) {
        showToast('Failed to delete image.');
        debugPrint("Error deleting image: $e");
      } finally {
        _isUploading = false;
      }
    }
  }

  Future<void> addComment(String groupId, String userId, String comment,
      double amount, String? imageUrl) async {
    String jsonString = jsonEncode({
      "commentText": comment,
      "imageUrl": imageUrl,
      "amount": amount,
    });

    debugPrint('Sending data to API: $jsonString');

    try {
      setState(() {
        _isUploading = true;
      });
      final response = await http.post(
        Uri.parse(
            '${Constant.androidIp}/api/groups/$groupId/users/$userId/chat/post-comment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonString,
      );
      if (response.statusCode == 201) {
        debugPrint('Comment added successfully');
      } else {
        throw Exception(
            'Failed to post comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error posting comment: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    int attempts = 0;
    const maxRetries = 3;
    bool uploadSuccess = false;

    FirebaseStorage storage = FirebaseStorage.instanceFor(
      bucket: 'gs://travelexpensemanager-82868.firebasestorage.app',
    );

    String filePath =
        'chat_images/groupId${widget.groupId}/userId${widget.chatUser.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    debugPrint('Constructed file path: $filePath');

    // Attempt to compress the image
    // XFile? result = await FlutterImageCompress.compressAndGetFile(
    //   image.absolute.path,
    //   '${image.path}_compressed.jpg', // Compressed file path
    //   quality: 60, // Set quality here (1-100)
    // );

    // // Use compressed image if available, else proceed with the original image
    // if (result != null) {
    //   image = File(result.path); // Convert XFile to File
    // } else {
    //   debugPrint('Image compression failed. Proceeding with original image.');
    // }

    Reference storageRef = storage.ref().child(filePath);

    // Retry loop for image upload
    while (!uploadSuccess && attempts < maxRetries) {
      try {
        debugPrint('Starting image upload (Attempt ${attempts + 1})...');

        // Upload the file
        final uploadTask = storageRef.putFile(image);
        final snapshot = await uploadTask.whenComplete(() => null);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        debugPrint('Image uploaded successfully! Download URL: $downloadUrl');

        return downloadUrl; // Return URL if upload is successful
      } catch (e) {
        attempts++;
        debugPrint("Error during image upload: $e");

        // Specific handling if the upload was canceled
        if (e is FirebaseException && e.code == 'cancelled') {
          debugPrint(
              "Upload marked as cancelled. Verifying if the image exists...");

          try {
            // Check if the image is already present in storage
            final url = await storageRef.getDownloadURL();
            debugPrint("Image is in storage, URL: $url");
            return url; // Return the existing URL if found
          } catch (checkError) {
            debugPrint(
                "Confirmed: Image is not in storage. Re-attempting upload.");
          }
        }

        if (attempts == maxRetries) {
          debugPrint("Upload failed after $attempts attempts: $e");
          showToast('Upload failed after multiple attempts. Please try again.');
        } else {
          debugPrint("Retrying upload... Attempt $attempts");
          showToast('Upload failed. Retrying...');
        }

        await Future.delayed(Duration(seconds: 2)); // Wait before retrying
      }
    }

    // If upload was not successful after max retries, return empty string
    return '';
  }

  @override
  initState() {
    super.initState();
    _dataFuture = fetchData(widget.groupId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Listen for focus changes on comment and amount fields
    _commentFocusNode.addListener(() {
      setState(() {
        _isCommentExpanded = _commentFocusNode.hasFocus;
      });
    });
    _amountFocusNode.addListener(() {
      setState(() {
        _isAmountExpanded = _amountFocusNode.hasFocus;
      });
    });
    _calculateCurrentContribution();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _amountController.dispose();
    _commentFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // Check if the comment and amount fields are not empty
    String commentText = _commentController.text.trim();
    String amountText = _amountController.text.trim();

    // Regex to validate the comment is not empty
    final commentRegex = RegExp(r'^(?!\s*$).+');

    // Regex to validate the amount is a valid number
    final amountRegex =
        RegExp(r'^\d+(\.\d{1,2})?$'); // Allows up to 2 decimal places

    // Check if the comment and amount fields match the regex
    if (!commentRegex.hasMatch(commentText)) {
      showToast("Comment cannot be empty.");
      return;
    }
    if (!amountRegex.hasMatch(amountText)) {
      showToast("Amount must be a valid number.");
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount != null) {
      // Handle image upload if there is a selected image
      if (_selectedImagePath != null) {
        setState(() {
          _isUploading = true; // Start the upload process
        });
        String imageUrl = await _uploadImage(File(_selectedImagePath!));
        if (imageUrl.isNotEmpty) {
          _imageUrl = imageUrl; // Set the image URL if upload is successful
        } else {
          showToast('Image upload failed, please try again.');
          setState(() {
            _isUploading = false; // Reset upload state
          });
          return; // Exit if the upload failed
        }
      }

      // Call addComment method
      await addComment(
        widget.groupId.toString(),
        widget.chatUser.userId.toString(),
        commentText,
        amount,
        _imageUrl,
      );

      await sendNotification(
          token!,
          widget.groupId.toString(),
          widget.chatUser.userId.toString(),
          widget.chatUser.firstName.toString(),
          widget.chatUser.lastName.toString(),
          amount);

      // Clear the input fields and refresh data
      _commentController.clear();
      _amountController.clear();
      _dataFuture = fetchData(widget.groupId); // Refresh comments
      _calculateCurrentContribution();
      setState(() {
        _imageUrl = null; // Clear image URL after sending
        _selectedImagePath = null; // Clear selected image after sending
        _isUploading = false; // Reset upload state
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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

  Future<void> sendNotification(String token, String groupId, String userId,
      String firstName, String lastName, double amount) async {
    try {
      // Prepare the body of the notification
      final body = jsonEncode({
        "groupId": groupId,
        "userId": userId,
        "senderName": '$firstName $lastName',
        "messageText":
            "Contribute ${amount.toString()}", // You can also use string interpolation here
      });

      // Send the POST request
      final response = await http.post(
        Uri.parse(
            '${Constant.androidIp}/api/messages/send'), // Replace with your API URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Handle the response
      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');
        // You can also handle further processing here, like updating the UI or saving data
      } else {
        // Handle non-200 status codes
        debugPrint(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any errors
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> commentVerifiedNotification(
      String token,
      String groupId,
      String userId,
      String creatorFirstName,
      String creatorLastName,
      double amount,
      String contibutorFirstName,
      String contibutorLastName) async {
    try {
      // Prepare the body of the notification
      final body = jsonEncode({
        "groupId": groupId,
        "userId": userId,
        "senderName": '$creatorFirstName $creatorLastName',
        "messageText":
            "Verifed ${"$contibutorFirstName $contibutorLastName"} ₹${amount.toString()} Contribution", // You can also use string interpolation here
      });

      // Send the POST request
      final response = await http.post(
        Uri.parse(
            '${Constant.androidIp}/api/messages/send'), // Replace with your API URL
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Handle the response
      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');
        // You can also handle further processing here, like updating the UI or saving data
      } else {
        // Handle non-200 status codes
        debugPrint(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any errors
      debugPrint('Error sending notification: $e');
    }
  }

  void _calculateCurrentContribution() async {
    final List<Comment> comments = await _dataFuture;
    double newContribution = 0;

    for (var comment in comments) {
      // Update the overall balance
      newContribution += (double.tryParse(comment.amount.toString()) ?? 0);
    }
    setState(() {
      currentContribution = newContribution;
    });
    }

  @override
  Widget build(BuildContext context) {
    int? loggedUser =
        Provider.of<FetchApiModel>(context, listen: false).user?.userId;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "${widget.chatUser.firstName}" " " "${widget.chatUser.lastName}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹$currentContribution",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Set the needsRefresh flag to true and pop manually
              // TO DO
              // final fetchApiModel =
              //     Provider.of<FetchApiModel>(context, listen: false);
              // fetchApiModel.setNeedsRefresh(true);
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No comments yet'));
                  } else {
                    final messages = snapshot.data!;
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateFormat('EEE, MMM d, y h:mm a').format(message.postedAt!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: message.verifiedBy != null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "This message verified by ${message.verifiedBy?.firstName} ${message.verifiedBy?.lastName} ",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white54),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: true
                                          ? [
                                              Color(0xFF33373B)
                                                  .withOpacity(0.9),
                                              Color(0xFF232529).withOpacity(0.7)
                                            ]
                                          : [
                                              Color(0xFFFFA07A)
                                                  .withOpacity(0.9),
                                              Color(0xFFFFC0CB).withOpacity(0.7)
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: Offset(2, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Main Row for Content
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (message.imageUrl != null &&
                                              message.imageUrl!.isNotEmpty)
                                            Container(
                                              height: 70,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (message.imageUrl
                                                          .toString()
                                                          .isNotEmpty) {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                FullScreenImageViewer(
                                                                    imageUrl: message
                                                                        .imageUrl
                                                                        .toString())));
                                                  }
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
                                                            StackTrace?
                                                                stackTrace) {
                                                      // Display a placeholder image or any other widget in case of error
                                                      return Container(
                                                        width: 100,
                                                        height: 70,
                                                        color: Colors
                                                            .grey, // Placeholder color
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors
                                                                .white), // Placeholder icon
                                                      );
                                                    },
                                                    message.imageUrl!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              height: 70,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey,
                                              ),
                                              child: Icon(Icons.image,
                                                  color: Colors.white),
                                            ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message.commentText
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (message.amount != null)
                                                  Text(
                                                    '₹${message.amount.toString()}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Blue Tick Icon (Top-Right)
                                      if (widget.isCreator == true &&
                                          message.isVerified == false)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.verified,
                                              color: message.isVerified == true
                                                  ? Colors.blue
                                                  : Colors.white,
                                              size: 18,
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Are you sure?'),
                                                  content: Text(
                                                      'Do you want to Verify this message?'),
                                                  actions: [
                                                    // Leave/Cancel Button
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    // Leave or Delete Button
                                                    TextButton(
                                                        onPressed: () async {
                                                          // Close the dialog first
                                                          Navigator.of(context)
                                                              .pop();

                                                          try {
                                                            await verifyComment(
                                                                widget.groupId,
                                                                widget.chatUser
                                                                    .userId,
                                                                message
                                                                    .group!
                                                                    .creator
                                                                    .userId,
                                                                message
                                                                    .commentId!,
                                                                message.amount,
                                                                message.user!
                                                                    .firstName
                                                                    .toString(),
                                                                message.user!
                                                                    .lastName
                                                                    .toString());
                                                            showToast(
                                                                "Message verified");
                                                          } catch (e) {
                                                            showToast(
                                                                "Unable to verified Message");
                                                          }
                                                        },
                                                        child: const Text(
                                                            "Verify")),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      if (message.isVerified == true)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Icon(
                                            Icons.verified,
                                            color: message.isVerified == true
                                                ? Colors.blue
                                                : Colors.white,
                                            size: 18,
                                          ),
                                        ),

                                      // Delete Button (Middle-Right)
                                      if (widget.chatUser.userId == loggedUser)
                                        Positioned(
                                          right: 0,
                                          top: 34,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Are you sure?'),
                                                  content: Text(
                                                      'Do you want to delete this message?'),
                                                  actions: [
                                                    // Leave/Cancel Button
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    // Leave or Delete Button
                                                    TextButton(
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                          if (message
                                                                  .isVerified ==
                                                              false) {
                                                            try {
                                                              await deleteComment(
                                                                  message.group!
                                                                      .groupId,
                                                                  message.user!
                                                                      .userId,
                                                                  message
                                                                      .commentId,
                                                                  message
                                                                      .imageUrl);
                                                            } catch (e) {
                                                              showToast(
                                                                  "Something went wrong.");
                                                            }
                                                          } else {
                                                            showToast(
                                                                "Verified messages cannot be deleted.");
                                                          }
                                                        },
                                                        child: const Text(
                                                            "Delete")),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            if (loggedUser == widget.chatUser.userId)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Stack(
                        children: [
                          IconButton(
                              icon: Icon(Icons.image), onPressed: _pickImage),
                          if (_selectedImagePath != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImagePath = null;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    8), // Adjust the radius as needed
                                child: Image.file(
                                  File(_selectedImagePath!),
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (_isUploading)
                            Container(
                              color: Colors.black.withOpacity(0.7),
                              child: CircularProgressIndicator(
                                value: null,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _commentFocusNode.hasFocus
                          ? MediaQuery.of(context).size.width * 0.48
                          : MediaQuery.of(context).size.width *
                              0.4, // Adjust width
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _amountFocusNode.hasFocus
                          ? MediaQuery.of(context).size.width * 0.23
                          : MediaQuery.of(context).size.width *
                              0.15, // Adjust width
                      child: TextField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
