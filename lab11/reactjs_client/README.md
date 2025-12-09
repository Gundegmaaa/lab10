# ReactJS/Next.js Person CRUD Client

## Setup Instructions

1. Navigate to the reactjs_client directory:
```bash
cd reactjs_client
```

2. Install dependencies:
```bash
npm install
# or
yarn install
```

3. Make sure your Django API server is running on `http://127.0.0.1:8000`

4. Run the development server:
```bash
npm run dev
# or
yarn dev
```

5. Open [http://localhost:3000](http://localhost:3000) in your browser

## Features

- **View all persons**: Displays all persons in a card-based list
- **Add person**: Modal form to add a new person
- **Edit person**: Click Edit button to modify person information in a modal
- **Delete person**: Click Delete button to remove a person (with confirmation)
- **Refresh**: Button to reload the list from the API

## API Connection

The app connects to: `http://127.0.0.1:8000/api/persons/`

Make sure:
- Django API server is running
- CORS is enabled in Django settings
- Neo4j database is running and accessible

## Technologies Used

- Next.js 14
- React 18
- TypeScript
- Axios for HTTP requests
- CSS Modules for styling

