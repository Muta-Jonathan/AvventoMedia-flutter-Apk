class SendEmail {
  late String name;
  late String phoneNumber;
  late String email;
  late String subject;
  late String message;

  SendEmail({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.subject,
    required this.message,
});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_name': name,
      'user_number': phoneNumber,
      'user_email': email,
      'user_message': message,
      'user_subject': subject
    };

    return data;
  }

  void reset() {
    name = '';
    phoneNumber = '';
    email = '';
    subject = '';
    message = '';
  }
}