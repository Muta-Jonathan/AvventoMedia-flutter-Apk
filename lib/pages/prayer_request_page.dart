import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../apis/send_email_api.dart';
import '../components/app_constants.dart';
import '../components/app_snackbar.dart';
import '../models/sendemail/send_email.dart';

/// Sends a prayer request; true on success.
typedef PrayerRequestSender = Future<bool> Function(SendEmail request);

class PrayerRequestPage extends StatefulWidget {
  const PrayerRequestPage({super.key, this.sender = SendEmailAPI.sendEmail});

  /// Injectable for tests.
  final PrayerRequestSender sender;

  @override
  State<PrayerRequestPage> createState() => _PrayerRequestPageState();
}

/// Colours from the redesign, with a light-theme counterpart.
class _Palette {
  _Palette(BuildContext context)
      : dark = Theme.of(context).brightness == Brightness.dark;
  final bool dark;

  static const accent = Color(0xFFFFB300);
  static const error = Color(0xFFFF6B6B);

  Color get card => dark ? const Color(0xFF221F33) : Colors.white;
  Color get text => dark ? Colors.white : const Color(0xFF161424);
  Color get muted => dark ? const Color(0xFF9E9CB0) : Colors.black54;
  Color get hint => dark ? const Color(0xFF6F6C85) : Colors.black38;
  Color get icon => dark ? const Color(0xFFBDBDBD) : Colors.black45;
  Color get separator => dark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.08);
  Color get chipBorder => dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.1);
}

class _PrayerRequestPageState extends State<PrayerRequestPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _prayFor = TextEditingController();
  final _message = TextEditingController();

  String _completePhone = '';

  /// Errors show only after the first Send attempt.
  bool _tried = false;
  bool _sending = false;

  /// First name of a sent request; non-null shows the success view.
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    // Rebuild for chip selection, the counter and live error clearing.
    for (final c in [_name, _phone, _email, _prayFor, _message]) {
      c.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _prayFor, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _nameError {
    final name = _name.text.trim();
    return name.isEmpty || !RegExp(r'^[a-zA-Z ]+$').hasMatch(name)
        ? AppConstants.prayerErrorName
        : null;
  }

  String? get _phoneError =>
      _phone.text.trim().isEmpty ? AppConstants.prayerErrorPhone : null;

  String? get _emailError => EmailValidator.validate(_email.text.trim())
      ? null
      : AppConstants.prayerErrorEmail;

  String? get _prayForError =>
      _prayFor.text.trim().isEmpty ? AppConstants.prayerErrorPrayFor : null;

  String? get _messageError =>
      _message.text.trim().isEmpty ? AppConstants.prayerErrorMessage : null;

  String? _shown(String? error) => _tried ? error : null;

  Future<void> _send() async {
    if (_sending) return;
    final hasErrors = [
      _nameError,
      _phoneError,
      _emailError,
      _prayForError,
      _messageError,
    ].any((e) => e != null);
    if (hasErrors) {
      setState(() => _tried = true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    final name = _name.text.trim();
    final ok = await widget.sender(SendEmail(
      name: name,
      phoneNumber: _completePhone.isNotEmpty ? _completePhone : _phone.text,
      email: _email.text.trim(),
      subject: _prayFor.text.trim(),
      message: _message.text.trim(),
    ));
    if (!mounted) return;

    setState(() {
      _sending = false;
      if (ok) _sentTo = name.split(' ').first;
    });
    if (!ok) AppSnackbar.show(AppConstants.prayerRequestError);
  }

  void _reset() {
    for (final c in [_name, _phone, _email, _prayFor, _message]) {
      c.clear();
    }
    setState(() {
      _completePhone = '';
      _tried = false;
      _sentTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _Palette(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.text),
        title: Text(AppConstants.prayerRequest,
            style: TextStyle(
                color: palette.text,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: _sentTo != null
          ? _SuccessView(
              firstName: _sentTo!, palette: palette, onSendAnother: _reset)
          : _buildForm(palette),
    );
  }

  Widget _buildForm(_Palette palette) {
    final detailErrors = [
      _shown(_nameError),
      _shown(_phoneError),
      _shown(_emailError),
    ].whereType<String>().join(' · ');
    final requestErrors = [
      _shown(_prayForError),
      _shown(_messageError),
    ].whereType<String>().join(' · ');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.prayerHeadline,
                        style: TextStyle(
                            color: palette.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15)),
                    const SizedBox(height: 8),
                    Text(AppConstants.prayerSubtitle,
                        style: TextStyle(
                            color: palette.muted, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
              _SectionTitle(AppConstants.prayerYourDetails, palette),
              _Card(
                palette: palette,
                child: Column(
                  children: [
                    _FieldRow(
                      palette: palette,
                      icon: CupertinoIcons.person,
                      hasError: _shown(_nameError) != null,
                      child: _PlainField(
                        controller: _name,
                        hint: AppConstants.prayerHintName,
                        palette: palette,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    _Separator(palette),
                    _FieldRow(
                      palette: palette,
                      icon: CupertinoIcons.phone,
                      hasError: _shown(_phoneError) != null,
                      // The country picker dialog inherits this Theme; the
                      // app's dark onSurface matches the background.
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context)
                              .colorScheme
                              .copyWith(onSurface: palette.text),
                          // Text styles were coloured when the theme was
                          // built, so recolour them too.
                          textTheme: Theme.of(context).textTheme.apply(
                              bodyColor: palette.text,
                              displayColor: palette.text),
                        ),
                        child: IntlPhoneField(
                          controller: _phone,
                          initialCountryCode: 'UG',
                          disableLengthCheck: true,
                          showDropdownIcon: true,
                          dropdownIconPosition: IconPosition.trailing,
                          flagsButtonPadding: EdgeInsets.zero,
                          dropdownTextStyle:
                              TextStyle(color: palette.text, fontSize: 15),
                          style: TextStyle(color: palette.text, fontSize: 15),
                          cursorColor: _Palette.accent,
                          pickerDialogStyle: PickerDialogStyle(
                            backgroundColor: palette.card,
                            countryNameStyle: TextStyle(
                                color: palette.text,
                                fontWeight: FontWeight.w600),
                            countryCodeStyle: TextStyle(
                                color: palette.muted,
                                fontWeight: FontWeight.w600),
                            listTileDivider:
                                Divider(height: 1, color: palette.separator),
                            searchFieldCursorColor: _Palette.accent,
                            searchFieldInputDecoration: InputDecoration(
                              hintText: AppConstants.prayerSearchCountry,
                              hintStyle: TextStyle(color: palette.hint),
                              suffixIcon: Icon(CupertinoIcons.search,
                                  color: palette.icon),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: palette.separator)),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: _Palette.accent)),
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: AppConstants.prayerHintPhone,
                            hintStyle: TextStyle(color: palette.hint),
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                          ),
                          onChanged: (number) =>
                              _completePhone = number.completeNumber,
                        ),
                      ),
                    ),
                    _Separator(palette),
                    _FieldRow(
                      palette: palette,
                      icon: CupertinoIcons.mail,
                      hasError: _shown(_emailError) != null,
                      child: _PlainField(
                        controller: _email,
                        hint: AppConstants.prayerHintEmail,
                        palette: palette,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
              ),
              if (detailErrors.isNotEmpty) _ErrorText(detailErrors),
              _SectionTitle(AppConstants.prayerPrayForSection, palette),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final topic in AppConstants.prayerTopics)
                    _TopicChip(
                      label: topic,
                      selected: _prayFor.text == topic,
                      palette: palette,
                      // Tapping the selected chip clears it.
                      onTap: () =>
                          _prayFor.text = _prayFor.text == topic ? '' : topic,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _Card(
                palette: palette,
                hasError: _shown(_prayForError) != null,
                child: _FieldRow(
                  palette: palette,
                  icon: CupertinoIcons.shield,
                  child: _PlainField(
                    controller: _prayFor,
                    hint: AppConstants.prayerHintPrayFor,
                    palette: palette,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              _SectionTitle(AppConstants.prayerYourRequest, palette),
              _Card(
                palette: palette,
                hasError: _shown(_messageError) != null,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextField(
                        controller: _message,
                        minLines: 6,
                        maxLines: 10,
                        maxLength: AppConstants.prayerMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: _Palette.accent,
                        style: TextStyle(
                            color: palette.text, fontSize: 15, height: 1.5),
                        decoration: InputDecoration(
                          hintText: AppConstants.prayerHintMessage,
                          hintStyle: TextStyle(color: palette.hint),
                          border: InputBorder.none,
                          isCollapsed: true,
                          counterText: '',
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_message.text.length} / ${AppConstants.prayerMaxLength}',
                          style: TextStyle(color: palette.hint, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (requestErrors.isNotEmpty) _ErrorText(requestErrors),
            ],
          ),
        ),

        // Pinned send button, above the keyboard and the home indicator.
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: _Palette.accent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: _Palette.accent.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.black54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: Text(_sending
                  ? AppConstants.prayerSending
                  : AppConstants.prayerSend),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.palette);
  final String title;
  final _Palette palette;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 26, 4, 8),
        child: Text(title,
            style: TextStyle(
                color: palette.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7)),
      );
}

class _Card extends StatelessWidget {
  const _Card(
      {required this.palette, required this.child, this.hasError = false});
  final _Palette palette;
  final Widget child;
  final bool hasError;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: hasError ? _Palette.error : Colors.transparent),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.palette,
    required this.icon,
    required this.child,
    this.hasError = false,
  });
  final _Palette palette;
  final IconData icon;
  final Widget child;
  final bool hasError;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 18, color: hasError ? _Palette.error : palette.icon),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        ),
      );
}

class _PlainField extends StatelessWidget {
  const _PlainField({
    required this.controller,
    required this.hint,
    required this.palette,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });
  final TextEditingController controller;
  final String hint;
  final _Palette palette;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        cursorColor: _Palette.accent,
        style: TextStyle(color: palette.text, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: palette.hint),
          border: InputBorder.none,
          isDense: true,
        ),
      );
}

class _Separator extends StatelessWidget {
  const _Separator(this.palette);
  final _Palette palette;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 44),
        child: Divider(height: 0.5, thickness: 0.5, color: palette.separator),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
        child: Text(text,
            style: const TextStyle(
                color: _Palette.error, fontSize: 12, height: 1.5)),
      );
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final _Palette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _Palette.accent : palette.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected ? _Palette.accent : palette.chipBorder),
            ),
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.black : palette.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.firstName,
    required this.palette,
    required this.onSendAnother,
  });
  final String firstName;
  final _Palette palette;
  final VoidCallback onSendAnother;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: _Palette.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 44, color: _Palette.accent),
              ),
              const SizedBox(height: 22),
              Text(AppConstants.prayerSent,
                  style: TextStyle(
                      color: palette.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(AppConstants.prayerSentMessage(firstName),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: palette.muted, fontSize: 14, height: 1.55)),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: onSendAnother,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Palette.accent,
                  side: const BorderSide(color: _Palette.accent),
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text(AppConstants.prayerSendAnother),
              ),
            ],
          ),
        ),
      );
}
