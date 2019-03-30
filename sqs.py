#!/usr/bin/env python3
# sqs - AWS Simple Queue Service tests
# https://github.com/ArtiomL/aws-labs
# Artiom Lichtenstein
# v1.0.0, 29/03/2019

import argparse
import boto3
import random
import string


def funArgParser():
	objArgParser = argparse.ArgumentParser(
		description = 'AWS Simple Queue Service tests',
		epilog = 'https://github.com/ArtiomL/aws-cli')
	objArgParser.add_argument('-c', help = 'number of messages to send/receive (default: 10)', type = int, default = 10, dest = 'count')
	objArgParser.add_argument('-d', help = 'delete queue', action = 'store_true', dest = 'delete')
	objArgParser.add_argument('-g', help = 'region name (default: eu-west-1)', default = 'eu-west-1', dest = 'region')
	objArgParser.add_argument('-q', help = 'queue name (must end with the .fifo suffix)', default = 'qAWSLabs.fifo', dest = 'qname')
	objArgParser.add_argument('-r', help = 'receive messages', action = 'store_true', dest = 'receive')
	objArgParser.add_argument('-s', help = 'send messages', action = 'store_true', dest = 'send')
	return objArgParser.parse_args()


def main():
	objArgs = funArgParser()

	# Create SQS client
	objSQS = boto3.client('sqs', region_name = objArgs.region)

	# Create an SQS queue (returns queue URL if a queue with this name already exists)
	diQResp = objSQS.create_queue(QueueName = objArgs.qname, Attributes = {
		'FifoQueue': 'true',
		'ContentBasedDeduplication': 'true'
		})
	qURL = diQResp['QueueUrl']

	# Send messages
	if objArgs.send:
		for i in range(objArgs.count):
			strMBody =  '{ "msgID": %i, "msgText": "%s" }' % (i, ''.join(random.choices(string.ascii_letters + string.digits, k=32)))
			diMResp = objSQS.send_message(QueueUrl = qURL, MessageBody = strMBody, MessageGroupId = 'msgGroupId')
			print(i, diMResp)

	# Receive messages
	if objArgs.receive:
		for i in range(objArgs.count):
			diMResp = objSQS.receive_message(QueueUrl = qURL, MaxNumberOfMessages = 1)
			print(diMResp['Messages'][0]['Body'])
			objSQS.delete_message(QueueUrl = qURL, ReceiptHandle = diMResp['Messages'][0]['ReceiptHandle'])

	# Delete queue
	if objArgs.delete:
		objSQS.delete_queue(QueueUrl = qURL)


if __name__ == '__main__':
	main()