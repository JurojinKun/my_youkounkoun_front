# My youkounkoun
Create new project flutter with already basics

## Getting Started
- Vous pouvez à tout moment faire dans votre terminal: flutter pub get afin de mettre à jour pubspec.lock

- Modifier tout les dp_app_flutter_boilerplate de ce projet par le nom du projet en question

- Pour renommer votre application, vous pouvez suivre les étapes suivantes:
    . Accédez à build.gradle dans le module d'application et renommez applicationId "com.company.name"
    . Accédez à Manifest.xml dans app/src/main et renommez package="com.company.name" et android:label="App Name"
    . Accédez à Manifest.xml dans app/src/debug et renommez package="com.company.name"
    . Accédez à Manifest.xml dans app/src/profile et renommez package="com.company.name"
    . Aller à app/src/main/kotlin/com/something/something/MainActivity.kt et renommer package="com.company.name"
    . Accédez à app/src/main/kotlin/chaque répertoire et renommez-le afin que la structure ressemble à app/src/main/kotlin/com/company/name/
    . Accédez à pubspec.yaml dans votre projet et remplacez name: something-le par name: name, exemple :- si le nom du package est com.abc.xyzlename: xyzlename
    . Accédez à chaque fichier Dart dans le dossier lib et renommez les importations avec le nom modifié.
    . Ouvrez XCode et ouvrez le fichier runner et cliquez sur Runner dans l'explorateur de projet.
    . Allez dans Général -> double-cliquez sur Bundle Identifier -> renommez-le en com.company.name
    . Accédez à Info.plist, cliquez sur le nom du bundle -> renommez-le en votre nom d'application.
    fermez tout -> allez dans votre projet flutter et exécutez cette commande dans le terminal flutter clean
    

- Modifier dans le fichier main.dart la ligne "title: 'AppFlutterBoilerplate'" par le titre que vous voulez pour votre application

- Si les différents dossiers de "lib" ne sont pas encore mis en place, petite mise au point des différents dossiers qui est fortement recommandé à mettre en place en terme de gestion de projet:
    - constants: le ou les fichiers qui pourront servir à garder toutes les constantes du projet
    - helpers: toutes les fonctions ou petites choses utiles à conserver pour être utiliser rapidement dans différents endroits de l'application
    - models: les différents modèles de données qui seront utiles pour la gestion de l'app
    - services: la gestion entre le back et le front => toute la gestion d'appel de ws, récupération de datas,... (utilisation de dio)
    - views : les différents screens qui feront l'app
    - widgets: les composants des screens qui pourraient revenir et être utilisés plusieurs fois dans différents screens de l'app
    - providers: pas obligatoirement présent au début d'un projet mais les providers vont gérés toute la partie state app management donc très utile pour la suite

- Pour ajouter dans la route de navigation:
    - router.dart 
    - voir si c'est un écran pour le côté auth ou le côté non auth afin de le mettre dans le bon generateRoute

- Pour mettre en place son propre launcher icon (icone de lancement):
    - aller dans pubspec.yaml
    - décommenter la partie "flutter_icons"
    - changer le contenu de image_path par votre icone
    - lancer dans un terminal les 2 commandes à la suite: flutter pub get puis flutter pub run flutter_launcher_icons:main
Bravo, si tout se passe bien votre icone de lancement est prête pour android&ios

- Pour mettre en place son propre splash screen:
    - aller dans pubspec.yaml
    - décommenter la partie flutter_native_splash
    - changer les contenus de image par votre splash screen
    - changer les couleurs de fond du splash screen
    - lancer dans un terminal la commande suivante: flutter pub run flutter_native_splash:create
    - si vous voulez préserver votre splash screen le tps que votre data se mette en place, vous pouvez suivre ceci:
        - importer le package flutter native splash dans les fichiers dédiés: import 'package:flutter_native_splash/flutter_native_splash.dart';
        - dans la fonction main dans main.dart juste avant la ligne runApp(MyApp(finalLocalStorage: localStorage)); ajouter la ligne suivante: FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
        - Lorsque la mise en place de la data est prête, vous pouvez ajouter cette ligne afin d'enlever le splash screen: FlutterNativeSplash.remove();
Bravo si tout se passe bien, votre splash screen est prêt pour android&ios

## Riverpod
- package flutter_riverpod
- afin de gérer toutes vos classes avec riverpod, vous pouvez les "extends" comme l'exemple ci-dessous:
class MyApp extends ConsumerStatefulWidget
class _MyAppState extends ConsumerState<MyApp>
Pour en savoir plus dans la mise en place de votre premier provider et les appels de celui-ci, vous pouvez lire la doc qui suit et notamment la partie "Migration" => "^0.14.0 vers ^1.0.0" ainsi que les exemples officiels:
https://riverpod.dev/fr/docs/getting_started

## Connectivity
- Mise en place de la détection de connectivité sur le device: stream subscription en écoute lorsque l'app est au premier plan ou en arrière-plan dans le main via le package connectivity_plus
- Logique riverpod qui change l'état de l'app lorsque s'il y a oui ou non une connectivité via un provider => providers/connectivity_provider.dart

## Loalizations
- Toute la mise en place du fichier de langue a été mise en place avec une langue: français & anglais
- pour ajouter des labels à votre app, il suffit d'ajouter ceux-ci dans les fichiers json dans le dossier lib/translations dans les langues correspondantes
- Si vous voulez ajouter une langue pour la localization:
    . dans le main, dans le MaterialApp, ajouter dans la section supportedLocales la langue que vous souhaitez avec le languageCode et si vous le souhaitez le countryCode
    . vous pouvez ajouter un fichier json dans le dossier translations pour la langue que vous souhaitez ajouter et le remplir avec les mêmes variables contenus dans les autres fichiers de langue
    . ajouter le nouveau fichier json dans le pubspec.yaml dans la section des assets avec le chemin vers ce fichier
    . attention à bien vérifier dans le fichier app_localizations.dart si vous devez rajouter de la logique pour votre ajout de langue

## Notifications
Vous pouvez suivre la mise en place des notifications push dans la doc suivante:
https://docs.google.com/document/d/1vUwTC1Sox5TzYvOAuDlU6OKJfLM6Cqzg

## Navigation
Pour le moment sur ce boilerplate, utilisation de la Navigation 2.0 avec 2 stacks de navigation distinctes (nav auth et non auth)
À voir sur plus long terme si ce système de navigation pose problème ou pas? Si oui, repasser à une Navigation 1.0 avec une seule stack de navigation