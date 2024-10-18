## Ikony aplikace

Pro změnu hlavní ikony aplikace nahraďte obrázky v adresáři [/assets/images/icon/](/assets/images/icon/). A spusťte příkaz:

```sh
dart run icons_launcher:create
```

A nezapomeňte pak provést commit & push.

## Název aplikace
```sh
dart run rename_app:main all="Český Teletext"
```

## Release aplikace
```sh
flutter build appbundle
```
