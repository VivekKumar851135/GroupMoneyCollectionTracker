
import 'package:money_collection_2/Entity/Group.dart';
import 'package:money_collection_2/Entity/User.dart';

class Comment {
  int? commentId;
  String? commentText;
  DateTime? postedAt;
  bool? isVerified;
  User? verifiedBy;
  User? user;
  Group? group;
  DateTime? verifiedAt;

  // New fields
  String? imageUrl; // Field to store the image URL
  double? amount;   // Field to store the amount

  Comment({
    this.commentId,
    this.commentText,
    this.postedAt,
    this.isVerified,
    this.verifiedBy,
    this.user,
    this.group,
    this.verifiedAt,
    this.imageUrl, // Include the new field in the constructor
    this.amount,    // Include the new field in the constructor
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      commentText: json['commentText'],
      postedAt: json['postedAt'] != null ? DateTime.parse(json['postedAt']) : null, // Null check for postedAt
      isVerified: json['isVerified'],
      verifiedBy: json['verifiedBy'] != null ? User.fromJson(json['verifiedBy']) : null, // Null check
      user: json['user'] != null ? User.fromJson(json['user']) : null, // Null check
      group: json['group'] != null ? Group.fromJson(json['group']) : null, // Null check
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      imageUrl: json['imageUrl'], // Parse the image URL from JSON
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null, // Parse the amount from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'commentText': commentText,
      'postedAt': postedAt?.toIso8601String(), // Use null-aware operator for postedAt
      'isVerified': isVerified,
      'verifiedBy': verifiedBy?.toJson(), // Use null-aware operator for verifiedBy
      'user': user?.toJson(), // Use null-aware operator for user
      'group': group?.toJson(), // Use null-aware operator for group
      'verifiedAt': verifiedAt?.toIso8601String(),
      'imageUrl': imageUrl, // Include the image URL in the JSON output
      'amount': amount,      // Include the amount in the JSON output
    };
  }
}