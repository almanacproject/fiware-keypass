# FIWARE-KeyPass

Keypass is multi-tenant XACML server with PAP (Policy Administration Point) and
PDP (Policy Decision Point) capabilities.

KeyPass is based mainly on:

* [Balana](https://github.com/wso2/commons/tree/master/balana),
  a complete implementation of both XACML v2 and v3 specs
* [Dropwizard](http://dropwizard.io), a framework for developing
  high-performance, RESTful web services.

In this README document you will find how to get started with the application and
basic concepts. For a more detailed information you can read the following docs:

* [API](API.md)
* [Installation guide](INSTALL.md)
* [Troubleshooting](TROUBLESHOOTING.md)
* [Behaviour Tests](https://github.com/telefonicaid/fiware-keypass/tree/develop/src/behavior/README.md)

# Manual


##Build

Building requires Java 6+ and Maven 3.

The jar files can be build manually with.

```
mvn -f ../pom/pap/pom.xml clean package
mvn -f ../pom/pdp/pom.xml clean package
```

## Running

```
java -jar target/keypassPAP-<VERSION>.jar server conf/PAPconfig.yml
java -jar target/keypassPDP-<VERSION>.jar server conf/PDPconfig.yml
```

# Docker

Under the path `./docker_ops/` are three script to setup a docker instance of the KeyPass servers.

1. the `build` script creates the docker images.
1. the `run` script creates and runs the container
1. the `remove` script stops the containers and removes the images
1. test `test` script which creates a policy and sends two queries for this policy.

## Build

The docker images can be build with `./docker_ops/build` script and downloads the latest image for a mariadb container.
In the build the jar files for the docker images for the PDP and PAP are created.

The images have the names `keypasspap` and `keypasspdp`.

## Running the docker containers

The new images can be started with the `./docker_ops/run` script.

The `run` script creates

1. new users and passwords for the PAP and PDP in the database
1. self signed certificates for the PAP and PDP,
1. the configuration files for the PAP and PDP, and
1. create the public certificates of the self-signed certificates for the PAP and PDP under `./docker_ops/pub_certs/`.

After this initialisation three containers are started with the `docker run` command.
The first is the database with the name AMdb.
Since the database needs quite a lot of time to start, there is a time delay of 15 seconds before the other containers are started.

The second container is the PAP with the name AMpap and
the third container is the PDP with the name AMpdp.
Both containers expose the port 8443.
For convince the ports are mapped to the host system the PAP is under port 8443 and the PDP is under port 8444 of the host.

After the first use of the `run` script the containers can be manged with the usual docker commands (stop, start,...).

## Removing the containers

The `remove` script stops and removes the containers.
It was created so the result of the `run` script can be quickly removed.

For example with

```
./remove; ./run
```

## Testing the containers

The script `test` creates a simple policy at the pap and immediately queries the pdp for result. 

# Usage

This chapter is describes the use for the Docker containers, when started with the `run` script.

## Create a policy

```
curl -k -i -H "Accept: application/xml" -H "Content-type: application/xml" \
    -H "Fiware-Service: myTenant" \
    -X POST -d @src/test/resources/es/tid/fiware/iot/ac/xacml/policy01.xml \
    https://localhost:8443/pap/v1/subject/role12345
```

Response should be something like this:

```
HTTP/1.1 201 Created
Date: Mon, 15 Sep 2014 20:02:35 GMT
Location: https://localhost:8443/pap/v1/subject/role12345/policy/policy01
Content-Type: application/xml
Content-Length: 0
```

## Retrieve a policy

```
curl -k -i -H "Fiware-Service: myTenant" \
    https://localhost:8443/pap/v1/subject/role12345/policy/policy01
```

Response will be the previously uploaded policy.

## Evaluate XACML request

```
curl -k -i -H "Accept: application/xml" -H "Content-type: application/xml" \
    -H "Fiware-Service: myTenant" \
    -X POST -d @src/test/resources/es/tid/fiware/iot/ac/xacml/policy01_request01.xml \
    https://localhost:8444/pdp/v3
```
Response:

```
HTTP/1.1 200 OK
Date: Mon, 15 Sep 2014 20:10:45 GMT
Content-Type: application/xml
Transfer-Encoding: chunked

<Response xmlns="urn:oasis:names:tc:xacml:3.0:core:schema:wd-17"><Result><Decision>Permit</Decision><Status><StatusCode Value="urn:oasis:names:tc:xacml:1.0:status:ok"/></Status></Result></Response>
```
