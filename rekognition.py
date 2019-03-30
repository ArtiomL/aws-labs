import boto3
import json

data = open('/home/user/pic.jpg', 'rb').read()
client = boto3.client('rekognition', region_name='us-west-2')

response = client.detect_faces(
	Image = {
		'Bytes': data,
	},
	Attributes = [
		'ALL',
	]
)

print(json.dumps(response, indent=4))
