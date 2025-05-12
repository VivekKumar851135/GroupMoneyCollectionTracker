import 'package:flutter/material.dart';
import 'package:money_collection_2/Screen/GroupScreen.dart';
import 'package:money_collection_2/Screen/side_bar_tiles.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';


class Homescreen extends StatefulWidget {
  final int? groupId;
  final int? userId;

  const Homescreen({Key? key, this.groupId, this.userId}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    // Automatically select a group if a groupId is provided
    if (widget.groupId != null) {
      _selectedGroupId = widget.groupId;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<FetchApiModel>(context).isDarkMode;

    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [Color(0xFF142A24), Color(0xFF1E262D), Color(0xFF614B3A), Color(0xFF142A24)]
                  : [Color(0xFFFFC0CB), Color(0xFFFFA07A)],
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Sidebar for group selection
                SideBarTiles(
                  selectedGroupId: _selectedGroupId,
                  onGroupSelected: (int groupId) {
                    setState(() {
                      _selectedGroupId = groupId;
                    });
                  },
                ),
                // Main content area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedGroupId != null
                        ? GroupDetailsWindow(
                            key: ValueKey(_selectedGroupId),
                            groupId: _selectedGroupId!,
                            initialChatUserId: widget.userId,
                          )
                        : Center(
                            child: Text(
                              "Select a group to view details",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}