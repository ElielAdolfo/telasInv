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

    final rollos = await firestore.collection('rollos').get();
    final empresas = await firestore.collection('catalog_empresas').get();
    final colores = await firestore.collection('catalog_colores').get();
    final tipos = await firestore.collection('catalog_tipos_tela').get();

    data = {
      "rollos": rollos.docs.map((e) => e.data()).toList(),
      "empresas": empresas.docs.map((e) => e.data()).toList(),
      "colores": colores.docs.map((e) => e.data()).toList(),
      "tiposTela": tipos.docs.map((e) => e.data()).toList(),
    };

    setState(() {
      loading = false;
    });
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
