## Introduction

[OR2024-Hyrax](https://github.com/CottageLabs/or2024-hyrax) is an application based on [Hyrax 5.0](https://github.com/samvera/hyrax/releases/tag/hyrax-v5.0.1) stack by [Cottage Labs](https://cottagelabs.com/). It is built with Docker containers.

## Getting Started

Clone the repository with `git clone https://github.com/CottageLabs/or2024-hyrax.git`.

Ensure you have docker and docker-compose.

Open a console and try running `docker -h` and `docker-compose -h` to verify they are both accessible.

Create the environment file `.env`. You can start by copying the template file [.env.template.development](https://github.com/CottageLabs/or2024-hyrax/blob/master/.env.template.development) to `.env` and customizing the values to your setup. <br>
Note: For production environment, use .env.template as your template.

## Quick start
If you would like to do a test run of the system, start the docker containers
```bash
$ cd or2024-hyrax
$ docker-compose -f docker-compose.yml up -d
```
You should see the containers being built and the services start.

## Docker compose explained

There is `docker-compose` file provided in the repository, which build the containers running the services as shown above
* [docker-compose.yml](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml) is the main docker-compose file. It builds all the core servcies required to run the application


### Containers running in docker

* [Solr container](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml#L17) runs [SOLR](lucene.apache.org/solr/), an enterprise search server. 

  By default, this runs the SOLR service on port 8983 internally in docker. 
  http://solr:8983

* [db containers](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml#L42) running a postgres database for use by the Hyrax application (appdb). 

  By default, this runs the database service on port 5432 internally in docker.

* [redis container](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml#L119) running [redis](https://redis.io/), used by Hyrax to manage background tasks. 

  By default, this runs the redis service on port 6379 internally in docker.

* [app container](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml#L60) sets up the Hyrax application, which is then used by 2 services - web and workers.

  * [Web container](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml#L75) runs the application. 

    By default, this runs on port 3000 internally in docker.
    http://web:3000 

  *  [Workers container](https://github.com/CottageLabs/or2024-hyrax/blob/master/docker-compose.yml#L103) runs the background tasks, using [sidekiq](https://github.com/mperham/sidekiq) and redis. 

    * Hyrax processes long-running or particularly slow work in background jobs to speed up the web request/response cycle. When a user submits a file through a work (using the web or an import task), there a number of background jobs that are run, initilated by the hyrax actor stack, as explained [here](https://samvera.github.io/what-happens-deposit-2.0.html).

      You can monitor the background workers using the OR2024-Hyrax service at http://web:3000/sidekiq when logged in as an admin user. 

### Container volumes
The data for the application is stored in docker named volumes as specified by the compose files. These are:

```bash
$ docker volume list -f name=or2024
DRIVER    VOLUME NAME
local     or2024-hyrax_branding
local     or2024-hyrax_cache
local     or2024-hyrax_db
local     or2024-hyrax_derivatives
local     or2024-hyrax_file_uploads
local     or2024-hyrax_redis
local     or2024-hyrax_solr
local     or2024_branding
local     or2024_cache
local     or2024_db
local     or2024_derivatives
local     or2024_file_uploads
local     or2024_redis
local     or2024_solr
```

These will persist when the system is brought down and rebuilt. Deleting them will require importers etc. to run again.

## Running OR2024-Hyrax

* When running in production environment, 

   * Prepare your .env file using .env.template as the template. 


   * You need to use `docker-compose.yml` to build and run the containers. 

     You could setup an alias for docker-compose on your local machine, to ease typing

     ```bash
     alias hd='docker-compose -f docker-compose.yml'
     ```


* When running in development and test environment, 

   * Prepare your .env file using .env.template.development as the template. 


   * You need to use `docker-compose.yml`. to build and run your containers.

     You could setup an alias for docker-compose on your local machine, to ease typing

     ```bash
     alias hd='docker-compose -f docker-compose.yml'
     ```


* Prepare the file `hyrax/seed/setup.json` if you would like to create a set of users in the OR2024-Hyrax, as a part of start-up.

### Build the docker container

To start with, you would need to build the system, before running the services. To do this you need to issue the `build` command
```bash
$ hd build
```

### Start and run the services in the containers

To run the containers after build, issue the `up` command (-d means run as daemon, in the background):

```bash
$ hd up -d
```
The containers should all start and the services should be available in their end points as described above
* web server at http://localhost:3000 in development and https://domain-name in production

### Docker container status and logs

You can see the state of the containers with `hd ps`, and view logs e.g. for the web container using `hd logs web`

The services that you would need to monitor the logs for are docker mainly web and workers.

### Running services

  * Solr container will run the Solr service, which will be available in port 8983 at  http://localhost:8983/solr
  * The web container runs the OR2024-Hyrax service, which will be available in port 3000 at http://localhost:3000

### Using OR2024-Hyrax

To use the OR2024-Hyrax application on http://localhost:3000, you would need to do the following

1.  [Add passwords for the system users](#setting-a-password-for-the-system-users), or assign the role admin to a user who has signed in through Shibboleth, or register an user with role admin (see [wiki](https://gitlab.ruhr-uni-bochum.de/FDM/rdm-system/antleaf-projectmanagement/-/wikis/Development-notes/Create-users-from-the-rails-console)), so they can login.
2.  Setup the [Default workflow](https://samvera.atlassian.net/wiki/spaces/samvera/pages/2224849295/Workflow+and+Mediated+Deposit), to submit a dataset.
3.  Setup the [Custom workflow](https://samvera.atlassian.net/wiki/spaces/samvera/pages/2224849295/Workflow+and+Mediated+Deposit) to submit an experiment.

### Stop the services
You could stop the container using `hd stop`.

This will just stop all of the running containers created by `hd up`

Any background jobs running in the workers container and not having completed will fail, and will be re-tried when the container is restarted.

To gracefully shutdown the service, before stopping, you could make sure 

* There are no background jobs running. 
  * If there are any running jobs and you don't want to wait, you can kill the job. The job will move to the dead tab, from where you can retry later, after restarting the service.
* There is no Create, Update and Delete activity happening in OR2024-Hyrax

### To deploy an update of the code

similar to the steps described above, to deploy an update of the code

 * Checkout the latest code from github

 * Stop the containers. To deploy an update of the code, you likely want to use 

   ``` 
   hd down
   ```

   This will stop containers and remove

   * Containers for services defined in the Compose file
   * Networks defined in the networks section of the Compose file
   * The default network, if one is used

   Networks and volumes defined as external are not removed. Named volumes are not removed.

* Build the system

  ```
  hd build
  ```

* Start the containers

  ```
  hd up -d
  ```

* Check all the containers have started and the status of the web service with the logs

  ```
  hd ps
  hd logs -f web
  ```

### Setup of OR2024-Hyrax at startup

The OR2024-Hyrax web container is the main entry point of the OR2024-Hyrax application, with which users interact.

At startup, the web container runs [docker-entrypoint.sh](https://github.com/CottageLabs/or2024-hyrax/blob/master/hyrax/docker-entrypoint.sh). This script does the following tasks 

#### 1. Initial checks

* Creates the log folder if it doesn't exist
* Checks the bundle (and installs It in development)
* Does the database migration and setup
* Checks Solr is running (waits 15 seconds if needed)

#### 2. System users

OR2024-Hyrax creates system users if they don't exist

* System administrator - the email id of the user is defined in the .env file as `SYSTEM_ADMINISTRATOR`

  ##### Setting a password for the system users

  The system users are created with a random password. If you need to login as these users, you need to change the password from the rails console (once the web container is up and running)

  ```
  docker exec -it or2024-hyrax-web-1 /bin/bash
  rails c
  u = User.find_by(email: ENV['SYSTEM_ADMINISTRATOR'])
  u.password = <some password>
  u.save
  ```

#### 3. Loads workflows, create default admin sets and collection types

* Loads the default workflows 
* Creates the default collection types and admin sets (Hyrax administrative task)
* Setup the participants, visibility and workflow for each admin set

Creates users defined in the file `hyrax/seed/setup.json`, if they haven't already been created.

#### 4. Create users during start-up from `setup.json`

OR2024-Hyrax uses the file `hyrax/seed/setup.json` to create a set of users during first startup, if the file exists. 

If you would like to create users during startup, 

* Copy the file in `hyrax/seed/setup.json.template` to `hyrax/seed/setup.json`

* Modify `hyrax/seed/setup.json` so it has the list of users to create / update.

**Note**: The file `hyrax/seed/setup.json` needs to exist before running docker build, for users to be created at start-up.

#### 5. Starts the rails server

### Some example docker commands and usage:

[Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)

```bash
# Bring the whole application up to run in the background, building the containers
hd up -d --build

# Stop the container
hd stop

# Halt the system
hd down

# Re-create the web container without affecting the rest of the system (and run in the background with -d)
hd up -d --build --no-deps --force-recreate web

# View the logs for the web application container
hd logs web

# Create a log dump file
hd logs web | tee web_logs_`date --iso-8601`
# (writes to e.g. web_logs_2022-02-14)

# View all running containers
hd ps     

# Using its container name, you can run a shell in a container to view or make changes directly
docker exec -it or2024-Hyrax-web-1 /bin/bash
```

## Backups

There is [docker documentation](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes) advising how to back up volumes and their data. Docker suggests mounting the volumes in a container, creating a tar of the contents of the volume in a backup location and restoring them. 

It is also possible to stop the containers, copy all of the named volumes in /var/lib/docker/volumes and start the containers. To use the backup, copy the volumes back into /var/lib/docker/volumes.




