import json
import base64
from io import BytesIO
from requests_toolbelt import MultipartDecoder
from PIL import Image
from predict import Prediction
from communicate import Communicate

communicate = Communicate()
model = Prediction()

def upload_route(event, context):
    params = event['multiValueQueryStringParameters']
    crop = params["crop"]
    uid = params["uid"]
    
    #wihtout proxy
    binary_file = base64.b64decode(event['body-json'])
    decoder = MultipartDecoder(binary_file, event['headers']['content-type'])
    byte_img = decoder.parts[0].content
    pil_image = Image.open(BytesIO(byte_img))

    ref = communicate.upload(pil_image, uid)
    disease = model.predict(pil_image, crop)
    communicate.add_image_disease(uid, ref, disease)

    return {
        "querystring": event['queryStringParameters'],
        "header": event['headers']
    }