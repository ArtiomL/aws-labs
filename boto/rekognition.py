#!/usr/bin/env python3
# rekognition - Amazon Rekognition tests
# https://github.com/ArtiomL/aws-labs
# Artiom Lichtenstein
# v1.0.0, 01/04/2019

import argparse
import boto3
import json
import sys


def funArgParser():
	objArgParser = argparse.ArgumentParser(
		description = 'Amazon Rekognition tests',
		epilog = 'https://github.com/ArtiomL/aws-cli')
	objArgParser.add_argument('-g', help = 'region name (default: eu-west-1)', default = 'eu-west-1', dest = 'region')
	objArgParser.add_argument('IMG', help = 'input image filename(s)', nargs = '*')
	return objArgParser.parse_args()


def main():
	objArgs = funArgParser()

	#
	objRek = boto3.client('rekognition', region_name = objArgs.region)

	for i in objArgs.IMG:
		with open(i, 'rb') as f:
			data = f.read()
		diResp = objRek.detect_faces(
			Image = {
				'Bytes': data,
			},
			Attributes = ['ALL']
		)
		print(json.dumps(diResp, indent = 4))


if __name__ == '__main__':
	main()
