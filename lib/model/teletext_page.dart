class TeletextPage {
  final String key;
  final List subpages;

  bool hasSubpage () => subpages.isNotEmpty;

  const TeletextPage({
    required this.key,
    required this.subpages,
  });


  factory TeletextPage.fromJson(MapEntry<String, dynamic> json) {
    List subpages = json.value['subpages'] as List;

    // make "dummy page" in case there are no children like "A", "B..."
    if (subpages.isEmpty) {
      subpages.add("");
    }

    return TeletextPage(
      key: json.key,
      subpages: json.value['subpages'] as List,
    );
  }
}
