import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/modulo_json/providers/json_provider.dart';
import 'package:inv_telas/modulo_json/widgets/json_collection_card.dart';

class JsonViewScreen extends ConsumerWidget {
  const JsonViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jsonAsync = ref.watch(firebaseJsonProvider);

    return jsonAsync.when(
      data: (collections) {
        return ListView(
          padding: const EdgeInsets.all(16),

          children: [
            /// ITEM TODO
            JsonCollectionCard(
              title: 'TODO',
              total: collections.fold(0, (sum, item) => sum + item.data.length),

              onTap: () {
                final allData = {
                  for (var collection in collections)
                    collection.name: collection.data,
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        JsonDetailScreen(title: 'Todo Firebase', json: allData),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            /// COLECCIONES
            ...collections.map((collection) {
              return JsonCollectionCard(
                title: collection.name,

                total: collection.data.length,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JsonDetailScreen(
                        title: collection.name,
                        json: collection.data,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },

      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class JsonDetailScreen extends StatelessWidget {
  final String title;
  final dynamic json;

  const JsonDetailScreen({super.key, required this.title, required this.json});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: SelectableText(
          const JsonEncoder.withIndent('  ').convert(json),

          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
