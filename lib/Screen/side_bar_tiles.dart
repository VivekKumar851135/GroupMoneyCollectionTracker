import 'package:flutter/material.dart';
import 'package:money_collection_2/Screen/CreateGroupDialog.dart';
import 'package:money_collection_2/Screen/UserProfileScreen.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';


class SideBarTiles extends StatefulWidget {
  final Function(int) onGroupSelected;
  final int? selectedGroupId;
  const SideBarTiles(
      {Key? key, required this.onGroupSelected, this.selectedGroupId})
      : super(key: key);

  @override
  State<SideBarTiles> createState() => _SideBarTilesState();
}

class _SideBarTilesState extends State<SideBarTiles> {
  int? selectedGroupId; // Track the selected group ID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedGroupId = widget.selectedGroupId;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    final fetchModelApi = Provider.of<FetchApiModel>(context);

    if (fetchModelApi != null && fetchModelApi.needsRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchModelApi.setNeedsRefresh(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<FetchApiModel>(context).isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<FetchApiModel>(
      builder: (context, fetchApiModel, child) {
        if (fetchApiModel == null) {
          return Center(child: CircularProgressIndicator());
        } else if (fetchApiModel.getLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Container(
          width: screenWidth * 0.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Color(0xFF33373B).withOpacity(0.9),
                      Color(0xFF232529).withOpacity(0.7),
                    ]
                  : [
                      Color(0xFFFFA07A).withOpacity(0.9),
                      Color(0xFFFFC0CB).withOpacity(0.7),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileScreen()),
                  );
                },
                child: _buildHomeButton(
                    fetchApiModel.user!.firstName.toString(),
                    fetchApiModel.user!.lastName.toString(),
                    fetchApiModel.user!.profileUrl.toString()),
              ),
              _buildDivider(),
              SizedBox(height: screenHeight * 0.005),

              // Group list visibility
              Expanded(
                child: Visibility(
                  visible: fetchApiModel.data?.isNotEmpty ?? false,
                  replacement: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        "Create  groups",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fetchApiModel.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Column(
                          children: [
                            _buildFaceButton(
                              index: index,
                              isSelected: selectedGroupId ==
                                  fetchApiModel.data![index].groupId,
                              screenHeight: screenHeight,
                            ),
                            SizedBox(
                              height: screenHeight * 0.002,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                              child: Text(
                                "${fetchApiModel.data![index].groupName}",
                                style:
                                    TextStyle(fontSize: 10, color: Colors.white),
                                maxLines: 1, // Limits to one line
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectedGroupId =
                                fetchApiModel.data![index].groupId;
                          });
                          widget.onGroupSelected(
                              fetchApiModel.data![index].groupId);
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.005),
              _buildDivider(),
              SizedBox(height: screenHeight * 0.005),

              // Search button
              // _searchButton(),
              // SizedBox(height: screenHeight * 0.01),

              // Create Group button (Always Visible)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateGroupDialog()),
                ),
                child: _createButton(),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildHomeButton(String firstName, String lastName, String profileUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF5865F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
          child: Text(
        (firstName.isNotEmpty ? firstName[0].toUpperCase() : " ") +
            (lastName.isNotEmpty ? lastName[0].toUpperCase() : ""),
        style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      )),
    ),
  );
}

Widget _buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Container(
      height: 2,
      color: const Color.fromARGB(255, 99, 101, 104),
    ),
  );
}

Widget _buildFaceButton(
    {required int index,
    required bool isSelected,
    required final screenHeight}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        key: ValueKey(isSelected),
        duration: const Duration(milliseconds: 300), // Animation duration
        curve: Curves.easeInOut, // Animation curve
        margin: EdgeInsets.only(
            top: screenHeight * 0.005, bottom: screenHeight * 0.005),
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5865F2)
              : const Color.fromARGB(255, 236, 237, 249),
          borderRadius: BorderRadius.circular(
              isSelected ? 16 : 30), // Change shape based on selection
        ),
        child: const Center(
          child: Icon(
            Icons.person_2_outlined,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    ),
  );
}

Widget _searchButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 237, 249),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.search_outlined,
          color: Colors.black,
          size: 28,
        ),
      ),
    ),
  );
}

Widget _createButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 237, 249),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 28,
        ),
      ),
    ),
  );
}
