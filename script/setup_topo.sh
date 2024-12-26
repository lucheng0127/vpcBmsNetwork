#!/bin/bash

set -ex

# vpnServer和网络
ip netns add vpnServer
ip netns exec vpnServer ip l set lo up
ip netns exec vpnServer ip l add br-vpn type bridge
ip netns exec vpnServer ip a add 10.66.0.254/24 dev br-vpn
ip netns exec vpnServer ip l set br-vpn up

# bmsGw vpn网络
ip netns add bmsGw
ip netns exec bmsGw ip l set lo up
ip l add bmsTs type veth peer name sTbms
ip l set sTbms netns vpnServer
ip netns exec vpnServer ip l set sTbms master br-vpn
ip netns exec vpnServer ip l set sTbms up
ip l set bmsTs netns bmsGw
ip netns exec bmsGw ip a add 10.66.0.200/24 dev bmsTs
ip netns exec bmsGw ip l set bmsTs up

# vpc1Gw vpn网络
ip netns add vpc1Gw
ip netns exec vpc1Gw ip l set lo up
ip l add vpc1Ts type veth peer name sTvpc1
ip l set sTvpc1 netns vpnServer
ip netns exec vpnServer ip l set sTvpc1 master br-vpn
ip netns exec vpnServer ip l set sTvpc1 up
ip l set vpc1Ts netns vpc1Gw
ip netns exec vpc1Gw ip a add 10.66.0.1/24 dev vpc1Ts
ip netns exec vpc1Gw ip l set vpc1Ts up

# vpc2Gw vpn网络
ip netns add vpc2Gw
ip netns exec vpc2Gw ip l set lo up
ip l add vpc2Ts type veth peer name sTvpc2
ip l set sTvpc2 netns vpnServer
ip netns exec vpnServer ip l set sTvpc2 master br-vpn
ip netns exec vpnServer ip l set sTvpc2 up
ip l set vpc2Ts netns vpc2Gw
ip netns exec vpc2Gw ip a add 10.66.0.2/24 dev vpc2Ts
ip netns exec vpc2Gw ip l set vpc2Ts up

# bms网络和虚机
ip netns exec bmsGw ip l add br-bms type bridge
ip netns exec bmsGw ip a add 172.16.0.254/24 dev br-bms
ip netns exec bmsGw ip l set br-bms up

ip netns add bmsvpc1
ip netns exec bmsvpc1 ip l set lo up
ip l add bms1Tg type veth peer name gTbms1
ip l set gTbms1 netns bmsGw
ip netns exec bmsGw ip l set gTbms1 master br-bms
ip netns exec bmsGw ip l set gTbms1 up
ip l set bms1Tg netns bmsvpc1
ip netns exec bmsvpc1 ip a add 172.16.0.11/24 dev bms1Tg
ip netns exec bmsvpc1 ip l set bms1Tg up
ip netns exec bmsvpc1 ip r add 192.168.100.0/24 via 172.16.0.254
ip netns exec bmsvpc1 ip r add 192.168.200.0/24 via 172.16.0.254

ip netns add bmsvpc2
ip netns exec bmsvpc2 ip l set lo up
ip l add bms2Tg type veth peer name gTbms2
ip l set gTbms2 netns bmsGw
ip netns exec bmsGw ip l set gTbms2 master br-bms
ip netns exec bmsGw ip l set gTbms2 up
ip l set bms2Tg netns bmsvpc2
ip netns exec bmsvpc2 ip a add 172.16.0.12/24 dev bms2Tg
ip netns exec bmsvpc2 ip l set bms2Tg up
ip netns exec bmsvpc2 ip r add 192.168.100.0/24 via 172.16.0.254

# vpc2网络和虚机
ip netns exec vpc2Gw ip l add br-subnet type bridge
ip netns exec vpc2Gw ip a add 192.168.100.1/24 dev br-subnet
ip netns exec vpc2Gw ip l set br-subnet up

ip netns add vpc2vm1
ip netns exec vpc2vm1 ip l set lo up
ip l add v2v1Tg type veth peer name gTv2v1
ip l set gTv2v1 netns vpc2Gw
ip netns exec vpc2Gw ip l set gTv2v1 master br-subnet
ip netns exec vpc2Gw ip l set gTv2v1 up
ip l set v2v1Tg netns vpc2vm1
ip netns exec vpc2vm1 ip a add 192.168.100.2/24 dev v2v1Tg
ip netns exec vpc2vm1 ip l set v2v1Tg up
ip netns exec vpc2vm1 ip r add default via 192.168.100.1

# vpc1网络和虚机
ip netns exec vpc1Gw ip l add br-subnet1 type bridge
ip netns exec vpc1Gw ip a add 192.168.100.1/24 dev br-subnet1
ip netns exec vpc1Gw ip l set br-subnet1 up

ip netns add vpc1s1
ip netns exec vpc1s1 ip l set lo up
ip l add v1s1Tg type veth peer name gTv1s1
ip l set gTv1s1 netns vpc1Gw
ip netns exec vpc1Gw ip l set gTv1s1 master br-subnet1
ip netns exec vpc1Gw ip l set gTv1s1 up
ip l set v1s1Tg netns vpc1s1
ip netns exec vpc1s1 ip a add 192.168.100.2/24 dev v1s1Tg
ip netns exec vpc1s1 ip l set v1s1Tg up
ip netns exec vpc1s1 ip r add default via 192.168.100.1

ip netns exec vpc1Gw ip l add br-subnet2 type bridge
ip netns exec vpc1Gw ip a add 192.168.200.1/24 dev br-subnet2
ip netns exec vpc1Gw ip l set br-subnet2 up

ip netns add vpc1s2
ip netns exec vpc1s2 ip l set lo up
ip l add v1s2Tg type veth peer name gTv1s2
ip l set gTv1s2 netns vpc1Gw
ip netns exec vpc1Gw ip l set gTv1s2 master br-subnet2
ip netns exec vpc1Gw ip l set gTv1s2 up
ip l set v1s2Tg netns vpc1s2
ip netns exec vpc1s2 ip a add 192.168.200.2/24 dev v1s2Tg
ip netns exec vpc1s2 ip l set v1s2Tg up
ip netns exec vpc1s2 ip r add default via 192.168.200.1

