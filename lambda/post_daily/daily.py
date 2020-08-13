import json

from communicate import Communicate
from batch import *

communicate = Communicate()

def lambda_handler(event, context):
    batch_process(communicate)
    return {
        'statusCode': 200,
        'body': json.dumps('success')
    }