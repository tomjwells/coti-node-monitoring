# coti-node-monitoring

<h1 align="center">Coti Node Monitoring</h1>
<p align="center">An easy method to configure public and private monitoring for Coti nodes. This setup is compatible with nodes installed with Systemd or Docker.</p>

<p align="center">
	<a href="https://github.com/tj-wells/coti-node-monitoring"><img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/tj-wells/coti-node-monitoring"></a>
    <a href="https://twitter.com/intent/tweet?text=I%20just%20installed%20%24COTI%20node%20monitoring%20with%20%40tomjwells%27%20Docker%20installation%20method.%20It%20worked%20like%20a%20charm%21%20and%20looks%20great%0A%0A%F0%9F%94%A5%0A%0Ahttps%3A%2F%2Fgithub.com%2Ftj-wells%2Fcoti-node-monitoring%0A%0A%23COTI%20%24DJED%20%24SHEN%20%20"><img src="https://randojs.com/images/tweetShield.svg" alt="Tweet" height="20"/></a>
</p><br/>

<p align="center"><a href="https://public.testnet.atomnode.tomoswells.com"><img src="https://media.discordapp.net/attachments/995792094088155227/1070497353968128041/Screenshot_2023-02-02_at_00.14.12.png?width=1493&height=825" width="100%" /></a></p><br/>

[Click to see a live example of a dashboard produced from this setup](https://public.testnet.atomnode.tomoswells.com).

This method provides:

- A <a href="https://github.com/grafana/grafana" target="_blank">Grafana</a> dashboard visualisation system
- Automatic SSL certificate management when needed
- Server monitoring and health statistics with <a href="https://prometheus.io/docs/introduction/overview/" target="_blank">Prometheus</a>
- Log tracking and querying with <a href="https://github.com/grafana/loki" target="_blank">Loki</a>

# Installation Instructions

This installation guide produces working setups for nodes installed both with systemd (a.k.a. <a href="https://cotidocs.geordier.co.uk/">GeordieR's installation scripts</a>) and with docker (for example <a href="https://github.com/tj-wells/coti-node" target="_blank">this Coti-Docker installation guide</a>), although the instructions for each installation type differ at certain points.

If `docker` and `docker-compose` are not already installed on your system, you will need to run the following commands to install `docker` and `docker-compose`:

```
sudo su
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
curl -L https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
```

Check whether the installations were successful using

```
docker --version
docker-compose --version
```

## DNS Settings (Docker installated nodes only)

For users whose nodes are installed with Docker, the monitoring system is set up to be accessed from the url `https://monitoring.<your-node-url>`. If you have not set up a subdomain record with your DNS provider, it is likely you will need to do this to make that url accessible.

To do this, you can either add a wildcard subdomain (`*`), or the specific subdomain you intend to set up (`monitoring.`). In my case I went with a wildcard subdomain, and my working DNS configuration looks like

![Wildcard subdomain example](https://media.discordapp.net/attachments/995792094088155227/1070766780181659668/Screenshot_2023-02-02_at_18.04.48.png)

## 1. Clone the Repository

To keep things organized, I suggest having your Coti node located under the directory `~/coti-node`. We will install the monitoring setup alongside that directory, under `~/coti-node-monitoring`. From your home directory, run

```
git clone https://github.com/tj-wells/coti-node-monitoring.git && cd coti-node-monitoring
```

## 2. Create a `.env` File

The `.env` file defines important environment variables used to set up the monitoring. Create a `.env` file in the `coti-node-monitoring` directory and enter your environment variables in the following format:

```.env
SERVERNAME="<your-node-domain.tld>"
GRAFANA_USERNAME="<Enter a username here>"
GRAFANA_PASSWORD="<Enter a password here>"
```

where

- `SERVERNAME` is the web address of your node, excluding `http(s)://` and `www.`, for example `subdomain.your-node-domain.tld`,
- `GRAFANA_USERNAME` is the username you wish to use for logging in to Grafana, and,
- `GRAFANA_PASSWORD` is the password you wish to use for logging in to Grafana.

Feel free to make up your own username, or you can use your email associated with your Coti node. For the password, either choose your own or use `tr -dc A-Za-z0-9 </dev/urandom | head -c 64` to generate one from a shell.

# 🏃 Running the Monitoring Stack

If you followed the <a href="https://github.com/tj-wells/coti-node" target="_blank">Coti-Docker installation guide</a>, you will already have a network called `gateway` running. You can check the Docker networks with `docker network ls`. If your node is running with systemd, or the network was not created somehow, you can create the `gateway` network with

```
docker network create --driver=bridge --attachable --internal=false gateway
```

Check whether the Docker network has been created with `docker network ls`. If you see the `gateway` network in the output, then you are ready to continue.

## Run the Monitoring Stack (Docker Installations)

Now you are ready to run the monitoring stack! If your node is installed with Docker, run

```
docker-compose up
```

This pulls the monitoring software for you and launches it once it is downloaded. If everything goes successfully, you are done.

## Run the Monitoring Stack (Systemd Installations)

First we need to modify the web server configuration. I have included a script which makes the necessary changes for you. Make sure you are logged in as the root user with `sudo su`. Then, the script can be run with

```
./configure-webserver.sh
```

Now you are ready to run the monitoring stack! If your node is running with systemd, run

```
docker-compose -f docker-compose-systemd.yml up
```

This pulls the monitoring software for you and launches it once it is downloaded. If everything goes successfully, you are done.

## Logging in to Grafana

Grafana usually takes between 10-30 seconds to become ready, so after some seconds, navigate in your browser to `monitoring.<your-node-url>` (Docker installs) or `<your-node-url>/monitoring` (Systemd installs). If everything is working, you will see the Grafana sign-in page:

<img src="https://media.discordapp.net/attachments/995792094088155227/1070504105056948244/Screenshot_2023-02-02_at_00.40.57.png?width=1445&height=825"/>

Use the sign in credentials you set in the `.env` file, `GRAFANA_USERNAME` and `GRAFANA_PASSWORD`, to log in.

If you see the following welcome screen:
<img src="https://media.discordapp.net/attachments/995792094088155227/1070504686387478598/Screenshot_2023-02-02_at_00.43.14.png?width=1802&height=825"/>
then congrats, you did it!

🎉

# Using Grafana

I wish to cover some of the features that come out-of-the-box with this installation method. These could be improved and extended further over time and I would welcome improvements and suggestions from others.

Out of the box features

- Dashboards:
  - `Coti Public Dashboard` - a publicly sharable dashboard. ([Example](https://public.testnet.atomnode.tomoswells.com))
    - ![img](https://media.discordapp.net/attachments/995792094088155227/1070709166404022344/Screenshot_2023-02-02_at_14.15.31.png?width=1589&height=825)
  - `Coti Private Dashboard` - a dashboard which has a bit more information
    - ![img](https://media.discordapp.net/attachments/995792094088155227/1070497353968128041/Screenshot_2023-02-02_at_00.14.12.png?width=1493&height=825)
- Grafana Datasources:
  - <a href="https://prometheus.io/docs/visualization/grafana/" target="_blank">Prometheus</a>
  - <a href="https://grafana.com/oss/loki/" target="_blank">Loki</a>

While the dashboards are more immediately useful and give lots of information about the state of your node, the preconfigured Grafana datasources will allow you to create your own custom queries and graphs.

# Useful Docker Management Commands

Take down a single container:

```
docker-compose rm -sv <container_name>
```

Start a single container:

```
docker-compose up <container_name>
```

Restart an individual container:

```
docker restart <container_name>
```

Follow logs of a single service/container:

```
docker-compose logs <container_name> --follow
```

# 🧑‍💻 Debugging

This section will be used to list solutions common debugging problems related to this installation process.

<details>
    <summary>I get HTTPS errors or strange connectivity problems even though everything is set up correctly, or `postgres: could not get migration log" error="failed to check table existence: dial tcp 172.19.0.7:5432: connect: connection refused"`</summary>
In creating this setup, I found that sometimes I would get intermittent problems with networking between docker containers. In debugging, I found that destroying and recreating the `gateway` network would fix this. My suspicion is this is a slight bug/incompatability in Docker, but I am not 100% clear about the cause.<br/>
    Whenever I had these issues, I was able to solve them by running
    <ul>
      <li>docker network rm gateway && docker network create   --driver=bridge   --attachable   --internal=false   gateway</li>
    </ul>
    which recreates the network.
<br/>
<br/>
</details>

# Contributing

This installation method is stable and works well in my tests, but there is plenty of room for improvement. I have many ideas that have not been explored. Some of these are

- Fixing any bugs
- Configuring alerts (e.g. based on RAM usage, CPU usage, and response times)
- More sophisticated dashboards that take better advantage of the unique information available from Coti nodes
- Monitoring traefik (the web server) and charting response times

Dashboards and panels are very easy to contribute, as they can simply be exported from Grafana as JSON files, and all that's needed to make them appear is place them in the directory `config/grafana/provisioning/dashboards`.

If you are interested in contributing to any of these, I would happily take suggestions or code submissions, or make this repository accessible to collaborators.

# ✨ Credits

- Credits to the Coti community for the vital support and guidance given to testnet and mainnet node operators.
- Credits to all the organizations who contribute open-source software, making all this possible for free. Namely Docker, Grafana and Traefik.

# STAY COTI

Stay Coti. ️‍🔥
<br />
<br />

If you have questions, I hang out on twitter <a href="https://twitter.com/tomjwells">@tomjwells</a>. Come and say hi and lets talk Coti!
<br />
<br />
<br />

<p align="center"><a href="https://atomnode.tomoswells.com" target="_blank"><img src="https://cdn.discordapp.com/avatars/343604221331111946/65130831872c9daabdb0d803ce27e594.webp?size=240"></a></p>
