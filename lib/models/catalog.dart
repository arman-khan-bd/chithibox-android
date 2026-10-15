class EnvelopeItem {
  final String id;
  final String nameBn;
  final String nameEn;
  final String badge;
  final int price;
  final String category;
  final String descriptionBn;
  final String? waxText;
  final String? waxSubtext;

  EnvelopeItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.badge,
    required this.price,
    required this.category,
    required this.descriptionBn,
    this.waxText,
    this.waxSubtext,
  });

  factory EnvelopeItem.fromJson(Map<String, dynamic> json) {
    return EnvelopeItem(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      category: json['category']?.toString() ?? 'old',
      descriptionBn: json['descriptionBn']?.toString() ?? '',
      waxText: json['waxText']?.toString(),
      waxSubtext: json['waxSubtext']?.toString(),
    );
  }
}

class PaperItem {
  final String id;
  final String nameBn;
  final String nameEn;
  final String category;
  final String badge;
  final String descriptionBn;
  final String watermarkIcon;
  final bool ruledLines;

  PaperItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.category,
    required this.badge,
    required this.descriptionBn,
    required this.watermarkIcon,
    required this.ruledLines,
  });

  factory PaperItem.fromJson(Map<String, dynamic> json) {
    return PaperItem(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      category: json['category']?.toString() ?? 'old',
      badge: json['badge']?.toString() ?? '',
      descriptionBn: json['descriptionBn']?.toString() ?? '',
      watermarkIcon: json['watermarkIcon']?.toString() ?? '📜',
      ruledLines: json['ruledLines'] == true,
    );
  }
}

class StampItem {
  final String id;
  final String nameBn;
  final String nameEn;
  final String price;
  final String badge;
  final String descriptionBn;
  final String icon;
  final String yearBn;

  StampItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.price,
    required this.badge,
    required this.descriptionBn,
    required this.icon,
    required this.yearBn,
  });

  factory StampItem.fromJson(Map<String, dynamic> json) {
    return StampItem(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      descriptionBn: json['descriptionBn']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📮',
      yearBn: json['yearBn']?.toString() ?? '',
    );
  }
}

class WaxSealItem {
  final String id;
  final String nameBn;
  final String nameEn;
  final String badge;
  final String descriptionBn;
  final String icon;
  final String title;
  final String subtext;

  WaxSealItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.badge,
    required this.descriptionBn,
    required this.icon,
    required this.title,
    required this.subtext,
  });

  factory WaxSealItem.fromJson(Map<String, dynamic> json) {
    return WaxSealItem(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      descriptionBn: json['descriptionBn']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '💮',
      title: json['title']?.toString() ?? '',
      subtext: json['subtext']?.toString() ?? '',
    );
  }
}

class FontItem {
  final String id;
  final String nameBn;
  final String nameEn;
  final String family;
  final String badge;
  final String descriptionBn;

  FontItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.family,
    required this.badge,
    required this.descriptionBn,
  });

  factory FontItem.fromJson(Map<String, dynamic> json) {
    return FontItem(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      family: json['family']?.toString() ?? 'sans-serif',
      badge: json['badge']?.toString() ?? '',
      descriptionBn: json['descriptionBn']?.toString() ?? '',
    );
  }
}

class InkColorItem {
  final String id;
  final String nameBn;
  final String hex;
  final String badge;

  InkColorItem({
    required this.id,
    required this.nameBn,
    required this.hex,
    required this.badge,
  });

  factory InkColorItem.fromJson(Map<String, dynamic> json) {
    return InkColorItem(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? '',
      hex: json['hex']?.toString() ?? '#1e293b',
      badge: json['badge']?.toString() ?? '',
    );
  }
}

class CatalogModel {
  final List<EnvelopeItem> envelopes;
  final List<PaperItem> papers;
  final List<StampItem> stamps;
  final List<WaxSealItem> seals;
  final List<FontItem> fonts;
  final List<InkColorItem> inkColors;

  CatalogModel({
    required this.envelopes,
    required this.papers,
    required this.stamps,
    required this.seals,
    required this.fonts,
    required this.inkColors,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      envelopes: ((json['envelopes'] as List?) ?? [])
          .map((e) => EnvelopeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      papers: ((json['papers'] as List?) ?? [])
          .map((e) => PaperItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      stamps: ((json['stamps'] as List?) ?? [])
          .map((e) => StampItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      seals: ((json['seals'] as List?) ?? [])
          .map((e) => WaxSealItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      fonts: ((json['fonts'] as List?) ?? [])
          .map((e) => FontItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      inkColors: ((json['inkColors'] as List?) ?? [])
          .map((e) => InkColorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
