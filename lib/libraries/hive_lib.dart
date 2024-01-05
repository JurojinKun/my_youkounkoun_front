import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

class HiveLib {
  static List<int> generateEncryptKeyHive(String key) {
    var keyEncode = utf8.encode(key);
    var bytes = sha256.convert(keyEncode).bytes;
    return bytes;
  }

  static Future<void> setDatasHive(bool encryptBox, String? encryptKey,
      String keyBox, String keyDatas, dynamic datas) async {
    Box? box;
    if (encryptBox) {
      var bytes = generateEncryptKeyHive(encryptKey!);
      box = await Hive.openBox(keyBox, encryptionCipher: HiveAesCipher(bytes));
    } else {
      box = await Hive.openBox(keyBox);
    }
    await box.put(keyDatas, datas);
    await box.close();
  }

  static Future<dynamic> getDatasHive(bool encryptBox, String? encryptKey,
      String keyBox, String keyDatas) async {
    Box? box;
    if (encryptBox) {
      var bytes = generateEncryptKeyHive(encryptKey!);
      box = await Hive.openBox(keyBox, encryptionCipher: HiveAesCipher(bytes));
    } else {
      box = await Hive.openBox(keyBox);
    }
    dynamic datas = box.get(keyDatas);
    await box.close();
    return datas;
  }

  static Future<void> deleteSpecificDatasHive(bool encryptBox,
      String? encryptKey, String keyBox, String keyDatas) async {
    Box? box;
    if (encryptBox) {
      var bytes = generateEncryptKeyHive(encryptKey!);
      box = await Hive.openBox(keyBox, encryptionCipher: HiveAesCipher(bytes));
    } else {
      box = await Hive.openBox(keyBox);
    }
    await box.delete(keyDatas);
    await box.close();
  }

  static Future<void> clearSpecificBoxHive(
      bool encryptBox, String? encryptKey, String keyBox) async {
    Box? box;
    if (encryptBox) {
      var bytes = generateEncryptKeyHive(encryptKey!);
      box = await Hive.openBox(keyBox, encryptionCipher: HiveAesCipher(bytes));
    } else {
      box = await Hive.openBox(keyBox);
    }
    await box.clear();
    await box.close();
  }

  static Future<void> deleteSpecificBoxHive(
      bool encryptBox, String? encryptKey, String keyBox) async {
    Box? box;
    if (encryptBox) {
      var bytes = generateEncryptKeyHive(encryptKey!);
      box = await Hive.openBox(keyBox, encryptionCipher: HiveAesCipher(bytes));
    } else {
      box = await Hive.openBox(keyBox);
    }
    await box.deleteFromDisk();
  }

  static Future<void> clearOrDeleteAllBoxesHive(
      bool deleteBoxes, List<String> keyBoxes) async {
    for (var keyBox in keyBoxes) {
      var box = await Hive.openBox(keyBox);
      if (deleteBoxes) {
        await box.deleteFromDisk();
      } else {
        await box.clear();
        await box.close();
      }
    }
  }

  static Future<void> clearOrDeleteAllEncryptBoxesHive(
      bool deleteBoxes, List<String> encryptKeys, List<String> keyBoxes) async {
    if (encryptKeys.length != keyBoxes.length) {
      throw ArgumentError(
          "Les listes 'encryptKeys' et 'keyBoxes' doivent avoir la même longueur.");
    }

    for (var i = 0; i < keyBoxes.length; i++) {
      var bytes = generateEncryptKeyHive(encryptKeys[i]);
      var box = await Hive.openBox(keyBoxes[i],
          encryptionCipher: HiveAesCipher(bytes));

      if (deleteBoxes) {
        await box.deleteFromDisk();
      } else {
        await box.clear();
        await box.close();
      }
    }
  }
}
