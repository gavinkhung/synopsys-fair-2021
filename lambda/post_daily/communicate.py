import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from firebase_admin import messaging
from google.cloud import firestore
from firebase_admin import firestore

from tempfile import TemporaryFile
from PIL import Image

from random import randrange
from datetime import datetime

import requests

class Communicate:
    def __init__(self):
        cred = credentials.Certificate('certificate.json')
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'jaikrishi.appspot.com'
        })
        self.store = firestore.client() 
        self.bucket = storage.bucket()

    def upload(self, file, uid):
        title = self.getTime()
        filename = uid+"/"+title+".png"
        blob = self.bucket.blob(filename)
        f = TemporaryFile()
        pil_image.save(f, 'JPEG')
        f.seek(0)
        blob.upload_from_file(f)
        blob.make_public()
        f.close()
        return blob.public_url
    
    def get_users(self):
        doc_ref = self.store.collection(u'users')
        docs = doc_ref.get()
        return docs 

    def get_user(self, uid):
        return self.store.collection(u'users').document(uid)

    def update_document(self, doc, fields):
        doc.update(fields)
    
    def add_image_disease(self, uid, ref, disease):
        time = self.getTime()
        print(time)
        title = f'{disease}:{time}'
        doc_ref = self.store.document(f'users/{uid}/image_diseases/{title}')
        doc_ref.set({
            'reference': ref,
            'status': 'unchecked',
            'time': time,
            'type': disease
        })

    def add_daily_disease(self, uid, disease, tp):
        time = self.getTime()
        if tp == 2 : 
            title = f'{disease}:{time}'
            doc_ref = self.store.document(f'users/{uid}/daily_diseases/{title}')
            doc_ref.set({
                'time': time,
                'type': 'disease_notif', 
                'disease': disease, 

            })
        elif tp == 1: 
            title = f'DateNotif:{time}'
            doc_ref = self.store.document(f'users/{uid}/daily_diseases/{title}')
            doc_ref.set({
              'time': time, 
              'type': 'date_notif', 
              'steps':  disease
           })
        else : 
            title = f'Misceallaneos:{time}'
            doc_ref = self.store.document(f'users/{uid}/daily_diseases/{title}')
            doc_ref.set({
                'time': time, 
                'type': 'misc', 
                'data': disease
            })

    
    def getTime(self):
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    def send_notifications(self, registration_tokens, title, body):
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            android=messaging.AndroidConfig(
                priority='normal',
                notification=messaging.AndroidNotification(
                    icon='stock_ticker_update',
                    color='#f45342'
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(badge=42),
                ),
            ),
            tokens=registration_tokens
        )
        response = messaging.send_multicast(message)
        if response.failure_count > 0:
            responses = response.responses
            failed_tokens = []
            for idx, resp in enumerate(responses):
                if not resp.success:
                    # The order of responses corresponds to the order of the registration tokens.
                    failed_tokens.append(registration_tokens[idx])
            # print('List of tokens that caused failures: {0}'.format(failed_tokens))
            return response.failure_count
        else: 
            return response.failure_count


if __name__ == "__main__":
    communicate = Communicate()
    communicate.send_notifications(['dy2EZGDOHuc:APA91bFQ3CbPps5z9gKcaL4c7KdRw4ifebzE5Hi2BC8Dd8cOl7M7UdhvRdo-XZCjjSymuJR83ADa-jPBi1vnNcj7aRDhJDGxBUZnZX9NdtMj52vrUcD5mVkNCjWuLzzb9SgfjY8YjW94'], 'title from python', 'body from python')

