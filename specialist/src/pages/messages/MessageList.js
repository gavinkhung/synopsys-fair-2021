import React, { useEffect } from 'react';
import { useState } from 'react';

import { Link } from 'react-router-dom';

import global from '../../services/global';
import { getThreadNames } from '../../services/firebase';

const MessageList = (props) => {

    const [threads, setThreads] = useState([]);

    useEffect(() => {
        const fetchMessages = async () => {
            const fetchedThreads = await getThreadNames();
            await setThreads(fetchedThreads);
        }
        fetchMessages();
    }, [])

    console.log(threads);
    console.log(threads.length);

    return (
        <>
            <h1>all chats</h1>
            <div className="ui relaxed divided list">
                {threads.length ?
                    threads.map(thread => 
                        <div className="item" key={thread.uid}>
                            <div className="content">
                                <Link className="header" to={`${thread.uid}/${thread.token}`}>{thread.uid}</Link>
                            </div>
                        </div>
                    )
                :
                    <p>loading</p>
                }
            </div>
        </>
    );
}

export default MessageList;