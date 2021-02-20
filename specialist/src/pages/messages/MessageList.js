import React, { useEffect } from 'react';
import { useState } from 'react';

import { Link } from 'react-router-dom';

import { getThreadNames } from '../../services/firebase';

const MessageList = (props) => {

    const [threads, setThreads] = useState([]);

    useEffect(() => {
        const setup = async () => {
            const fetchedThreads = await getThreadNames();
            await setThreads(fetchedThreads);
        }
        setup();
    }, [])

    return (
        <>
            <div className="ui container">
                <h1 className="ui huge header">Chats</h1>
                <div className="ui relaxed divided list">
                    {threads.length ?
                        threads.map(thread =>
                            <div className="item" key={thread.uid}>
                                <div className="content">
                                    <Link className="header" to={`${thread.uid}/${thread.token}`}>
                                        {`${thread.uid} `}
                                        {!thread.read &&
                                            <a class="ui red horizontal label">New Message</a>
                                        }
                                    </Link>
                                </div>
                            </div>
                        )
                    :
                        <p>loading</p>
                    }
                </div>
            </div>
        </>
    );
}

export default MessageList;