# Lab 12: GraphQL API with Flask and Neo4j

## Зорилго
GraphQL ашиглан Neo4j өгөгдлийн сангаас мэдээлэл авах.

## Суулгах заавар

### 1. Virtual Environment үүсгэх

```bash
cd lab12
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

### 2. Dependencies суулгах

```bash
pip install -r requirements.txt
```

### 3. Neo4j холболт тохируулах

`app.py` файлд Neo4j нууц үгээ засах:
```python
password = "12345678"  # Чиний Neo4j нууц үгээр солих
```

### 4. Сервер ажиллуулах

```bash
python app.py
```

Сервер `http://localhost:3000` дээр ажиллана.

## GraphQL Endpoint

- **GraphQL Endpoint**: `http://localhost:3000/graphql`
- **GraphiQL Interface**: `http://localhost:3000/graphql` (browser дээр нээх)

## Даалгаврууд

### Даалгавар 1: 2010 оноос хойш гарсан кинонууд

Postman дээр GraphQL query:

```graphql
query MoviesSince2010 {
  movies(year: 2010) {
    title
    released
  }
}
```

### Даалгавар 2: Movie болон People with ACTED_IN relationship

```graphql
query MoviesWithActors {
  movies {
    title
    tagline
    released
    actors {
      name
      born
    }
  }
}
```

Эсвэл зөвхөн people:

```graphql
query People {
  people {
    name
    born
  }
}
```

## Postman дээр ашиглах

1. Postman нээх
2. Шинэ request үүсгэх
3. Request type-ийг **POST** болгох
4. URL: `http://localhost:3000/graphql`
5. **Body** tab сонгох → **GraphQL** сонгох
6. Query хэсэгт GraphQL query бичих
7. **Send** товч дарах

## GraphQL Queries жишээ

### Бүх кинонууд:

```graphql
query {
  movies {
    title
    tagline
    released
  }
}
```

### Тодорхой кино:

```graphql
query {
  movie(title: "The Matrix") {
    title
    tagline
    released
    actors {
      name
      born
    }
  }
}
```

### Бүх хүмүүс:

```graphql
query {
  people {
    name
    born
  }
}
```

## Шалгах

1. Neo4j Desktop ажиллаж байгаа эсэхийг шалгах
2. Flask сервер ажиллаж байгаа эсэхийг шалгах
3. Browser дээр `http://localhost:3000/graphql` нээж GraphiQL interface-ийг ашиглах
4. Postman дээр GraphQL query илгээж турших

