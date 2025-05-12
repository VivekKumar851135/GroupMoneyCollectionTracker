import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';




class CreateGroupDialog extends StatelessWidget {
  // Use TextEditingController directly in a StatelessWidget
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();

 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create New Group"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: groupNameController,
            decoration: InputDecoration(
              labelText: "Group Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12.0),
          TextField(
            controller: groupDescriptionController,
            decoration: InputDecoration(
              labelText: "Group Description",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: ()async {
            String groupName = groupNameController.text;
            String groupDescription = groupDescriptionController.text;
            try {
               await Provider.of<FetchApiModel>(context, listen: false).createGroup(groupName, groupDescription);
             
                // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Create Group successful!')),
                  );
            } catch (e) {
              debugPrint("Create Group: $e");
              // Handle login error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Create Group failed: $e')),);
            }
            // Handle the group creation logic here
            print("Group Name: $groupName");
            print("Group Description: $groupDescription");
           context.go('/'); // Close the dialog
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text("Create Group"),
        ),
      ],
    );
  }
}