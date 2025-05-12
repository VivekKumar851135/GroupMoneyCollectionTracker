import 'package:money_collection_2/Entity/Creator.dart';
import 'package:money_collection_2/Entity/User.dart';


class Group {
  final int groupId; // In Java, it was `Long`; here we use `int` for Dart.
  final String? groupName;
  final String description;
  final Creator creator; // This maps to the `creator` in the Java class.
  final String createdAt; // In Java, it's a `LocalDateTime`, in Dart it's a String or DateTime.
  final List<User> admins;
  final List<User> members;
  final String? groupProfilePic; // This maps to `groupProfilePic` in the Java class.

  Group({
    required this.groupId,
    required this.groupName,
    required this.description,
    required this.creator,
    required this.createdAt,
    required this.admins,
    required this.members,
    this.groupProfilePic, // Optional field
  });

  // Convert JSON to Group object
  factory Group.fromJson(Map<String, dynamic> json) {
    var adminList = json['admins'] as List;
    var memberList = json['members'] as List;

    return Group(
      groupId: json['groupId'],
      groupName: json['groupName'],
      description: json['description'],
      creator: Creator.fromJson(json['creator']),
      createdAt: json['createdAt'],
      admins: adminList.map((e) => User.fromJson(e)).toList(),
      members: memberList.map((e) => User.fromJson(e)).toList(),
      groupProfilePic: json['groupProfilePic'], // Optional field
    );
  }

  // Convert Group object to JSON
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'description': description,
      'creator': creator.toJson(),
      'createdAt': createdAt,
      'admins': admins.map((admin) => admin.toJson()).toList(),
      'members': members.map((member) => member.toJson()).toList(),
      'groupProfilePic': groupProfilePic, // Optional field
    };
  }
}