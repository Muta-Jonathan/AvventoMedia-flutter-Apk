import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameTextField extends StatefulWidget {
  String name;
  NameTextField({super.key, required this.name});

  @override
  _NameTextFieldState createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextOverlay(label: "Full Name",
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
          ),
          SizedBox(height: 10,),
          TextFormField(
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
              if (value!.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) {
              widget.name = value!;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState?.save();
                // Do something with the validated name, for example, submit it.
                print('Name: ${widget.name}');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
