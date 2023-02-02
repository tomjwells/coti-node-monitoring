# coti-node-monitoring

<h1 align="center">Coti Node Monitoring</h1>
<p align="center">An easy method to configure public and private monitoring for Coti nodes.</p>

<p align="center">
	<a href="https://github.com/tj-wells/coti-node-monitoring"><img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/tj-wells/coti-node-monitoring"></a>
    <a href="https://twitter.com/intent/tweet?text=I+just+installed+my+%23COTI+node+with+%40tomjwells%27+Docker+installation+method.+It+worked+like+a+charm%21+%F0%9F%94%A5%0D%0A%0D%0Ahttps%3A%2F%2Fgithub.com%2Ftj-wells%2Fcoti-node%0D%0A%0D%0A%24COTI+%24DJED+%24SHEN+"><img src="https://randojs.com/images/tweetShield.svg" alt="Tweet" height="20"/></a>
</p><br/>

<p align="center"><a href="https://monitoring.testnet.atomnode.tomoswells.com/public-dashboards/e74a85014074490ca844039c73436f3d?orgId=1&refresh=10s"><img src="https://media.discordapp.net/attachments/995792094088155227/1070497353968128041/Screenshot_2023-02-02_at_00.14.12.png?width=1493&height=825" width="100%" /></a></p><br/>

[Click to see a live example of a dashboard produced from this setup](https://monitoring.testnet.atomnode.tomoswells.com/public-dashboards/e74a85014074490ca844039c73436f3d?orgId=1&refresh=10s).

This method provides:

- A <a href="https://github.com/grafana/grafana" target="_blank">Grafana</a> dashboard visualisation system, accessible at `monitoring.<your-node-url>`
- Automatic SSL certificate management for the new subdomain
- Server monitoring and health statistics with <a href="https://prometheus.io/docs/introduction/overview/" target="_blank">Prometheus</a>
- Log tracking and querying with <a href="https://github.com/grafana/loki" target="_blank">Loki</a>

# Installation Instructions

This guide assumes that your Coti node is installed using Docker. If you are yet to do this, I suggest following my <a href="https://github.com/tj-wells/coti-node" target="_blank">Coti-Docker installation guide</a> before setting up your monitoring. This guide also assumes you have the following programs installed:

- Docker
- docker-compose
- git

Before beginning, you should take down your node, as one of the steps requires a restart of Docker. If your node is installed with Docker, do this by navigating to your directory where your docker-compose file is located, and run

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

For organizational purposes, I suggest having your Coti node located under the directory `~/coti-node`. We will install the monitoring setup alongside that directory, under `~/coti-node-monitoring`.

```
cd ~ && git clone https://github.com/tj-wells/coti-node-monitoring.git && cd coti-node-monitoring
```

## 2. Install the Loki plugin

Loki is a log aggregation system that stores and queries logs from your applications. Loki needs special access to Docker's internals to collect logs from the container running inside Docker. Loki's way of obtaining this access is by means of a Docker plugin.

I have included a script `install_loki_plugin.sh` to automatically install and configure the plugin. If it does not work, please let me know, or you can read the script and try to follow its steps.

The script requires sudo priviliges, so run

```
sudo su
install_loki_plugin.sh
```

## 3. Create a `.env` File

The same `.env` file that was used to install your node can be used to install the monitoring. If your node was installed at `~/coti-node`, you can run

```
cp ~/coti-node/.env .
```

# 🏃 Running the Monitoring Stack

You may want to perform this process with two terminal sessions open. In one terminal you can run the Coti node, and in the other you will run the monitoring stack.

## Step 1) Run the Coti Node

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

It is only necessary to use the `--force-recreate` option the first time after installing the Loki plugin. Every other time, you can simply use

```
docker-compose up
```

Make sure your Coti node is running correctly before continuing to the next step.

## Step 3) Run the Monitoring Stack

Now you are ready to run the monitoring stack! In the second terminal, change to the Coti node monitoring directory, and run

```
docker-compose up
```

This will download and install the monitoring software for you, and configure all the networking. If everything goes successfully, you are done.

Grafana typically takes between 5-20 seconds to become ready, so after a few seconds, navigate in your browser to `monitoring.\<your-node-url>`. If everything is working, you will see the Grafana sign-in page:

<img src="https://media.discordapp.net/attachments/995792094088155227/1070504105056948244/Screenshot_2023-02-02_at_00.40.57.png?width=1445&height=825"/>

Your sign-in credentials are taken from the `.env` file. Use your `EMAIL` as your username, and `PKEY` as your password.

If you see the following welcome screen:
<img src="https://media.discordapp.net/attachments/995792094088155227/1070504686387478598/Screenshot_2023-02-02_at_00.43.14.png?width=1802&height=825"/>
then congrats, you did it!

🎉

# Using Grafana

I wish to cover some of the features that come out-of-the-box with this installation method. These could be improved and extended further and I would welcome improvements and suggestions from others.

Out of the box features

- Dashboards:
  - `Coti Public Dashboard` - a publicly sharable dashboard. ([Example](https://monitoring.testnet.atomnode.tomoswells.com/public-dashboards/e74a85014074490ca844039c73436f3d?orgId=1&refresh=10s))
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

# 🧑‍💻 Debugging

This section will be used to answer common debugging problems related to this installation process.

# Contributing

This installation method is stable and works well, but it is far from perfect. There are some improvements that could be made that I have not had time to explore. Some of these are

- Fixing any bugs
- Configuring alerts (e.g. based on RAM usage, CPU usage, and response times)
- More sophisticated dashboards that take better advantage of the unique information available from Coti nodes
- Monitoring traefik

If you are interested in contributing to any of these, I would happily take suggestions or code submissions, or give access to this repository to collaborators.

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
