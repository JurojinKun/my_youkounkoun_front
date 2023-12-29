class IconsAppModel {
  String asset;
  String name;

  IconsAppModel(
      {required this.asset, required this.name});

  IconsAppModel.fromJSON(Map<String, dynamic> jsonMap)
      : asset = jsonMap['asset'] ?? "",
        name = jsonMap['name'] ?? "";

  IconsAppModel copy() {
    return IconsAppModel(
        asset: asset, name: name);
  }
}