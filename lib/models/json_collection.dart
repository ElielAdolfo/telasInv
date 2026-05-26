class JsonCollection {
  final String name;
  final List<dynamic> data;

  JsonCollection({required this.name, required this.data});

  Map<String, dynamic> toJson() {
    return {'collection': name, 'data': data};
  }
}
