import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JsonViewScreen extends StatefulWidget {
  const JsonViewScreen({super.key});

  @override
  State<JsonViewScreen> createState() => _JsonViewScreenState();
}

class _JsonViewScreenState extends State<JsonViewScreen> {
  Map<String, dynamic> data = {};
  bool loading = true;

  Future<void> cargarDatos() async {
    final firestore = FirebaseFirestore.instance;

    final Map<String, dynamic> tempData = {};

    // Lista automática de colecciones
    final collections = [
      'rollos',
      'catalog_empresas',
      'catalog_colores',
      'catalog_tipos_tela',
      'catalog_sucursales',
      'catalog_monedas',
      'catalog_anchos',
      'users',
    ];

    for (final collectionName in collections) {
      final snapshot = await firestore.collection(collectionName).get();

      tempData[collectionName] = snapshot.docs
          .map((doc) => convertirFirestore(doc.data()))
          .toList();
    }

    setState(() {
      data = tempData;
      loading = false;
    });
  }

  dynamic convertirFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key, convertirFirestore(val)));
    }

    if (value is List) {
      return value.map(convertirFirestore).toList();
    }

    return value;
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Datos JSON Firebase")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(data),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
    );
  }
}
