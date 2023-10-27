import 'dart:convert';
import 'package:avvento_media/models/sendemail/send_email.dart';

import 'package:http/http.dart' as http;

class SendEmailAPI {
  static Future<bool> sendEmail(SendEmail sendEmailData) async {
    const serviceId = "service_78aobee";
    const templateId = "template_arqna7a";
    const userId = "DFwSd_WhywHMACy84";
    
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': sendEmailData.toJson(),
      }),
    );
    if (response.statusCode == 200) {
      // Email sent successfully
      return true;
    } else {
      // Email sending failed
      return false;
    }
    
  }
}
