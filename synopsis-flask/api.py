try:
    import unzip_requirements
except ImportError:
    pass

from flask import Flask, jsonify, request, make_response
from PIL import Image
import cv2
from io import BytesIO
import base64
import numpy as np
import boto3
import botocore
import json
import time

from ciede2000 import CIEDE2000
from batch import get_diseases

app = Flask(__name__)

image_disease_classes = ['bacterial_leaf_blight', 'brown_spot', 'leaf_smut']
lcc_classes = ['2', '3', '4', '5']

def maskedImage(image):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    hsv_image = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)
    # masking range in hsv
    # lower_bound = (35, 60, 35)
    lower_bound = (20, 60, 35)
    upper_bound = (100, 255, 255)

    # create the mask
    lower_square = np.full((10, 10, 3), lower_bound, dtype=np.uint8) / 255.0
    upper_square = np.full((10, 10, 3), upper_bound, dtype=np.uint8) / 255.0
    mask = cv2.inRange(hsv_image, lower_bound, upper_bound)
    result = cv2.bitwise_and(image, image, mask=mask)

    return result

def convertToLAB(filename):
    img = cv2.imread(filename)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.float32(img)
    img *= 1./255
    Lab = cv2.cvtColor(img, cv2.COLOR_RGB2Lab)
    L, a, b = cv2.split(Lab)
    return (L.flatten(), a.flatten(), b.flatten())

def convertToLABAndMask(image):
    img = maskedImage(image)
    img = np.float32(img)

    # convert masked image to lab and flatten image
    img *= 1./255
    Lab = cv2.cvtColor(img, cv2.COLOR_RGB2Lab)
    L, a, b = cv2.split(Lab)
    return (L.flatten(), a.flatten(), b.flatten())

# iterates through the image and quotient of the sum of the differents and the length
def total_difference(L1, a1, b1, L2, a2, b2):
    length = L1.shape[0]
    lccLength = L2.shape[0]
    trueLength = 0
    diff = 0
    for i in range(length):
        # wrap the lcc chart, if the image is larger than the lcc image
        lccIndex = i % lccLength
        # do not count black pixels
        if L1[i] != 0.0 and a1[i]!=0.0 and b1[i]!=0.0:
            diff += CIEDE2000((L1[i], a1[i], b1[i]), (L2[lccIndex], a2[lccIndex], b2[lccIndex]))
            trueLength += 1
    if(trueLength == 0):
        return 0
    return diff/trueLength

LCC2 = 'LCC2.jpeg'
LCC3 = 'LCC3.jpeg'
LCC4 = 'LCC4.jpeg'
LCC5 = 'LCC5.jpeg'

L_LCC2, a_LCC2, b_LCC2 = convertToLAB(LCC2)
L_LCC3, a_LCC3, b_LCC3 = convertToLAB(LCC3)
L_LCC4, a_LCC4, b_LCC4 = convertToLAB(LCC4)
L_LCC5, a_LCC5, b_LCC5 = convertToLAB(LCC5)

@app.route("/upload", methods=["POST"])
def upload():
  try:
    form = request.form.to_dict(flat=False)
    data = {}

    data["temperature"] = form["temp"][0]  
    data["dTemp"] = form['maxTemp'][0]
    data["nTemp"] = form['minTemp'][0]
    data["seed"] = int((int(time.time()) - int(form['seeding'][0]))/86400)
    data["trans"] = int((int(time.time()) - int(form['transplant'][0]))/86400)
    data["type"] = form['type'][0]
    data["humid"] = form['humidity'][0]
    
    weather_disease = get_diseases(data)

    config = botocore.config.Config(read_timeout=80)
    runtime= boto3.client('runtime.sagemaker', region_name='us-west-1', config=config)
    ENDPOINT_NAME = 'tensorflow-training-2021-03-08-06-10-54-194'

    # disease prediction
    img_str = form['img'][0]
    img_bytes = base64.b64decode(img_str)
    img = Image.frombytes(mode='RGB', data=img_bytes, size=(10, 10))

    img = img.resize((128, 128))
    img = np.array(img)
    img = np.expand_dims(img, axis=0)

    # LCC
    L, a, b = convertToLABAndMask(img)

    lcc_differences = []
    # LCC2
    lcc_differences.append(total_difference(L, a, b, L_LCC2, a_LCC2, b_LCC2))
    # LCC3
    lcc_differences.append(total_difference(L, a, b, L_LCC3, a_LCC3, b_LCC3))
    # LCC 4
    lcc_differences.append(total_difference(L, a, b, L_LCC4, a_LCC4, b_LCC4))
    # LCC5
    lcc_differences.append(total_difference(L, a, b, L_LCC5, a_LCC5, b_LCC5))
        
    img = img/255
    payload = json.dumps(img.tolist())

    # temp
    # image_disease_classes = ['bacterial_leaf_blight', 'brown_spot', 'leaf_smut']
    results = {'predictions': [[0.252986103, 0.295812041, 0.451201886]]}

    # response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME, ContentType='application/json', Body=payload)
    # results=json.loads(response['Body'].read().decode())

    print(lcc_differences, results)

    # image_disease_classification = image_disease_classes[results['predictions'].index(max(results))]
    image_disease_classification = image_disease_classes[results['predictions'][0].index(max(results['predictions'][0]))]
    lcc_chart = lcc_classes[lcc_differences.index(max(lcc_differences))]

    response = {
        "image_disease_classification": image_disease_classification,
        "weather_disease": weather_disease,
        "lcc_chart": lcc_chart,
    }

    print(response)

    return make_response(jsonify(response), 200)
  except Exception as e:
    print(e)
    response = {
        "image_disease_classification": "",
        "weather_disease": [""],
        "lcc_chart": -1
    }
    return make_response(jsonify(response), 502)