from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .neo4j_connection import Neo4jConnection
from django.conf import settings

driver = Neo4jConnection.get_driver()

def run_query(query, params=None):
    """Helper function to run Neo4j queries"""
    with driver.session() as session:
        result = session.run(query, params or {})
        return [record.data() for record in result]

@api_view(['GET', 'POST'])
def person_list(request):
    """List all persons or create a new person"""
    if request.method == 'GET':
        query = """
        MATCH (p:Person)
        RETURN ID(p) AS id, p.name AS name, p.born AS born
        ORDER BY p.name
        """
        persons = run_query(query)
        return Response(persons, status=status.HTTP_200_OK)
    
    elif request.method == 'POST':
        data = request.data
        name = data.get('name')
        born = data.get('born')
        
        if not name:
            return Response(
                {"error": "Name is required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        query = """
        CREATE (p:Person {
            name: $name,
            born: $born
        })
        RETURN ID(p) AS id, p.name AS name, p.born AS born
        """
        
        result = run_query(query, {"name": name, "born": born})
        if result:
            return Response(result[0], status=status.HTTP_201_CREATED)
        return Response(
            {"error": "Failed to create person"}, 
            status=status.HTTP_400_BAD_REQUEST
        )

@api_view(['GET', 'PATCH', 'DELETE'])
def person_detail(request, pk):
    """Retrieve, update or delete a person"""
    if request.method == 'GET':
        query = """
        MATCH (p:Person)
        WHERE ID(p) = $id
        RETURN ID(p) AS id, p.name AS name, p.born AS born
        """
        result = run_query(query, {"id": int(pk)})
        
        if result:
            return Response(result[0], status=status.HTTP_200_OK)
        return Response(
            {"error": "Person not found"}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    elif request.method == 'PATCH':
        data = request.data
        set_clauses = []
        params = {"id": int(pk)}
        
        if 'name' in data:
            set_clauses.append("p.name = $name")
            params['name'] = data['name']
        
        if 'born' in data:
            set_clauses.append("p.born = $born")
            params['born'] = data['born']
        
        if not set_clauses:
            return Response(
                {"error": "No fields to update"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        query = f"""
        MATCH (p:Person)
        WHERE ID(p) = $id
        SET {', '.join(set_clauses)}
        RETURN ID(p) AS id, p.name AS name, p.born AS born
        """
        
        result = run_query(query, params)
        if result:
            return Response(result[0], status=status.HTTP_200_OK)
        return Response(
            {"error": "Person not found"}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    elif request.method == 'DELETE':
        query = """
        MATCH (p:Person)
        WHERE ID(p) = $id
        DETACH DELETE p
        RETURN count(p) AS deleted
        """
        result = run_query(query, {"id": int(pk)})
        
        if result and result[0].get('deleted', 0) > 0:
            return Response(
                {"message": "Person deleted successfully"}, 
                status=status.HTTP_200_OK
            )
        return Response(
            {"error": "Person not found"}, 
            status=status.HTTP_404_NOT_FOUND
        )

