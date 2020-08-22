import React, { useEffect, useState, useReducer } from 'react';
import { useParams, Link } from 'react-router-dom';

import { v4 as uuidv4 } from 'uuid';

import { getThreadRef, sendMessage } from '../../services/firebase';

const MessageDetail = (props) => {

    const reducer = (state, action) => {
        switch(action.type){
            case 'filter':
                return messages.filter(visibleMessage => visibleMessage.type === action.payload );
            default:
                return state;
        }
    }    

    const { uid } = useParams();

    const [lastSelected, setLastSelected] = useState("");
    const [messages, setMessages] = useState([]);
    const [text, setText] = useState("");

    const [visibleMessages, dispatch] = useReducer(reducer, []);
    
    useEffect(() => {
        const unsubscribe = getThreadRef(uid).onSnapshot(querySnapshot => {
            const threadMessages = [];
            querySnapshot.forEach(messsage => {
                const messageData = messsage.data();
                threadMessages.push({
                    text: messageData["text"],
                    time: messageData["createdAt"],
                    image: messageData["image"],
                    type: "hello"
                });
            });
            setMessages(threadMessages);
        });

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
            video: null
        }
        await sendMessage(uid, message);
        setText("");
    }

    return (
        <>
            <Link to={"/"}>Back home</Link>
            {/* <button onClick={() => dispatch(rice)}></button> */}
            <div className="ui container">
                <>
                    <button onClick={() => setLastSelected('hello')}>set to hello</button>
                    <button onClick={() => setLastSelected('')}>set to ""</button>
                </>
                {visibleMessages.length ?
                    <div className="ui comments">
                        <h3 className="ui dividing header">Messages with {uid}</h3>
                        {/* {messages.map(message => 
                            <div className="comment" key={message["time"]}>
                                <div className="content">
                                    <div className="text">
                                        {message["text"]}
                                    </div>
                                    {message["image"] && <div className="image">
                                        <img src={message["image"]} />
                                    </div>}
                                </div>
                            </div>
                        )} */}
                        {visibleMessages.map(visibleMessage => 
                            <div className="comment" key={visibleMessage["time"]}>
                                <div className="content">
                                    <div className="text">
                                        {visibleMessage["text"]}
                                    </div>
                                    {visibleMessage["image"] && <div className="image">
                                        <img src={visibleMessage["image"]} />
                                    </div>}
                                </div>
                            </div>
                        )}
                        <form className="ui reply form" onSubmit={handleSubmit}>
                            <input name="text" type="text" placeholder="Reply..." value={text} onChange={e => setText(e.target.value)} />
                            <button>Send</button>
                        </form>
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