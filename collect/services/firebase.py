import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage

class Firebase:
    def __init__(self):
        cred = credentials.Certificate('certificate.json')
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'jaikrishi.appspot.com'
        })
        self.store = firestore.client() 
        self.bucket = storage.bucket()
    
    def get_users(self):
        return self.store.collection(u'users').get()

    def get_users_collection(self):
        return self.store.collection(u'users')

    