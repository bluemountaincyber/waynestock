import boto3
import json

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    response = client.scan(TableName='seats')
    output = []
    for item in response['Items']:
        entry = {
            'seat_id': item['seat_id']['S'],
            'row': int(item['row']['N']),
            'seat': int(item['seat']['N']),
            'section': int(item['section']['N']),
            'available': item['available']['BOOL']
        }
        output.append(entry)
    return {
        'statusCode': 200,
        'body': json.dumps(output)
    }