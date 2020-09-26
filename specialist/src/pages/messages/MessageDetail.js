import React, { useEffect, useState, useReducer } from 'react';
import { useParams, Link } from 'react-router-dom';

import { v4 as uuidv4 } from 'uuid';

import { getThreadRef, getPresetResponses, sendMessage, sendNotif, updateRead } from '../../services/firebase';

const MessageDetail = (props) => {

    const reducer = (state, action) => {
        switch(action.type){
            case 'filter':
                return messages.filter(visibleMessage => visibleMessage.type === action.payload );
            default:
                return state;
        }
    }

    const { uid , token} = useParams();

    const [messages, setMessages] = useState([]);
    const [presetResponses, setPresetResponses] = useState([]);
    const [text, setText] = useState("");

    const [visibleMessages, dispatch] = useReducer(reducer, []);

    const [lastSelected, setLastSelected] = useState("");
    const [selectedDisease, setSelectedDisease] = useState("");
    
    useEffect(() => {
        const unsubscribe = getThreadRef(uid).onSnapshot(querySnapshot => {
            const threadMessages = [];
            querySnapshot.forEach(messsage => {
                const messageData = messsage.data();
                threadMessages.push({
                    text: messageData["text"],
                    time: messageData["createdAt"],
                    image: messageData["image"],
                    name: messageData["user"]["name"],
                    type: messageData["type"],
                });
            });
            setMessages(threadMessages);
        });

        const setup = async () => {
            await updateRead(uid);
            const preset = await getPresetResponses();
            setPresetResponses(preset);
        }
        setup();

        return () => {
            unsubscribe();
        }
    }, []);

    useEffect(() => {
        if(messages && messages.length){
            dispatch({
                type: 'filter',
                payload: lastSelected
            })
        }
    }, [messages, lastSelected]);

    const handleSubmit = async (event) => {
        event.preventDefault();
        if(text !== ''){
            const message = {
                createdAt: Date.now(),
                customProperties: null,
                id: uuidv4(),
                image: null,
                quickReplies: null,
                text: text,
                user: {
                    avatar: "",
                    color: null,
                    containerColor: null,
                    customProperties: null,
                    firstName: null,
                    lastName: null,
                    name: "JaiKrishi",
                    uid: "US"
                },
                video: null,
                type: lastSelected
            }
            await sendMessage(uid, message);
            await sendNotif({
                notification : {
                    title: "Message From JaiKrishi!", 
                    body: text.value
                }, 
                token: token
            });
            setText("");
        }
    }

    console.log(presetResponses);

    return (
        <>
            <div className="ui container">
                <Link to={"/"}><i className="arrow left icon"></i>Back home</Link>
                <br/>
                <>
                    {presetResponses && Object.keys(presetResponses).map(presetResponse => 
                        <button className="ui button" onClick={() => setLastSelected(presetResponse)} key={presetResponse}>{presetResponse}</button>
                    )}
                </>
                {visibleMessages.length ?
                    <div className="ui comments">
                        <h3 className="ui dividing header">Messages with {uid}</h3>
                        {visibleMessages.map(visibleMessage =>
                            <div className="comment" key={visibleMessage["time"]}>
                                <div className="content">
                                    <div className={visibleMessage["name"] === 'JaiKrishi' ? "right": "left"}>
                                        <div className="text">
                                        {visibleMessage["text"]}
                                        </div>
                                    </div>
                                </div>
                                {visibleMessage["image"] && <div className="image">
                                    <img src={visibleMessage["image"]} />
                                </div>}
                                <br />
                            </div>
                        )}
                        <form className="ui reply form" onSubmit={handleSubmit}>
                            <input name="text" type="text" placeholder="Reply..." value={text} onChange={e => setText(e.target.value)} />
                            <button className="ui button">Send</button>
                        </form>
                        <div className="menu">
                            <div className="ui simple dropdown item">
                                Preset Reponses <i className="dropdown icon"></i>
                                <div className="menu">
                                    {presetResponses && presetResponses[lastSelected] && Object.keys(presetResponses[lastSelected]).map(disease => 
                                        <p className="item" key={disease} onClick={() => setSelectedDisease(disease)}>{disease}</p>
                                    )}
                                </div>
                            </div>
                        </div>
                        <div className="ui relaxed divided list">
                            {presetResponses[lastSelected][selectedDisease] && presetResponses[lastSelected][selectedDisease].map(diseaseResponse => 
                                <p className="item" key={diseaseResponse} onClick={() => setText(diseaseResponse)}>
                                    {diseaseResponse}
                                </p>
                            )}
                        </div>
                    </div>
                :
                    <>
                        <h3 className="ui dividing header">Select a chat with {uid}</h3>
                    </>
                }
            </div>
        </>
    );
}

export default MessageDetail;