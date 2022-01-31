#!/bin/bash
# woof - Common attacks for AWS WAF
# Artiom Lichtenstein
# v2.0, 02/07/2020

shopt -s expand_aliases
source ~/.bash_aliases

trap "echo; echo 'Exiting...'; exit" SIGINT

if [ -z "$1" ]; then
	echo; echo "Usage: ./attack http|s://{HOST_NAME | IP_ADDRESS}[:PORT]"; echo
	exit
fi

sHost=$(echo "$1" | cut -d"/" -f3)
sScheme=$(echo "$1" | cut -d":" -s -f1)
if [ -z "$sScheme" ]; then
	sScheme="https"
fi

echo "Woofing at: $sScheme://$sHost"

# Admin
curl -v -s "$sScheme://$sHost/admin/ui" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/wp-admin/" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/administrator" 2>&1 | grep "> \|< \|Request"

# XSS
curl -v -s "$sScheme://$sHost/get/<script>funEvil();</script>" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/poke" -X POST -d 'name=user&email=<script>funLucifer();</script>' 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/index.php?name=%3C%73%63%72%69%70%74%3E%66%75%6E%4C%69%6C%69%74%68%28%29%3C%2F%73%63%72%69%70%74%3E" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/omnomnom" -H "Cookie: Monster=%3C%73%63%72%69%70%74%3E%66%28%29%3C%2F%73%63%72%69%70%74%3E" 2>&1 | grep "> \|< \|Request"

# Bots
curl -v -s "$sScheme://$sHost/sonny" -H "User-Agent: grabber" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/r2d2" -H "User-Agent: blackwidow" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/t1000" -H "User-Agent: mysqloit" 2>&1 | grep "> \|< \|Request"

# SQLi
curl -v -s "$sScheme://$sHost/search?find=%27%20OR%20%271%27=%271" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/syringe" -X POST -d "name=user&email=' OR '1'='1" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/stick.php?name=-1+union+select+1,2,3,4,5,6,7,8,9,version()" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/mewant" -H "Cookie: Monster=1+ORDER+BY+11" 2>&1 | grep "> \|< \|Request"

# EC2 MetaData SSRF
curl -v -s "$sScheme://$sHost/?url=http://169.254.169.254/latest/meta-data/iam/info" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/relay" -X POST -d "url=http://localhost/latest/meta-data/hostname" 2>&1 | grep "> \|< \|Request"

# LFI
curl -v -s "$sScheme://$sHost/page=../../../etc/passwd" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/?fetch=php://filter/resource=/etc/passwd" 2>&1 | grep "> \|< \|Request"
curl -v -s "$sScheme://$sHost/?gimme=../.aws/credentials" 2>&1 | grep "> \|< \|Request"
