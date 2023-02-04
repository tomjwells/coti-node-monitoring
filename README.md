# coti-node-monitoring

<h1 align="center">Coti Node Monitoring</h1>
<p align="center">An easy method to configure public and private monitoring for Coti nodes.</p>

<p align="center">
	<a href="https://github.com/tj-wells/coti-node-monitoring"><img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/tj-wells/coti-node-monitoring"></a>
    <a href="https://twitter.com/intent/tweet?text=I%20just%20installed%20%24COTI%20node%20monitoring%20with%20%40tomjwells%27%20Docker%20installation%20method.%20It%20worked%20like%20a%20charm%21%20and%20looks%20great%0A%0A%F0%9F%94%A5%0A%0Ahttps%3A%2F%2Fgithub.com%2Ftj-wells%2Fcoti-node-monitoring%0A%0A%23COTI%20%24DJED%20%24SHEN%20%20"><img src="https://randojs.com/images/tweetShield.svg" alt="Tweet" height="20"/></a>
</p><br/>

<p align="center"><a href="https://public.testnet.atomnode.tomoswells.com"><img src="https://media.discordapp.net/attachments/995792094088155227/1070497353968128041/Screenshot_2023-02-02_at_00.14.12.png?width=1493&height=825" width="100%" /></a></p><br/>

[Click to see a live example of a dashboard produced from this setup](https://public.testnet.atomnode.tomoswells.com).

This method provides:

- A <a href="https://github.com/grafana/grafana" target="_blank">Grafana</a> dashboard visualisation system, accessible at `https://monitoring.<your-node-url>`
- Automatic SSL certificate management for the new subdomain
- Server monitoring and health statistics with <a href="https://prometheus.io/docs/introduction/overview/" target="_blank">Prometheus</a>
- Log tracking and querying with <a href="https://github.com/grafana/loki" target="_blank">Loki</a>

# Installation Instructions

This guide assumes that your node has been installed using Docker. If you are yet to do this, I suggest checking out my <a href="https://github.com/tj-wells/coti-node" target="_blank">Coti-Docker installation guide</a> before installing any monitoring. This guide also assumes you have the following programs installed:

- Docker
- docker-compose
- git

Before beginning, you should bring down your node, since one of the steps requires a restart of Docker. For nodes installed with Docker, do this by navigating to your directory where your docker-compose file is located, and run

```
docker-compose down
```

which safely brings down your node.

## DNS Settings

The monitoring system is set up to be accessed from the url `https://monitoring.<your-node-url>`. If you have not set up a subdomain record with your DNS provider, it is likely you will need to do this to make that url accessible.

To do this, you can either add a wildcard subdomain (`*`), or the specific subdomain you intend to set up (`monitoring.`). In my case I went with a wildcard subdomain, and my working DNS configuration looks like

![Wildcard subdomain example](https://media.discordapp.net/attachments/995792094088155227/1070766780181659668/Screenshot_2023-02-02_at_18.04.48.png)

where the IP address is the IP address for your server.

## 1. Clone the Repository

To keep things organized, I suggest having your Coti node located under the directory `~/coti-node`. We will install the monitoring setup alongside that directory, under `~/coti-node-monitoring`. From your home directory, run

```
git clone https://github.com/tj-wells/coti-node-monitoring.git && cd coti-node-monitoring
```

## 2. Create a `.env` File

The `.env` file defines important environment variables used to set up the monitoring. Create a `.env` file in the `coti-node-monitoring` directory, enter your environment variables in the following format:

```.env
SERVERNAME="<your-node-domain.tld>"
GRAFANA_USERNAME="<Enter a username here>"
GRAFANA_PASSWORD="<Enter a password here>"
```

where

- `SERVERNAME` is the web address of your node, excluding `http(s)://` and `www.`, for example `subdomain.your-node-domain.tld`,
- `GRAFANA_USERNAME` is the username you wish to use to login to the Grafana dashboard, and,
- `GRAFANA_PASSWORD` is the password you wish to use to login to the Grafana dashboard.

If you are unsure about a username, you can use your email associated with your Coti node (or make one up). [Click here for a simple password generator](https://bitwarden.com/password-generator/).

# 🏃 Running the Monitoring Stack

You may want to perform this process with two terminal sessions open. In one terminal you can run the Coti node, and in the other you will run the monitoring stack.

## Step 1) Set up a Network

This setup uses a Docker network called `gateway` (that we create) to communicate between the two projects. You can check if this network exists on your system using `docker network ls`. If it exists, you needn't do anything. If it does not exist, it can be created with `docker network create --driver=bridge --attachable --internal=false gateway`. Or, in one line:

```
[[ $(docker network ls) == *"gateway"* ]] && docker network create --driver=bridge --attachable --internal=false gateway
```

## Step 2) Run the Coti Node

Since we installed the Loki plugin, it is safest to use the `--force-recreate` option of docker-compose when running the Coti node, which makes Docker rebuild the containers with proper configuration for Loki logging.
In your first terminal, navigate to your Coti node directory, and run the containers

```
docker-compose up --force-recreate
```

The `--force-recreate` option is only needed the first time after installing the Loki plugin. Every other time, you can simply use

```
docker-compose up
```

Make sure your Coti node is running correctly before continuing to the next step.

## Step 3) Run the Monitoring Stack

Now you are ready to run the monitoring stack! In the second terminal, change to the Coti node monitoring directory, and run

```
docker-compose up
```

This will download and install the monitoring software for you, . If everything goes successfully, you are done.

Grafana usually takes between 10-30 seconds to become ready, so after a few seconds, navigate in your browser to `monitoring.<your-node-url>`. If everything is working, you will see the Grafana sign-in page:

<img src="https://media.discordapp.net/attachments/995792094088155227/1070504105056948244/Screenshot_2023-02-02_at_00.40.57.png?width=1445&height=825"/>

Your sign-in credentials come from the `.env` file. Use your `EMAIL` as your username, and `PKEY` as your password.

If you see the following welcome screen:
<img src="https://media.discordapp.net/attachments/995792094088155227/1070504686387478598/Screenshot_2023-02-02_at_00.43.14.png?width=1802&height=825"/>
then congrats, you did it!

🎉

# Using Grafana

I wish to cover some of the features that come out-of-the-box with this installation method. These could be improved and extended further and I would welcome improvements and suggestions from others.

Out of the box features

- Dashboards:
  - `Coti Public Dashboard` - a publicly sharable dashboard. ([Example](https://public.testnet.atomnode.tomoswells.com))
    - ![img](https://media.discordapp.net/attachments/995792094088155227/1070709166404022344/Screenshot_2023-02-02_at_14.15.31.png?width=1589&height=825)
  - `Coti Private Dashboard` - a dashboard which has a bit more information
    - ![img](https://media.discordapp.net/attachments/995792094088155227/1070497353968128041/Screenshot_2023-02-02_at_00.14.12.png?width=1493&height=825)
- Grafana Datasources:
  - <a href="https://prometheus.io/docs/visualization/grafana/" target="_blank">Prometheus</a>
  - <a href="https://grafana.com/oss/loki/" target="_blank">Loki</a>

While the dashboards are more immediately useful, the preconfigured Grafana datasources will allow you to create your own queries and graphs.

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

View logs of a single service/container:

```
docker-compose logs <container_name> --follow
```

# 🧑‍💻 Debugging

This section will be used to answer common debugging problems related to this installation process.

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

This installation method is stable and works well in my tests, but it is far from perfect. I have many ideas for improvements that are not explored. Some of these are

- Fixing any bugs
- Configuring alerts (e.g. based on RAM usage, CPU usage, and response times)
- More sophisticated dashboards that take better advantage of the unique information available from Coti nodes
- Monitoring traefik (the web server) and charting response times

If you are interested in contributing to any of these, I would happily take suggestions or code submissions, or make this repository accessible to collaborators.

Dashboards are especially easy to contribute, as they can be exported from Grafana easily as JSON files, and all I need to do to make them appear is put them in the directory `config/grafana/provisioning/dashboards`.

# ✨ Credits

- Credits to the Coti community for the vital support and guidance given to testnet and mainnet node operators.
- Credits to all the organizations who contribute open-source software, making all this possible for free. Namely Docker, Grafana and Traefik.

# STAY COTI

Stay Coti. ️‍🔥
<br />
<br />

If you have questions, I hang out on twitter <a href="https://twitter.com/tomjwells">@tomjwells</a>. Come and say hi and talk Coti!
<br />
<br />
<br />

<p align="center"><a href="https://atomnode.tomoswells.com" target="_blank"><img src="https://cdn.discordapp.com/avatars/343604221331111946/65130831872c9daabdb0d803ce27e594.webp?size=240"></a></p>
