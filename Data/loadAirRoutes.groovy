graph = JanusGraphFactory.open('inmemory')

// Change the path below to point to wherever you put the graphml file
graph.io(graphml()).readGraph('/Users/ben/Documents/GitHub/graph/sample-data/air-routes-latest.graphml')
mgmt = graph.openManagement()

g=graph.traversal()
:set max-iteration 1000

println "Vertex Labels:"
mgmt.getVertexLabels()

println "Edge Labels:"
mgmt.getRelationTypes(EdgeLabel.class)

println "Property Keys:"
types = mgmt.getRelationTypes(PropertyKey.class)

println "Data Types and Cardinality of Properties:"
types.each{println "$it\t: " + mgmt.getPropertyKey("$it").dataType() + " " + mgmt.getPropertyKey("$it").cardinality()}
mgmt.commit()
