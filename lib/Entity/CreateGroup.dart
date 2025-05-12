class Creategroup {
  String? groupName;
  String? groupDescription;
  String? groupProfilePic;
  Creategroup({required this.groupName, required this.groupDescription, required this.groupProfilePic});
  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'description': groupDescription,
      'groupProfilePic':groupProfilePic
    };
  }
}
