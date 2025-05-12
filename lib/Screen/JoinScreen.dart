import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:money_collection_2/Utility/NotificationService.dart';
import 'package:provider/provider.dart';



class JoinScreen extends StatelessWidget {
  final String? groupId;
  final String? adminId;
  const JoinScreen({super.key, this.groupId , this.adminId});

  void joinGroup(String groupId) {
    // Subscribe to the group topic when joining a group
    NotificationService().subscribeToGroup(groupId);
  }

  @override
  Widget build(BuildContext context) {
    //final GoRouterState state = GoRouterState.of(context);
    // final String? groupId = state.uri.queryParameters['groupId'];
    // final String? userAdminId = state.uri.queryParameters['adminId'];
    final int userId=Provider.of<FetchApiModel>(context, listen: false).user!.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Group'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Join group with ID: $groupId + adminId: $adminId'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Perform login
                  await Provider.of<FetchApiModel>(context, listen: false).joinGroup(groupId!, userId.toString(), adminId!);
                  joinGroup(groupId!);
                  // Navigate based on redirect after login
                   context.go('/');
                } catch (e) {
                    context.go('/error?errorMsg=$e');
                }
                
              },
              child: Text('Join Group'),
            ),
          ],
        ),
      ),
    );
  }
}