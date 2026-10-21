# FoodLink

A simple Flutter UI demo for a food donation app.

## Screens

- Welcome with Get Started and Log In.
- Donor, NGO, and Admin role selection.
- Login and signup form previews.
- Basic dashboards with sample donation and pickup cards.
- Add Donation form preview.

Buttons navigate between screens or show a preview message. Login and signup do
not check or create accounts. Donations and pickup requests are sample content;
forms do not save data or send requests.

## Project files

```text
lib/
  main.dart
  app.dart
  screens/
    welcome_screen.dart
    role_selection_screen.dart
    auth_screen.dart
    dashboard_screen.dart
    add_donation_screen.dart

test/
  widget_test.dart
```

`main.dart` starts the app. `app.dart` sets the green theme. Each screen uses
standard Flutter widgets and direct Navigator calls. The only screen state is
the selected role on the authentication preview.

The previous repositories, services, models, custom widget folders, and complex
auth/donor/NGO screens were removed. Flutter platform folders remain so the app
can still run on supported platforms. No backend or extra packages were added.

## Run

```sh
flutter run
```

## Check

```sh
flutter analyze
flutter test
```
