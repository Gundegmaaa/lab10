# Lab 11: CRUD Operations with Flutter and ReactJS Clients

This lab implements CRUD operations for the Person model using Django REST API with Neo4j database, along with Flutter and ReactJS clients.

## Project Structure

```
lab11/
├── django_api/          # Django REST API backend
├── flutter_client/      # Flutter mobile client
└── reactjs_client/      # Next.js/React web client
```

## Setup Instructions

### 1. Neo4j Database

Make sure Neo4j is running and accessible at `neo4j://127.0.0.1:7687`

### 2. Django REST API

```bash
cd django_api

# Create virtual environment (if needed)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Update Neo4j password in movieapi/settings.py
# Change NEO4J_PASSWORD = "12345678" to your password

# Run migrations (if needed)
python manage.py migrate

# Start the server
python manage.py runserver
```

The API will be available at: http://127.0.0.1:8000/api/persons/

### 3. Flutter Client

```bash
cd flutter_client

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 4. ReactJS Client

```bash
cd reactjs_client

# Install dependencies
npm install

# Run development server
npm run dev
```

Open http://localhost:3000 in your browser

## API Endpoints

- `GET /api/persons/` - Get all persons
- `POST /api/persons/` - Create a new person
- `GET /api/persons/<id>/` - Get person by ID
- `PATCH /api/persons/<id>/` - Update person
- `DELETE /api/persons/<id>/` - Delete person

## Testing

1. Start Neo4j database
2. Start Django API server
3. Test API using Postman or curl
4. Test Flutter client
5. Test ReactJS client
6. Verify changes in Neo4j Browser

## Notes

- Make sure CORS is enabled in Django settings (already configured)
- Update Neo4j connection credentials in Django settings
- For mobile testing, you may need to change API URLs to use your machine's IP address

