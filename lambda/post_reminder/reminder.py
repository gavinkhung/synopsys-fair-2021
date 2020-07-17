import json

from communicate import Communicate

communicate = Communicate()

def lambda_handler(event, context):
    tokens = {
        'en': [],
        'hi': []
    }
    users = communicate.get_users()
    for user in users:
        try:
            user = user.to_dict()
            lang = user['lang']
            token = user['token']
            tokens[lang].append(token)
        except Exception as e:
            pass
    for key, value in tokens.items():
        if key == 'en':
            communicate.send_notifications(tokens[key], 'Reminder', '*Please upload photo if you think your crop has some disease')
        elif key =='hi':
            communicate.send_notifications(tokens[key], 'अनुस्मारक', '* कृपया फोटो अपलोड करें यदि आपको लगता है कि आपकी फसल में कोई बीमारी है')
    return {
        'statusCode': 200,
        'body': json.dumps('Sent')
    }