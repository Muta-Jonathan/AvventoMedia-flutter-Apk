import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../apis/send_email_api.dart';
import '../models/sendemail/send_email.dart';

class PrayerRequestField extends StatefulWidget {
  const PrayerRequestField({super.key,});

  @override
  PrayerRequestFieldState createState() => PrayerRequestFieldState();
}

class PrayerRequestFieldState extends State<PrayerRequestField> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SendEmail sendEmailData = SendEmail(
    name: '',
    phoneNumber: '',
    email: '',
    subject: '',
    message: '',
  );

  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final prayForController = TextEditingController();
  final prayerRequestController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    prayForController.dispose();
    prayerRequestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextOverlay(label: "\"Rejoice evermore. Pray without ceasing....\" 1 Thessalonians 5:16-23",
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
          ),
          const SizedBox(height: 20,),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Icon(
                CupertinoIcons.person,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              hintText: 'Enter your name',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
              ),
              focusColor: Theme.of(context).colorScheme.onPrimary,
            ),
            validator: (value) {
              if (value!.isEmpty || !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) {
              sendEmailData.name = value?.toString() ?? '';
            },
          ),
          const SizedBox(height: 10,),
          IntlPhoneField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              hintText: 'Phone Number',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
              ),
              focusColor: Theme.of(context).colorScheme.onPrimary,
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter your correct number';
              }
              return null;
            },
            onSaved: (value) {
              sendEmailData.phoneNumber = value!.toString();
            },
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Icon(
                CupertinoIcons.mail,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              hintText: 'Enter your email',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
              ),
              focusColor: Theme.of(context).colorScheme.onPrimary,
            ),
            validator: (email) {
              if (email!.isEmpty || !EmailValidator.validate(email)) {
                return 'Please enter a correct email';
              }
              return null;
            },
            onSaved: (value) {
             sendEmailData.email = value!;
            },
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: prayForController,
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Icon(
                FontAwesomeIcons.personPraying,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              hintText: 'Pray For',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
              ),
              focusColor: Theme.of(context).colorScheme.onPrimary,
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter what you want to join with you in Prayer';
              }
              return null;
            },
            onSaved: (value) {
              sendEmailData.subject = value!;
            },
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: prayerRequestController,
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Icon(
                    FontAwesomeIcons.message,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              ),
              hintText: 'Prayer Request',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
              ),
              focusColor: Theme.of(context).colorScheme.onPrimary,
            ),
            maxLines: 6,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your Prayer Request';
              }
              return null;
            },
            onSaved: (value) {
              sendEmailData.message = value!;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed:
                  () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState?.save();
                  final result = await SendEmailAPI.sendEmail(sendEmailData);
                  if (context.mounted) {

                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: result ? 'Successful' : 'Oops need to try Again',
                        message:
                        result ? 'Hey ${sendEmailData.name}, Prayer Request sent successfully 🎉 ' : 'Error sending your Prayer Request 🚫',

                        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                        contentType: result ? ContentType.success :  ContentType.failure,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  }

                  if (result) {
                    sendEmailData.reset();
                    nameController.clear();
                    phoneNumberController.clear();
                    emailController.clear();
                    prayForController.clear();
                    prayerRequestController.clear();
                  }
              }
            },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 40)),
                backgroundColor: MaterialStateProperty.all(Colors.orange),
              ),
              child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

}
