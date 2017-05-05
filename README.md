Formicarium
===========

Development environment for AlienAntFarm. Based on docker-compose, provides
utilities to set up a base architecture.

Getting Started
---------------

Get `make`, `docker` and `docker-compose`, then build the environment up by typing:

```
# init the dev env
make init
# build containers and bring everything up
docker-compose up
```

Tips
----

You can connect to the database by running the following command when all
containers are up:

```
docker exec -ti alienantfarm_hatchery psql -h hatchery -U hatchery
```
