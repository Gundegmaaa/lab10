from flask import Flask
from flask_cors import CORS
from flask_graphql import GraphQLView
from graphene import ObjectType, Schema, Field, List, Int, String
from neo4j import GraphDatabase

app = Flask(__name__)
CORS(app)

# Neo4j connection
uri = "neo4j://127.0.0.1:7687"
username = "neo4j"
password = "12345678"  # Change this to your Neo4j password

driver = GraphDatabase.driver(uri, auth=(username, password))

def run_query(query, params=None):
    """Helper function to run Neo4j queries"""
    with driver.session() as session:
        result = session.run(query, params or {})
        return [record.data() for record in result]


# GraphQL Types
class Person(ObjectType):
    name = String()
    born = Int()


class Movie(ObjectType):
    title = String()
    tagline = String()
    released = Int()
    actors = List(Person)

    def resolve_actors(self, info):
        """Resolve actors for a movie"""
        query = """
        MATCH (m:Movie {title: $title})<-[:ACTED_IN]-(a:Person)
        RETURN a.name AS name, a.born AS born
        ORDER BY a.name
        """
        result = run_query(query, {"title": self.title})
        return [Person(name=record.get("name"), born=record.get("born")) for record in result]


# GraphQL Queries
class Query(ObjectType):
    movies = List(Movie, year=Int(), title=String())
    people = List(Person, name=String())
    movie = Field(Movie, title=String())
    person = Field(Person, name=String())
    
    def resolve_movies(self, info, year=None, title=None):
        """Get all movies, optionally filtered by year or title"""
        if year is not None:
            query = """
            MATCH (m:Movie)
            WHERE m.released >= $year
            RETURN m.title AS title, m.tagline AS tagline, m.released AS released
            ORDER BY m.released DESC
            """
            result = run_query(query, {"year": year})
        elif title is not None:
            query = """
            MATCH (m:Movie {title: $title})
            RETURN m.title AS title, m.tagline AS tagline, m.released AS released
            """
            result = run_query(query, {"title": title})
        else:
            query = """
            MATCH (m:Movie)
            RETURN m.title AS title, m.tagline AS tagline, m.released AS released
            ORDER BY m.title
            """
            result = run_query(query)
        
        return [
            Movie(
                title=record.get("title"),
                tagline=record.get("tagline"),
                released=record.get("released")
            )
            for record in result
        ]
    
    def resolve_people(self, info, name=None):
        """Get all people, optionally filtered by name"""
        if name is not None:
            query = """
            MATCH (p:Person {name: $name})
            RETURN p.name AS name, p.born AS born
            """
            result = run_query(query, {"name": name})
        else:
            query = """
            MATCH (p:Person)
            RETURN p.name AS name, p.born AS born
            ORDER BY p.name
            """
            result = run_query(query)
        
        return [
            Person(name=record.get("name"), born=record.get("born"))
            for record in result
        ]
    
    def resolve_movie(self, info, title):
        """Get a single movie by title"""
        query = """
        MATCH (m:Movie {title: $title})
        RETURN m.title AS title, m.tagline AS tagline, m.released AS released
        """
        result = run_query(query, {"title": title})
        if result:
            record = result[0]
            return Movie(
                title=record.get("title"),
                tagline=record.get("tagline"),
                released=record.get("released")
            )
        return None
    
    def resolve_person(self, info, name):
        """Get a single person by name"""
        query = """
        MATCH (p:Person {name: $name})
        RETURN p.name AS name, p.born AS born
        """
        result = run_query(query, {"name": name})
        if result:
            record = result[0]
            return Person(name=record.get("name"), born=record.get("born"))
        return None


# Create GraphQL schema
schema = Schema(query=Query)

# Add GraphQL endpoint
app.add_url_rule(
    '/graphql',
    view_func=GraphQLView.as_view(
        'graphql',
        schema=schema,
        graphiql=True  # Enable GraphiQL interface for testing
    )
)


@app.route('/')
def index():
    return '''
    <h1>GraphQL API</h1>
    <p>GraphQL endpoint: <a href="/graphql">/graphql</a></p>
    <p>GraphiQL interface is enabled for testing.</p>
    '''


if __name__ == '__main__':
    app.run(port=3000, debug=True)

