
$ErrorActionPreference = "Stop"

Write-Host "`n=== MULTI-SITE NETWORK DEPLOYMENT ===" -ForegroundColor Cyan

# 1. Create networks if they do not exist
$networks = @(
    @{ Name = "site-lahore"; Subnet = "10.10.1.0/24" },
    @{ Name = "site-islamabad"; Subnet = "10.10.2.0/24" },
    @{ Name = "site-karachi"; Subnet = "10.10.3.0/24" }
)

foreach ($net in $networks) {
    $exists = docker network ls --format '{{.Name}}'
    if ($exists -notcontains $net.Name) {
        docker network create --driver bridge --subnet $net.Subnet $net.Name
    }
    Write-Host "Network ready: $($net.Name)" -ForegroundColor Green
}

# 2. Create site servers if missing
$servers = @(
    @{ Name = "lahore-server"; Network = "site-lahore"; IP = "10.10.1.10" },
    @{ Name = "islamabad-server"; Network = "site-islamabad"; IP = "10.10.2.10" },
    @{ Name = "karachi-server"; Network = "site-karachi"; IP = "10.10.3.10" }
)

foreach ($server in $servers) {
    $exists = docker ps -a --format '{{.Names}}'
    if ($exists -notcontains $server.Name) {
        docker run -d --name $server.Name --network $server.Network --ip $server.IP --cap-add NET_ADMIN nginx:alpine
    } else {
        $running = docker inspect -f '{{.State.Running}}' $server.Name
        if ($running -ne "true") {
            docker start $server.Name
        }
    }
    Write-Host "Server ready: $($server.Name)" -ForegroundColor Green
}

# 3. Create central router if missing
$exists = docker ps -a --format '{{.Names}}'

if ($exists -notcontains "central-router") {
    docker run -dit --name central-router --network site-lahore --ip 10.10.1.254 --privileged alpine:latest sh
} else {
    $running = docker inspect -f '{{.State.Running}}' central-router
    if ($running -ne "true") {
        docker start central-router
    }
}

# 4. Connect router to remaining networks
$routerNetworks = docker inspect -f '{{json .NetworkSettings.Networks}}' central-router

if ($routerNetworks -notmatch '"site-islamabad"') {
    docker network connect --ip 10.10.2.254 site-islamabad central-router
}

if ($routerNetworks -notmatch '"site-karachi"') {
    docker network connect --ip 10.10.3.254 site-karachi central-router
}

# 5. Enable router IP forwarding
docker exec central-router sysctl -w net.ipv4.ip_forward=1

# 6. Configure static routes
docker exec --privileged lahore-server ip route replace 10.10.2.0/24 via 10.10.1.254
docker exec --privileged lahore-server ip route replace 10.10.3.0/24 via 10.10.1.254

docker exec --privileged islamabad-server ip route replace 10.10.1.0/24 via 10.10.2.254
docker exec --privileged islamabad-server ip route replace 10.10.3.0/24 via 10.10.2.254

docker exec --privileged karachi-server ip route replace 10.10.1.0/24 via 10.10.3.254
docker exec --privileged karachi-server ip route replace 10.10.2.0/24 via 10.10.3.254

Write-Host "`n=== NETWORK DEPLOYMENT FINISHED ===" -ForegroundColor Green
