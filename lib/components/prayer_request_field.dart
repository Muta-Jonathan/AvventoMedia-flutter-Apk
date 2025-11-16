import 'package:avvento_media/components/app_constants.dart';
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
          TextOverlay(label: AppConstants.prayerRequestTitle,
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
          ),
          const SizedBox(height: 20,),
          TextFormField(
            controller: nameController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Icon(
                CupertinoIcons.person,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              hintText: AppConstants.prayerRequestHintName,
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
                return AppConstants.prayerRequestName;
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
            initialCountryCode: 'UG',
            dropdownTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            decoration: InputDecoration(
              prefixIconColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              iconColor: Theme.of(context).colorScheme.onPrimary,
              fillColor: Theme.of(context).colorScheme.secondary,
              hintText: AppConstants.prayerRequestHintPhone,
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
                return AppConstants.prayerRequestPhone;
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Icon(
                CupertinoIcons.mail,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              hintText: AppConstants.prayerRequestHintEmail,
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
                return AppConstants.prayerRequestEmail;
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            decoration: InputDecoration(
              hoverColor: Theme.of(context).colorScheme.onPrimary,
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              prefixIcon: Icon(
                FontAwesomeIcons.personPraying,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              hintText: AppConstants.prayerRequestHintPrayFor,
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
                return AppConstants.prayerRequestPrayFor;
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
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
              hintText: AppConstants.prayerRequest,
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
                return AppConstants.prayerRequestMessage;
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
                        title: result ? AppConstants.successful : AppConstants.error,
                        message:
                        result ? 'Hey ${sendEmailData.name}, Prayer Request sent successfully 🎉 ' :  AppConstants.prayerRequestError,

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
                minimumSize: WidgetStateProperty.all(const Size(double.infinity, 40)),
                backgroundColor: WidgetStateProperty.all(Colors.amber),
              ),
              child: const Text(AppConstants.send),
          ),
        ],
      ),
    );
  }

}
