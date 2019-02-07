# marvel_graph
The Marvel Universe in agensgraph

## require 
* agensgraph

## use examples

```
agens -f load.cql
```

### Data Import

#### unzip dataset files.
unzip files into /path/to/
in my case, path is /home/agens/marvel_universe

#### import query
##### scripts using agens cli command.
```sql
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

```
##### Result
```bash
agens=# 
agens=# create graph marvel_graph;
CREATE GRAPH
agens=# set graph_path = marvel_graph;
SET
agens=# LOAD FROM nodes AS source 
agens-# WITH   { name : to_jsonb( source.node ), type : to_jsonb( source.type ) } as nodes 
agens-# WHERE nodes.type = 'hero'
agens-# CREATE (a:hero {name: nodes.name } )
agens-# ;
GRAPH WRITE (INSERT VERTEX 6439, INSERT EDGE 0)
agens=# LOAD FROM nodes AS source 
agens-# WITH   { title : to_jsonb( source.node ), type : to_jsonb( source.type ) } as nodes 
agens-# WHERE nodes.type = 'comic'
agens-# CREATE (a:comic { title: nodes.title } )
agens-# ;
GRAPH WRITE (INSERT VERTEX 12651, INSERT EDGE 0)
agens=# LOAD FROM edges AS source 
agens-# MATCH (h:hero {name : to_jsonb(source.hero) })
agens-# MATCH (c:comic {title : to_jsonb(source.comic) })
agens-# CREATE (h)-[:appered_in]->(c)
agens-# ;
GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 94527)
agens=# 
agens=# CREATE ELABEL KNOWS;
CREATE ELABEL
agens=# LOAD FROM hero_network AS source 
agens-# MATCH (h1:hero {name : to_jsonb(source.hero1) })
agens-# MATCH (h2:hero {name : to_jsonb(source.hero2) })
agens-# MERGE (h1)-[:knows]->(h2)
agens-# ;
GRAPH WRITE (INSERT VERTEX 0, INSERT EDGE 183645)
agens=# 
agens=# MATCH (a:hero )-[e:knows]->(b:hero)
agens-# WHERE a.name = 'CAPTAIN AMERICA'
agens-# RETURN a.name, label(e), b.name
agens-# LIMIT 20
agens-# ;
       name        |  label  |          name          
-------------------+---------+------------------------
 "CAPTAIN AMERICA" | "knows" | "3-D MAN/CHARLES CHAN"
 "CAPTAIN AMERICA" | "knows" | "ABOMINATION/EMIL BLO"
 "CAPTAIN AMERICA" | "knows" | "ABSORBING MAN/CARL C"
 "CAPTAIN AMERICA" | "knows" | "ACHEBE, REVEREND DOC"
 "CAPTAIN AMERICA" | "knows" | "ACHILLES II/HELMUT"
 "CAPTAIN AMERICA" | "knows" | "ADAMS, CINDY"
 "CAPTAIN AMERICA" | "knows" | "ADAMS, NICOLE NIKKI"
 "CAPTAIN AMERICA" | "knows" | "AGAMEMNON III/"
 "CAPTAIN AMERICA" | "knows" | "AGENT AXIS/"
 "CAPTAIN AMERICA" | "knows" | "AKUTAGAWA, OSAMU"
 "CAPTAIN AMERICA" | "knows" | "ALANYA"
 "CAPTAIN AMERICA" | "knows" | "ALDEN, PROF. MEREDIT"
 "CAPTAIN AMERICA" | "knows" | "ALEXANDER, CARRIE"
 "CAPTAIN AMERICA" | "knows" | "ALVAREZ, FELIX"
 "CAPTAIN AMERICA" | "knows" | "AMERICAN EAGLE III/J"
 "CAPTAIN AMERICA" | "knows" | "AMERICOP/"
 "CAPTAIN AMERICA" | "knows" | "AMPHIBIAN/KINGLEY RI"
 "CAPTAIN AMERICA" | "knows" | "ANACONDA/BLANCHE SIT"
 "CAPTAIN AMERICA" | "knows" | "ANELLE"
 "CAPTAIN AMERICA" | "knows" | "ANGEL DOPPELGANGER"
(20 rows)

```
