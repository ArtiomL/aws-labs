#!/usr/bin/env python3
# rekognition - Amazon Rekognition Tests
# https://github.com/ArtiomL/aws-labs
# Artiom Lichtenstein
# v1.0.1, 19/10/2019

import argparse
import boto3
import json
import sys


def funArgParser():
	objArgParser = argparse.ArgumentParser(
		description = 'Amazon Rekognition Tests',
		epilog = 'https://github.com/ArtiomL/aws-cli')
	objArgParser.add_argument('-g', help = 'region name (default: eu-west-1)', default = 'eu-west-1', dest = 'region')
	objArgParser.add_argument('-e', '--entities', help = 'detect instances of real-world entities', action = 'store_true')
	objArgParser.add_argument('-f', '--faces', help = 'detect faces', action = 'store_true')
	objArgParser.add_argument('-t', '--text', help = 'detect text', action = 'store_true')
	objArgParser.add_argument('-u', '--unsafe', help = 'detect unsafe content', action = 'store_true')
	objArgParser.add_argument('IMG', help = 'input image filename(s)', nargs = '*')
	return objArgParser.parse_args()


def main():
	#Convert argument strings to objects
	objArgs = funArgParser()

	# Rekognition client
	objRek = boto3.client('rekognition', region_name = objArgs.region)

	for i in objArgs.IMG:
		with open(i, 'rb') as f:
			data = f.read()

		# Labels
		if objArgs.entities:
			diResp = objRek.detect_labels(
				Image = {
					'Bytes': data,
				}
			)
			print(json.dumps(diResp, indent = 4))

		# Faces
		if objArgs.faces:
			diResp = objRek.detect_faces(
				Image = {
					'Bytes': data,
				},
				Attributes = ['ALL']
			)
			print(json.dumps(diResp, indent = 4))

		# Text
		if objArgs.text:
			diResp = objRek.detect_text(
				Image = {
					'Bytes': data,
				}
			)
			print(json.dumps(diResp, indent = 4))

		# Moderation
		if objArgs.unsafe:
			diResp = objRek.detect_moderation_labels(
				Image = {
					'Bytes': data,
				}
			)
			print(json.dumps(diResp, indent = 4))


if __name__ == '__main__':
	main()
