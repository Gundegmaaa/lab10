# GraphQL Query Examples

## Даалгавар 3: 2010 оноос хойш гарсан бүх киноны гарчиг, гарсан оныг JSON хэлбэрээр харуулах

Postman дээр дараах query ашиглах:

```graphql
query MoviesSince2010 {
  movies(year: 2010) {
    title
    released
  }
}
```

## Даалгавар 4: Movie болон People-ийг ACTED_IN холбоосоор харуулах

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

## Бусад жишээ queries

### Бүх кинонууд:

```graphql
query AllMovies {
  movies {
    title
    tagline
    released
  }
}
```

### Тодорхой кино actor-уудтай:

```graphql
query MovieWithActors {
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
query AllPeople {
  people {
    name
    born
  }
```

### Тодорхой хүн:

```graphql
query Person {
  person(name: "Keanu Reeves") {
    name
    born
  }
}
```

