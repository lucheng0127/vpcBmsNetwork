#!/bin/bash

set -ex

function ne() {
  ip netns exec $@
}

# Router
ip netns add router
ne router ip l set lo up
ne router ip l add br-bms type bridge
ne router ip a add 172.16.0.1/16 dev br-bms
ne router ip l set br-bms up
ne router ip l add br-cloud type bridge
ne router ip a add 10.66.0.1/16 dev br-cloud
ne router ip l set br-cloud up

# Bms VM belong to vpc1
ip netns add bv1
ne bv1 ip l set lo up
ip l add rTbv1 type veth peer name bv1Tr
ip l set rTbv1 netns router
ip l set bv1Tr netns bv1
ne router ip l set rTbv1 master br-bms
ne router ip l set rTbv1 up
ne bv1 ip a add 172.16.0.11/16 dev bv1Tr
ne bv1 ip l set bv1Tr up
ne bv1 ip r add default via 172.16.0.1

# Bms VM belong to vpc2
ip netns add bv2
ne bv2 ip l set lo up
ip l add rTbv2 type veth peer name bv2Tr
ip l set rTbv2 netns router
ip l set bv2Tr netns bv2
ne router ip l set rTbv2 master br-bms
ne router ip l set rTbv2 up
ne bv2 ip a add 172.16.0.12/16 dev bv2Tr
ne bv2 ip l set bv2Tr up
ne bv2 ip r add default via 172.16.0.1

# Bms VPC Gateway
ip netns add bvg
ne bvg ip l set lo up
ip l add rTbvg type veth peer name bvgTr
ip l set rTbvg netns router
ip l set bvgTr netns bvg
ne router ip l set rTbvg master br-bms
ne router ip l set rTbvg up
ne bvg ip a add 172.16.0.254/16 dev bvgTr
ne bvg ip l set bvgTr up
ne bvg ip r add default via 172.16.0.1

# Gateway of vpc1
ip netns add v1g
ne v1g ip l set lo up
ip l add rTv1g type veth peer name v1gTr
ip l set rTv1g netns router
ip l set v1gTr netns v1g
ne router ip l set rTv1g master br-cloud
ne router ip l set rTv1g up
ne v1g ip a add 10.66.0.11/16 dev v1gTr
ne v1g ip l set v1gTr up
ne v1g ip r add default via 10.66.0.1
ne v1g ip l add br0 type bridge
ne v1g ip a add 192.168.100.1/24 dev br0
ne v1g ip l set br0 up
ne v1g iptables -t nat -A POSTROUTING -o v1gTr -j MASQUERADE
## Vm of vpc1
ip netns add v1p
ne v1p ip l set lo up
ip l add v1gTp type veth peer name v1pTg
ip l set v1gTp netns v1g
ip l set v1pTg netns v1p
ne v1g ip l set v1gTp master br0
ne v1g ip l set v1gTp up
ne v1p ip a add 192.168.100.2/24 dev v1pTg
ne v1p ip l set v1pTg up
ne v1p ip r add default via 192.168.100.1

# Gateway of vpc2
ip netns add v2g
ne v2g ip l set lo up
ip l add rTv2g type veth peer name v2gTr
ip l set rTv2g netns router
ip l set v2gTr netns v2g
ne router ip l set rTv2g master br-cloud
ne router ip l set rTv2g up
ne v2g ip a add 10.66.0.22/16 dev v2gTr
ne v2g ip l set v2gTr up
ne v2g ip r add default via 10.66.0.1
ne v2g ip l add br0 type bridge
ne v2g ip a add 192.168.100.1/24 dev br0
ne v2g ip l set br0 up
ne v2g iptables -t nat -A POSTROUTING -o v2gTr -j MASQUERADE
## Vm of vpc2
ip netns add v2p
ne v2p ip l set lo up
ip l add v2gTp type veth peer name v2pTg
ip l set v2gTp netns v2g
ip l set v2pTg netns v2p
ne v2g ip l set v2gTp master br0
ne v2g ip l set v2gTp up
ne v2p ip a add 192.168.100.2/24 dev v2pTg
ne v2p ip l set v2pTg up
ne v2p ip r add default via 192.168.100.1
