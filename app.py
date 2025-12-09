from flask import Flask, request, jsonify
from neo4j import GraphDatabase

app = Flask(__name__)

# ---- Neo4j connection ----
uri = "neo4j://127.0.0.1:7687"
username = "neo4j"
password = "12345678"   # Чиний өөрийн Password-г бичнэ

driver = GraphDatabase.driver(uri, auth=(username, password))

# ---------------------------
# Helpers
# ---------------------------

def run_query(query, params=None):
    with driver.session() as session:
        return session.run(query, params).data()

# ===========================
#        API ROUTES
# ===========================

# 1) GET ALL MOVIES
@app.get("/api/v1/movies")
def get_movies():
    query = """
    MATCH (m:Movie)
    RETURN ID(m) AS id, m.title AS title, m.released AS released, m.tagline AS tagline
    """
    with driver.session() as session:
        result = session.run(query)
        movies = []

        for record in result:
            movies.append({
                "id": record["id"],
                "title": record["title"],
                "released": record["released"],
                "tagline": record["tagline"]
            })

        return movies


# 2) GET MOVIE BY ID
@app.get("/api/v1/movies/<int:movie_id>")
def get_movie_by_id(movie_id):
    query = """
    MATCH (m:Movie)
    WHERE ID(m) = $movie_id
    RETURN ID(m) AS id, m.title AS title, m.released AS released, m.tagline AS tagline
    """
    with driver.session() as session:
        result = session.run(query, movie_id=movie_id)
        record = result.single()

        if record:
            return {
                "id": record["id"],
                "title": record["title"],
                "released": record["released"],
                "tagline": record["tagline"]
            }
        else:
            return {"error": "Movie not found"}, 404


# 3) CREATE MOVIE
@app.route("/api/v1/movies", methods=["POST"])
def create_movie():
    data = request.get_json()

    query = """
    CREATE (m:Movie {
        title: $title,
        released: $released,
        tagline: $tagline
    })
    RETURN ID(m) AS id, m.title AS title, m.released AS released, m.tagline AS tagline
    """

    result = run_query(query, data)
    return jsonify(result[0]), 201


# 4) UPDATE (PATCH)
@app.route("/api/v1/movies/<int:id>", methods=["PATCH"])
def update_movie(id):
    data = request.get_json()

    # динамик SET clause
    set_clause = ", ".join([f"m.{key} = ${key}" for key in data.keys()])

    query = f"""
    MATCH (m:Movie)
    WHERE ID(m) = $id
    SET {set_clause}
    RETURN ID(m) AS id, m.title AS title, m.released AS released, m.tagline AS tagline
    """

    params = {"id": id}
    params.update(data)

    result = run_query(query, params)

    if not result:
        return jsonify({"message": "Movie not found"}), 404

    return jsonify(result[0]), 200



@app.route("/api/v1/movies/<int:id>", methods=["DELETE"])
def delete_movie(id):
    query = """
    MATCH (m:Movie)
    WHERE ID(m) = $id
    DETACH DELETE m
    """
    run_query(query, {"id": id})
    return jsonify({"message": "Movie deleted"}), 200


# ===========================
#        START SERVER
# ===========================
if __name__ == "__main__":
    app.run(port=5000, debug=True)
