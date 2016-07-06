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

There are two docker image from the ALMANAC project

* [almanacproject/keypasspap](https://hub.docker.com/r/almanacproject/keypasspap/) the PAP interface
* [almanacproject/keypasspdp](https://hub.docker.com/r/almanacproject/keypasspdp/) the PDP interface

If you want to build your own images you can find a docker compose file under `./docker_ops/docker-compose.yml`, which which you can build and run your keypass instance.

## Build

To build the images you need to go to the folder `./docker_ops/` and run

```
./build
```

The `build` script first creates the JAR files for you and then creates certificates and random passwords which can be used by the docker images.

## Running the docker containers

You can start the containers with `docker-compose` by executing

```
docker-compose up
```

This starts the database under the name amdb.

The second container is the PAP with the name ampap and
the third container is the PDP with the name ampdp.
Both the ampap and the ampdp expose the port 8443.
For convince the ports are mapped to the host system the PAP is under port 8443 and the PDP is under port 8444 of the host.

## Testing the containers

The script `test` creates a simple policy at the pap and immediately queries the pdp for result. 

# Usage

This chapter is describes the use for the Docker containers, when started with the `run` script.

## Create a policy

```
curl -k -i -H "Accept: application/xml" -H "Content-type: application/xml" \
    -H "tenantHeader: AM-Service" \
    -X POST -d @src/test/resources/es/tid/fiware/iot/ac/xacml/policy01.xml \
    https://localhost:8443/pap/v1/subject/role12345
```

Response should be something similar to:

```
HTTP/1.1 201 Created
Date: Mon, 15 Sep 2014 20:02:35 GMT
Location: https://localhost:8443/pap/v1/subject/role12345/policy/policy01
Content-Type: application/xml
Content-Length: 0
```

## Retrieve a policy

```
curl -k -i -H "tenantHeader: myTenant" \
    https://localhost:8443/pap/v1/subject/role12345/policy/policy01
```

Response will be the previously uploaded policy.

## Evaluate XACML request

```
curl -k -i -H "Accept: application/xml" -H "Content-type: application/xml" \
    -H "tenantHeader: myTenant" \
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
