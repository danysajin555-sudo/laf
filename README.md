# Campus Lost & Found (Flutter)

## Setup
1. Create a fresh project:  `flutter create campus_lost_found`
2. Replace its `pubspec.yaml` and `lib/` folder with the ones here.
3. `flutter pub get`
4. `flutter run`

## Features
- Report lost or found items (name, category, description, place, date, contact)
- Tabs: All / Lost / Found
- Search + category filter
- Detail page with copy-contact, mark resolved, delete
- Data saved on-device with shared_preferences

## Ideas to extend
- Firebase (Auth + Firestore) so all students share one feed (edit only lib/services/item_repository.dart)
- Photos via image_picker + Firebase Storage
- Push notifications when a matching item is posted
