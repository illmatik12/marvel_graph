CREATE EXTENSION file_fdw;
CREATE SERVER import_server FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE nodes
(
node TEXT,
type TEXT
)
SERVER import_server
OPTIONS( FORMAT 'csv', HEADER 'true', FILENAME '/home/agens/marvel_universe/nodes.csv', delimiter ',');

CREATE FOREIGN TABLE hero_network
(
hero1 TEXT,
hero2 TEXT
)
SERVER import_server
OPTIONS( FORMAT 'csv', HEADER 'true', FILENAME '/home/agens/marvel_universe/hero-network.csv', delimiter ',');

CREATE FOREIGN TABLE edges
(
hero TEXT,
comic TEXT
)
SERVER import_server
OPTIONS( FORMAT 'csv', HEADER 'true', FILENAME '/home/agens/marvel_universe/edges.csv', delimiter ',');


create graph marvel_graph;

set graph_path = marvel_graph;

# hero vertex create 
LOAD FROM nodes AS source 
WITH   { name : to_jsonb( source.node ), type : to_jsonb( source.type ) } as nodes 
WHERE nodes.type = 'hero'
CREATE (a:hero {name: nodes.name } )
;

# comic vertex create 
LOAD FROM nodes AS source 
WITH   { title : to_jsonb( source.node ), type : to_jsonb( source.type ) } as nodes 
WHERE nodes.type = 'comic'
CREATE (a:comic { title: nodes.title } )
;

# appered_in edge create 
LOAD FROM edges AS source 
MATCH (h:hero {name : to_jsonb(source.hero) })
MATCH (c:comic {title : to_jsonb(source.comic) })
CREATE (h)-[:appered_in]->(c)
;

# knows edge create 
CREATE ELABEL KNOWS;
LOAD FROM hero_network AS source 
MATCH (h1:hero {name : to_jsonb(source.hero1) })
MATCH (h2:hero {name : to_jsonb(source.hero2) })
MERGE (h1)-[:knows]->(h2)
;

# check import result
MATCH (a:hero )-[e:knows]->(b:hero)
WHERE a.name = 'CAPTAIN AMERICA'
RETURN * 
LIMIT 20
;

