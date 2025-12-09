class Category {
  final String id;
  final String name;
  final String thumbnail;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['idCategory'] as String,
    name: j['strCategory'] as String,
    thumbnail: j['strCategoryThumb'] as String,
    description: j['strCategoryDescription'] as String,
  );
}
