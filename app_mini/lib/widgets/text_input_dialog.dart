import 'package:flutter/material.dart';

/* Asks the user for one line of text. Returns what was typed (not trimmed)
or null when cancelled.

The TextEditingController lives in the dialog's own State, so it is disposed
together with the dialog route, after its closing animation. Disposing a
controller from the caller right after `await showDialog(...)` is a bug: the
TextField is still on screen during the exit animation, which ends in
framework assertions such as "_dependents.isEmpty is not true".

[emptyMessage], when given, makes an empty answer invalid (shown under the
field). Without it, the caller decides what an empty answer means. */
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  required String cancelLabel,
  String initialText = '',
  String? emptyMessage,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      label: label,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialText: initialText,
      emptyMessage: emptyMessage,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initialText,
    required this.emptyMessage,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String cancelLabel;
  final String initialText;
  final String? emptyMessage;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: widget.label),
          validator: widget.emptyMessage == null
              ? null
              : (value) => (value ?? '').trim().isEmpty
                  ? widget.emptyMessage
                  : null,
          onFieldSubmitted: (_) => _confirm(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        TextButton(
          onPressed: _confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}