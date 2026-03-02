import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const InvTelasApp());
}

class InvTelasApp extends StatelessWidget {
  const InvTelasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 CREAR
  Future<void> crearProducto() async {
    await _db.collection("productos").add({
      "nombre": "Tela Roja",
      "precio": 30,
      "stock": 50,
      "eliminado": false,
      "fechaCreacion": DateTime.now(),
      "fechaEliminacion": null,
    });
  }

  // 🔥 MODIFICAR
  Future<void> modificarProducto(String id) async {
    await _db.collection("productos").doc(id).update({
      "precio": 35,
      "stock": 80,
    });
  }

  // 🔥 ELIMINACIÓN LÓGICA
  Future<void> eliminarLogico(String id) async {
    await _db.collection("productos").doc(id).update({
      "eliminado": true,
      "fechaEliminacion": DateTime.now(),
    });
  }

  // 🔥 ELIMINACIÓN FÍSICA
  Future<void> eliminarFisico(String id) async {
    await _db.collection("productos").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("invTelas CRUD Firestore")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: crearProducto,
            child: const Text("Crear Producto"),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection("productos")
                  .where("eliminado", isEqualTo: false) // 👈 Solo activos
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No hay productos"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final producto = data.data() as Map<String, dynamic>;
                    final id = data.id;

                    return Card(
                      child: ListTile(
                        title: Text(producto["nombre"]),
                        subtitle: Text(
                          "Precio: ${producto["precio"]} Bs | Stock: ${producto["stock"]}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // MODIFICAR
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => modificarProducto(id),
                            ),

                            // ELIMINAR LÓGICO
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => eliminarLogico(id),
                            ),

                            // ELIMINAR FÍSICO
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => eliminarFisico(id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
