import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/find_controller.dart';

class FindDialogBox extends StatelessWidget {
  final FindController _controller;
  const FindDialogBox({super.key, required FindController controller})
    : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(20),
      title: Text('Find'),
      children: [
        TextField(
          controller: _controller.queryTextController,
          decoration: InputDecoration(hintText: 'Search text'),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _controller.find();
          },
        ),
        const SizedBox(height: 24),
        Row(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.find();
              },
              child: Text('Find'),
            ),
          ],
        ),
      ],
    );
  }
}
