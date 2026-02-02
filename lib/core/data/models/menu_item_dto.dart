class MenuItemDto {
  final int id;
  final String key;
  final String titleEn;
  final String titleFa;
  final String? titleCkb;
  final String url;
  final String icon;
  final String color;
  final int order;

  MenuItemDto({
    required this.id,
    required this.key,
    required this.titleEn,
    required this.titleFa,
    this.titleCkb,
    required this.url,
    required this.icon,
    required this.color,
    required this.order,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    return MenuItemDto(
      id: json['id'] ?? json['Id'] ?? 0,
      key: json['key'] ?? json['Key'] ?? "",
      titleEn: json['titleEn'] ?? json['TitleEn'] ?? "",
      titleFa: json['titleFa'] ?? json['TitleFa'] ?? "",
      titleCkb: json['titleCkb'] ?? json['TitleCkb'],
      url: json['url'] ?? json['Url'] ?? "",
      icon: json['icon'] ?? json['Icon'] ?? "language",
      color: json['color'] ?? json['Color'] ?? "#808080",
      order: json['order'] ?? json['Order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'titleEn': titleEn,
    'titleFa': titleFa,
    'titleCkb': titleCkb,
    'url': url,
    'icon': icon,
    'color': color,
    'order': order,
  };
}