import 'package:flutter/material.dart';

class JsonCollectionCard extends StatelessWidget {
  final String title;
  final int total;
  final VoidCallback onTap;

  const JsonCollectionCard({
    super.key,
    required this.title,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$total registros'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
