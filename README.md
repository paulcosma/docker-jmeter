# Jenkins Docker Template with JMeter

Jenkins SSH slave Docker template with JMeter.


## Getting Started

Run Docker container with:
```sh
docker run paulcosma/docker-jmeter "<public key>"
```


### Prerequisites

What things you need to install the software and how to install them

- [sshd server](https://linux.die.net/man/8/sshd)
- [Java8 JDK or higher](https://www.java.com/en/download/)
- [Jmeter ](https://jmeter.apache.org/download_jmeter.cgi)

## Deployment

## Create Master JMeter Container and start it
 
```sh
docker image build -f jmeter.Dockerfile --target jmeter-master -t jmeter-master .
docker stop jmeter-master || true && docker rm jmeter-master || true
docker container run -dit --name jmeter-master -p 60000:60000 -v "$(pwd)":/projects jmeter-master /bin/bash
```

## Create Slave JMeter Containers
 
```sh
docker image build -f jmeter.Dockerfile --target jmeter-slave -t jmeter-slave .
docker container run -dit --name jmeter-slave-01 -p 1099:1099 -p 50000:50000 -v "$(pwd)":/projects jmeter-slave  /bin/bash
docker container run -dit --name jmeter-slave-02 -p 1099:1099 -p 50000:50000 -v "$(pwd)":/projects jmeter-slave /bin/bash
```

## Run JMeter tests
 
```sh
docker exec jmeter-master jmeter -n -t /projects/jmeterTest.jmx -Jvu=$vu -Jramp=$ramp -Jduration=$duration -l /projects/jmeterTest.jtl -j /projects/jmeterTest.log
```

## Get the list of ip addresses for running containers.
 
```sh
docker inspect --format '{{ .Name }} => {{ .NetworkSettings.IPAddress }}' $(sudo docker ps -a -q)
```

## Run test distributed using docker slave containers
Append slaves IPs with -R

```sh
docker exec -it jmeter-master bash
jmeter -n -t /projects/jmeterTest.jmx -l /projects/jmeterTest.jmx_results.jtl -R172.17.0.5,172.17.0.6,172.17.0.7
```

## Generate HTML Report

```sh
docker exec jmeter-master /bin/sh -c "rm -Rf /projects/results"
docker exec jmeter-master jmeter -g /projects/jmeterTest.jtl -o /projects/results/
```
