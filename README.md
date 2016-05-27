docker-discover is a service discovery container that leverages haproxy and etcd.  When running,
it sets up listeners for remote docker containers discovered via etcd.  It works in tandem with
docker-register.

Together, they implement [service discovery][2] for docker containers with a similar architecture
to [SmartStack][3].  docker-discovery is analagous to [synapse][4] in the SmartStack system.

See also [Docker Service Discovery Using Etcd and Haproxy][5]

### How it works

When running, the container will setup ports on the host that can be accessed from other locally
running containers.  For example, host port 5000 would forward requests to remote hosts running
containers that `EXPOSE` port 5000.  Each proxied service port is monitored with basic TCP health
checks and will be re-dispatched if backend container fails.  This ensure that backend containers
can be started and stopped as needed w/ minimal client impact.

The intent is that you would run this container on any host that has containers that need to call
remote services in your infrastructure.

From within a container on a host running docker-discover, they can reach remote containers by hitting
the docker bridge IP or the host IP and the corresponding `EXPOSE`ed port of the service.

### Usage

To run it:

    $ docker run -d --net host --name docker-discover -e ETCD_HOST=1.2.3.4:4001 -p 127.0.0.1:1936:1936 -t jwilder/docker-discover

Then start any containers that need to access remote containers.  You'll likely want to pass the host's
 IP or the docker bridge IP as an env variable to make it easy for call proxied services.

You can also access the remote containers directly from the host by sending requests to the
localhost:port.

### Stats Interface

The haproxy stats interface is exposed on port 1936.  Open your browser to `http://localhost:1936` to view it.

### Limitations

There are a few simplifications that were made:

* *TCP Proxy* - By default, each listener uses haproxy's `tcp` mode.
* *Round-Robin Load Balancing* - Multiple containers running on different hosts are load-balanced
using a round-robin strategy.  Stateful/sticky requests or master/slave type scenarios are not
currently supported.
* *Minimal haproxy config* - The haproxy template in place currently is pretty minimal and likely not ready for production use.  Please feel free to submit improvements.

[1]: https://github.com/jwilder/docker-gen
[2]: http://jasonwilder.com/blog/2014/02/04/service-discovery-in-the-cloud/
[3]: http://nerds.airbnb.com/smartstack-service-discovery-cloud/
[4]: https://github.com/airbnb/synapse
[5]: http://jasonwilder.com/blog/2014/07/15/docker-service-discovery/

### TODO

* Support http, udp proxying
* Support multiple ports
* Make ETCD prefix configurable
* Support other backends (consul, zookeeper, redis, etc.)

### License

MIT
