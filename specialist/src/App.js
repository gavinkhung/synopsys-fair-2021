import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';

import MessageList from './pages/messages/MessageList';
import MessageDetail from './pages/messages/MessageDetail';

import './assets/css/styles.css';

const App = () => {
    return(
        <Router>
            <Switch>
                <Route exact path="/" component={MessageList} />
                <Route exact path="/:uid/:token" component={MessageDetail} />
            </Switch>
        </Router>
    );
}

export default App;