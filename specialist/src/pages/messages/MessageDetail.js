import React, { useEffect, useState } from 'react';

import { useParams, Link } from 'react-router-dom';

import global from '../../services/global';
import { getThread } from '../../services/firebase';

const MessageDetail = (props) => {

    const { uid } = useParams();

    const [messages, setMessages] = useState([]);

    useEffect(() => {
        const fetchMessages = async () => {
            const fetchedThreads = await getThread(uid);
            await setMessages(fetchedThreads["messages"]);
        }
        fetchMessages();
    }, [])

    return (
        <>
            <Link to={"/"}>Back home</Link>
            <div className="ui container">
                {messages.length ?
                    <div className="ui comments">
                        <h3 className="ui dividing header">Messages with {uid}</h3>
                        {messages.map(message => 
                            <div className="comment">
                                <div className="content">
                                    <div className="text">
                                        {message}
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                :
                    <>
                        <h3 className="ui dividing header">No messages found with {uid}</h3>
                    </>
                }
            </div>
        </>
    );
}

export default MessageDetail;