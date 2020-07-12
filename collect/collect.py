from services.firebase import Firebase
from services.excel import Excel

import requests
import os

FOLDER = 'output'

def download_image(url, disease, filename):
    img = requests.get(url)
    if not os.path.isdir(f'{FOLDER}/{disease}'):
        os.makedirs(f'{FOLDER}/{disease}')
    with open(f'{FOLDER}/{disease}/{filename}', "wb") as file:
        file.write(img.content)

def download_images(firebase, users):
    for user in users:
        user_doc = firebase.get_users_collection().document(user.id
        imgs = user_doc.collection(u'image_diseases').get()
        for img in imgs:
            filename = str(img.id)
            img_dict = img.to_dict()
            url = img_dict['reference']
            disease, _, filename = filename.partition(':')
            print(disease, filename+".png")
            download_image(url, disease, filename+".png")

def get_phone_numbers(users):
    output = []
    for user in users:
        user_dict = user.to_dict()
        try:
            output.append(user_dict['phone'])
        except:
            pass
    return output
    
if __name__ == "__main__":
    if not os.path.isdir(FOLDER):
        os.makedirs(FOLDER)

    excel = Excel('user.xlsx')
    firebase = Firebase()

    users = firebase.get_users()

    data = {}
    data['phone #'] = get_phone_numbers(users)
    excel.write(data, 'phone nums')

    users = firebase.get_users()
    download_images(firebase, users)