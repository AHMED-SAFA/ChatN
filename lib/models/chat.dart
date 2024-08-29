//
// class Chat {
//   String? id;
//   List<string>? participants;
//   List<message>? messages;
//
//   Chat({
//     required this.id,
//     required this.participants,
//     required this.messages,
//   });
//
//   Chat.fromJson(Map<string dynamic> json) {
//   id = json['id'];
//   participants = List<string>.from(json['participants']);
//   messages =
//   List.from(json['messages']).map((m) => Message.fromJson(m)).toList();
//   }
//
//   Map<string dynamic> toJson() {
//   final Map<string dynamic> data = <string dynamic>{};
//   data['id'] = id;
//   data['participants'] = participants;
//   data['messages'] = messages?.map((m) => m.toJson()).toList() ?? [];
//   return data;
//   }
// }</string></string></string></string></string></message></string>