import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_collection_2/Entity/Comment.dart';
import 'package:money_collection_2/Entity/Group.dart';
import 'package:money_collection_2/Entity/User.dart';
import 'package:money_collection_2/Screen/BarChartCard.dart';
import 'package:money_collection_2/Screen/ChatScreen.dart' show ChatScreen;
import 'package:money_collection_2/Screen/PiChart.dart';
import 'package:money_collection_2/Utility/Constant.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:money_collection_2/Utility/NotificationService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class GroupDetailsWindow extends StatefulWidget {
  final int groupId;
  final int? initialChatUserId;
  const GroupDetailsWindow({
    super.key,
    required this.groupId,
    this.initialChatUserId,
  });

  @override
  State<GroupDetailsWindow> createState() => _GroupDetailsWindowState();
}

class _GroupDetailsWindowState extends State<GroupDetailsWindow> {
//Variable to store the current balance and monthly data to plot the bar chart
  double currentBalance = 0;
  int selectedYear = DateTime.now().year;
  late Map<String, Map<String, double>> monthlyDataWithYear = {};
  late Future<List<Comment>> _dataFuture = Future.value([]);
  late Map<String, Map<String, double>> temp = {};
  late Map<String, double> monthlyDataPerUser = {};

  //Variable to implement search functionality
  List<User> allUsers = [];
  List<User> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  Group? groupData;
  bool isDarkMode = true;
  bool isCreator = false;
  User? user;

  // Fetch comment by group id data from API
  Future<List<Comment>> fetchData(int groupId) async {
    List<Comment> comments = [];
    String _errorMessage = '';
    final fetchApiModel = Provider.of<FetchApiModel>(context, listen: false);
    try {
      String? token = await fetchApiModel.getToken();
      final response = await http.get(
        Uri.parse(
            '${Constant.androidIp}/api/groups/${groupId}/users/${fetchApiModel.user!.userId}/chat/get-group-comment'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        comments =
            jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load data';
      }
    } catch (error) {
      _errorMessage = 'Error: $error';
      comments = [];
    }
    setState(() {
      user = fetchApiModel.user;
    });

    if (fetchApiModel.data != null) {
      final data = fetchApiModel.data;
      for (Group group in data!) {
        if (group.creator.userId == user!.userId) {
          setState(() {
            isCreator = true;
          });
        }
      }
    }

    return comments;
  }

  @override
  void initState() {
    super.initState();

    // Delay Provider access until the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _dataFuture = fetchData(widget.groupId);
      });
      _calculateCurrentBalance();
    });

    searchController.addListener(_filterUsers);
  }

  @override
  void didUpdateWidget(GroupDetailsWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      // If the groupId has changed, fetch new data
      _dataFuture = fetchData(widget.groupId);
      _calculateCurrentBalance();
    }
  }

// If your data det change it will rebuild the widget
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final fetchModelApi = Provider.of<FetchApiModel>(context, listen: false);

    if (fetchModelApi.needsRefresh) {
    
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          fetchModelApi.setNeedsRefresh(false);
          _refreshData();
        }
      });
    }
    if (groupData == null) {
      groupData = fetchModelApi.data!
          .firstWhere((group) => group.groupId == widget.groupId);
      if (groupData != null) {
        allUsers = groupData!.members;
        filteredUsers = allUsers; // Start with all users
        isDarkMode = fetchModelApi.isDarkMode;
      }
    }
    final chatUser = allUsers.firstWhere(
      (user) => user.userId == widget.initialChatUserId,
      orElse: () => User(
          userId: -1,
          firstName: 'Unknown',
          lastName: '',
          username: '',
          email: '',
          password: '',
          phone: '',
          authProvider: '',
          dateOfBirth: null,
          gender: '',
          createdAt: DateTime.now(),
          profileUrl: ''), // Default User
    );

    if (chatUser.userId != -1 && fetchModelApi.isNavigated == false) {
      fetchModelApi.setIsNavigated(true);
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatUser: chatUser,
              groupId: widget.groupId,
              isCreator: isCreator, loggedInUser: user,
            ),
          ),
        );
      });
    } else {
      // Handle case where the user is not found, e.g., show an error message.
      print("No Notification");
    }
  }

// Function that help search funcationality
  void _filterUsers() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredUsers = allUsers
          .where(
              (user) => user.firstName?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterUsers);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dataFuture = fetchData(widget.groupId);
      _calculateCurrentBalance();
    });
  }

  void _calculateMonthBalanceByUser(List<Comment> comments) {
    String currentMonth =
        DateTime.now().month.toString(); // Current month as a string
    String currentYear = DateTime.now().year.toString(); // Current year

    // Map to store the total amount per person for the current month
    Map<String, double> userBalances = {};

    for (var data in comments) {
      if (data.postedAt!.year.toString() == currentYear &&
          data.postedAt!.month.toString() == currentMonth) {
        // Combine first and last names for the contributor
        String contributorName =
            "${data.user!.firstName} ${data.user?.lastName}";

        // Update the user's total balance
        userBalances.update(
          contributorName,
          (value) => value + (data.isVerified==true?(double.tryParse(data.amount.toString()) ?? 0):0.0),
          ifAbsent: () => (data.isVerified==true?(double.tryParse(data.amount.toString()) ?? 0):0.0),
        );
      }
    }

    setState(() {
      monthlyDataPerUser = userBalances;
    });
    // Print the result for debugging
    debugPrint(userBalances.toString());
  }

// This function help to get current balance and monthly data to plot the bar chart
  void _calculateCurrentBalance() async {
    joinGroup(widget.groupId.toString());
    // Clear previous data
    monthlyDataWithYear.clear();

    final List<Comment> comments = await _dataFuture;

    if (comments != null) {
      double newBalance = 0;

      for (var comment in comments) {
        // Check if the comment belongs to the correct group
        if (comment.group!.groupId == widget.groupId) {
          // Extract year and month from comment's posted date
          String yearKey = comment.postedAt!.year.toString();
          String monthKey = comment.postedAt!.month.toString();

          // Ensure year map exists
          if (!monthlyDataWithYear.containsKey(yearKey)) {
            monthlyDataWithYear[yearKey] = {};
          }

          // Update the monthly data within the year map
          monthlyDataWithYear[yearKey]!.update(
            monthKey,
            (value) =>
                value + (comment.isVerified==true?(double.tryParse(comment.amount.toString()) ?? 0):0.0),
            ifAbsent: () => comment.isVerified==true?(double.tryParse(comment.amount.toString()) ?? 0):0.0,
          );

          // Update the overall balance
          newBalance += (comment.isVerified==true?(double.tryParse(comment.amount.toString()) ?? 0):0.0);
        }
      }

      setState(() {
        temp = monthlyDataWithYear;
        currentBalance = newBalance;
      });
      _calculateMonthBalanceByUser(comments);
    } else {
      // Reset the balance if no comments are found
      setState(() {
        currentBalance = 0;
        monthlyDataWithYear.clear();
      });
    }
  }

  void joinGroup(String groupId) {
    // Subscribe to the group topic when joining a group
    NotificationService().subscribeToGroup(groupId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (groupData == null) {
      return Center(child: Text("Group details not found"));
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: FutureBuilder<List<Comment>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard(
                            groupData!.groupName.toString(),
                            groupData!.description,
                            groupData!.groupId,
                            user!.userId,
                            isDarkMode),
                        const SizedBox(height: 16),
                        _buildBarChart(isDarkMode),
                        const SizedBox(height: 16),
                        _buildPiChart(true),
                        const SizedBox(height: 16),
                        Container(
                          width: screenWidth * 0.8,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Container(
                                  height: 50,
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
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey),
                                      hintText: "Search...",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (isCreator) {
                                     String encodedGroupId = base64Url.encode(utf8.encode(widget.groupId.toString()));
                                    String encodedAdminId = base64Url.encode(utf8.encode(user!.userId.toString()));
                                    String url = "https://groupmoneycollection.web.app/join?groupId=$encodedGroupId&adminId=$encodedAdminId";
                                  
                                    Clipboard.setData(ClipboardData(
                                        text:url));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Text copied to clipboard")),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Only Admin can Invite members to group")),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black87.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.blueAccent,
                                              size: 25,
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              "Invite Your Friend",
                                              style: TextStyle(fontSize: 15),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                              // Use ListView.builder without Expanded
                              Container(
                                height: filteredUsers.length *
                                    60.0, // or any height per item
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                    chatUser:
                                                        filteredUsers[index],
                                                    groupId: widget.groupId,
                                                    isCreator: isCreator, loggedInUser: user,
                                                  )),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(left: 15),
                                        height:
                                            60, // fixed height for each user item
                                        width: screenWidth * 0.8,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              child:
                                                  Icon(Icons.person_3_outlined),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              filteredUsers[index].firstName! +
                                                  " " +
                                                  filteredUsers[index]
                                                      .lastName
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Text("No Data found");
                }),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      String title, String subtitle, int groupId, int userId, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12,
  
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Text with Overflow
                Text(
                  title,
                  maxLines: 1, // Restrict to one line
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.039,
                  ),
                ),
                const SizedBox(height: 3),
                // Subtitle Text with Overflow
                Text(
                  subtitle,
                  maxLines: 1, // Restrict to one line
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                  style: TextStyle(
                    fontSize: screenWidth * 0.033,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Rounded button with delete icon and text
          TextButton(
            onPressed: () {
              // Show confirmation dialog first
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text(
                    isCreator
                        ? 'Do you want to delete this group?'
                        : 'Do you want to leave this group?',
                  ),
                  actions: [
                    // Leave/Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    // Leave or Delete Button
                    TextButton(
                      onPressed: () async {
                       

                        // Perform the delete or leave action
                        if (isCreator) {
                          try {
                            await Provider.of<FetchApiModel>(context,
                                    listen: false)
                                .deleteGroup(groupId, userId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Group deleted successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Something went wrong...')),
                            );
                          }
                        } else {
                          try {
                            await Provider.of<FetchApiModel>(context,
                                    listen: false)
                                .leaveGroup(groupId, userId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('You have left the group.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Something went wrong...')),
                            );
                          }
                        }
                         // Close the dialog first
                        Navigator.of(context).pop();
                      },
                      child: Text(isCreator ? 'Delete' : 'Leave'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              backgroundColor:
                  Colors.black.withOpacity(0.5), // Transparent black
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              isCreator ? 'Delete Group' : 'Leave Group',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDarkMode) {
    return BarChartCard(
      isDarkMode: isDarkMode,
      currentBalance: currentBalance,
      monthlyDataWithYear: temp,
    );
  }

  Widget _buildPiChart(bool isDarkMode) {
    return PIChartContainer(monthlyDataWithYear: monthlyDataPerUser);
  }
}
