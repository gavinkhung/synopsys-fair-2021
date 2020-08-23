import * as firebase from 'firebase';
import 'firebase/auth';
import 'firebase/storage';
import admin from 'firebase-admin';


const firebaseConfig = {
    apiKey: "AIzaSyDpX14fp6s_0RzJaPl4P6gs3qYTT0t6UX0",
    authDomain: "jaikrishi-dev.firebaseapp.com",
    databaseURL: "https://jaikrishi-dev.firebaseio.com",
    projectId: "jaikrishi-dev",
    storageBucket: "jaikrishi-dev.appspot.com",
    messagingSenderId: "664954438154",
    appId: "1:664954438154:web:2e055b27ed7bd4e92295f3",
    measurementId: "G-W89T06ZC2S"
};

const app = firebase.initializeApp(firebaseConfig);
const db = app.firestore();

// export const getThread = async (uid) => {
//     const fetched = global['messages'][uid];
//     if(fetched && fetched.length){
//         console.log({fetched});
//         const temp = {
//             uid: uid,
//             messages: fetched
//         };
//         return temp;
//     } else {
//         const thread = await db.collection('users').doc(uid).collection('messages').get();
//         if(thread.size){
//             console.log(uid);
//             const threadMessages = [];
//             thread.forEach(async messsage => {
//                 const messageData = await messsage.data();
//                 threadMessages.push(messageData["text"]);
//             });
//             global['messages'][uid] = threadMessages;
//             const temp = {
//                 uid: uid,
//                 messages: threadMessages
//             };
//             return temp;
//         }
//     }
// }

// export const getThreads = async () => {
//     const allUsers = db.collection('users');
//     const threads = [];
//     try {
//         const usersSnapshot = await allUsers.get();
//         usersSnapshot.forEach(async (userSnapshot) => {
//             const uid = userSnapshot.id;
//             const thread = await getThread(uid);
//             threads.push(thread);
//         });
//     } catch(error){
//         console.log('error', error);
//     }
//     const delay = ms => new Promise(res => setTimeout(res, ms));
//     await delay(1000);
//     console.log('threads', threads);
//     return threads;
// }

export const sendNotif = async (message) => {
    // messaging.send(message).then((resp) => {
    //     console.log(resp); 
    // })
    // .catch((err) => {
    //     console.log(err); 
    // })
    console.log(message);
    fetch("https://us-central1-jaikrishi-dev.cloudfunctions.net/sendNotif", {
        method: "POST", 
        headers: {
            "Content-Type": "application/json"
        }, 
        body: JSON.stringify(message),
        mode: "no-cors"
    }).then((resp) => console.log(resp)).catch((err) => console.log(err)); 
}

export const getThreadNames = async () => {
    const allUsers = db.collection('users');
    const threads = [];
    try {
        const usersSnapshot = await allUsers.get();
        usersSnapshot.forEach(async (userSnapshot) => {
            const uid = userSnapshot.id;
            console.log(userSnapshot.data()["token"]); 
            threads.push({
                uid: uid,
                token: userSnapshot.data()["token"]
            });
        });
    } catch(error){
        console.log('error', error);
    }
    console.log('threads', threads);
    return threads;
}

export const getThreadRef = (uid) => {
    return db.collection('users').doc(uid).collection('messages');
}

export const sendMessage = async (uid, message) => {
    const threadRef = getThreadRef(uid);
    threadRef.doc(`${Date.now()}`).set(message);
}