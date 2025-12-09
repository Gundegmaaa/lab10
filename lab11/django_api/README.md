# Django REST API for Neo4j Person CRUD

## Installation

1. Create and activate virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Update Neo4j connection settings in `movieapi/settings.py`:
   - Update `NEO4J_PASSWORD` with your Neo4j password

4. Run migrations (if needed):
```bash
python manage.py migrate
```

5. Start the development server:
```bash
python manage.py runserver
```

The API will be available at: http://127.0.0.1:8000/api/persons/

## API Endpoints

- `GET /api/persons/` - Get all persons
- `POST /api/persons/` - Create a new person
- `GET /api/persons/<id>/` - Get person by ID
- `PATCH /api/persons/<id>/` - Update person
- `DELETE /api/persons/<id>/` - Delete person

## Example Requests

### Create Person:
```bash
POST http://127.0.0.1:8000/api/persons/
Content-Type: application/json

{
  "name": "John Doe",
  "born": 1980
}
```

### Update Person:
```bash
PATCH http://127.0.0.1:8000/api/persons/1/
Content-Type: application/json

{
  "name": "Jane Doe",
  "born": 1985
}
```

