// import 'package:cloud_firestore/cloud_firestore.dart';
//
// enum MessageType { Text, Image }
//
// class Message {
//   String? senderID;
//   String? content;
//   MessageType? messageType;
//   Timestamp? sentAt;
//
//   Message({
//     required this.senderID,
//     required this.content,
//     required this.messageType,
//     required this.sentAt,
//   });
//
//   Message.fromJson(Map<string dynamic> json) {
//   senderID = json['senderID'];
//   content = json['content'];
//   sentAt = json['sentAt'];
//   messageType = MessageType.values.byName(json['messageType']);
//   }
//
//   Map<string dynamic> toJson() {
//   final Map<string dynamic> data = <string dynamic>{};
//   data['senderID'] = senderID;
//   data['content'] = content;
//   data['sentAt'] = sentAt;
//   data['messageType'] = messageType!.name;
//   return data;
//   }
// }</string></string></string></string>