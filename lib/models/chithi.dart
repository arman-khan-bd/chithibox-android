class SenderDisplay {
  final String name;
  final String? username;
  final bool isAnonymous;

  SenderDisplay({
    required this.name,
    this.username,
    this.isAnonymous = false,
  });

  factory SenderDisplay.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SenderDisplay(name: 'Sender', isAnonymous: false);
    }
    return SenderDisplay(
      name: json['name']?.toString() ?? 'Sender',
      username: json['username']?.toString(),
      isAnonymous: json['isAnonymous'] == true,
    );
  }
}

class ChithiModel {
  final String id;
  final String? senderId;
  final String? recipientUserId;
  final String? subject;
  final String body;
  final String? place;
  final String? letterDate;
  final String? salutation;
  final String? closing;
  final String? signature;
  final String stampDesign;
  final String envelopeDesign;
  final String sealDesign;
  final String theme;
  final String font;
  final String fontColor;
  final bool isAnonymous;
  final bool isStarred;
  final bool isArchived;
  final DateTime? readAt;
  final DateTime createdAt;
  final SenderDisplay senderDisplay;
  final String? recipientDisplay;
  final bool isSender;
  final bool isRecipient;

  ChithiModel({
    required this.id,
    this.senderId,
    this.recipientUserId,
    this.subject,
    required this.body,
    this.place,
    this.letterDate,
    this.salutation,
    this.closing,
    this.signature,
    this.stampDesign = 'shapla',
    this.envelopeDesign = 'classic_khaki',
    this.sealDesign = 'crimson_lotus',
    this.theme = 'notebook',
    this.font = 'patralekha',
    this.fontColor = '#1e293b',
    this.isAnonymous = false,
    this.isStarred = false,
    this.isArchived = false,
    this.readAt,
    required this.createdAt,
    required this.senderDisplay,
    this.recipientDisplay,
    this.isSender = false,
    this.isRecipient = true,
  });

  bool get isRead => readAt != null;

  factory ChithiModel.fromJson(Map<String, dynamic> json) {
    return ChithiModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString(),
      recipientUserId: json['recipientUserId']?.toString(),
      subject: json['subject']?.toString(),
      body: json['body']?.toString() ?? '',
      place: json['place']?.toString(),
      letterDate: json['letterDate']?.toString(),
      salutation: json['salutation']?.toString(),
      closing: json['closing']?.toString(),
      signature: json['signature']?.toString(),
      stampDesign: json['stampDesign']?.toString() ?? 'shapla',
      envelopeDesign: json['envelopeDesign']?.toString() ?? 'classic_khaki',
      sealDesign: json['sealDesign']?.toString() ?? 'crimson_lotus',
      theme: json['theme']?.toString() ?? 'notebook',
      font: json['font']?.toString() ?? 'patralekha',
      fontColor: json['fontColor']?.toString() ?? '#1e293b',
      isAnonymous: json['isAnonymous'] == true,
      isStarred: json['isStarred'] == true,
      isArchived: json['isArchived'] == true,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'].toString()) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      senderDisplay: SenderDisplay.fromJson(json['senderDisplay'] as Map<String, dynamic>?),
      recipientDisplay: json['recipientDisplay']?.toString(),
      isSender: json['isSender'] == true,
      isRecipient: json['isRecipient'] != false,
    );
  }

  ChithiModel copyWith({
    bool? isStarred,
    bool? isArchived,
    DateTime? readAt,
  }) {
    return ChithiModel(
      id: id,
      senderId: senderId,
      recipientUserId: recipientUserId,
      subject: subject,
      body: body,
      place: place,
      letterDate: letterDate,
      salutation: salutation,
      closing: closing,
      signature: signature,
      stampDesign: stampDesign,
      envelopeDesign: envelopeDesign,
      sealDesign: sealDesign,
      theme: theme,
      font: font,
      fontColor: fontColor,
      isAnonymous: isAnonymous,
      isStarred: isStarred ?? this.isStarred,
      isArchived: isArchived ?? this.isArchived,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      senderDisplay: senderDisplay,
      recipientDisplay: recipientDisplay,
      isSender: isSender,
      isRecipient: isRecipient,
    );
  }
}
