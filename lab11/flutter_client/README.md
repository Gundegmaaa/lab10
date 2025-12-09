# Flutter Person CRUD Client

## Setup Instructions

1. Make sure Flutter is installed on your system.

2. Navigate to the flutter_client directory:
```bash
cd flutter_client
```

3. Get dependencies:
```bash
flutter pub get
```

4. Make sure your Django API server is running on `http://127.0.0.1:8000`

5. Run the app:
```bash
flutter run
```

## Features

- **View all persons**: ListView displays all persons from the API
- **Add person**: FloatingActionButton opens a form to add a new person
- **Edit person**: Tap the edit icon to modify person information
- **Delete person**: Tap the delete icon to remove a person (with confirmation dialog)
- **Refresh**: Use the refresh button in the app bar to reload the list

## API Connection

The app connects to: `http://127.0.0.1:8000/api/persons/`

Make sure:
- Django API server is running
- CORS is enabled in Django settings
- Neo4j database is running and accessible

## Notes

- For Android/iOS testing, you may need to change the API URL from `127.0.0.1` to your actual machine IP address or use `10.0.2.2` for Android emulator.

