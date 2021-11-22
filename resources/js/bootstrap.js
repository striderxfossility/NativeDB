window._ = require('lodash');

/**
 * We'll load the axios HTTP library which allows us to easily issue requests
 * to our Laravel back-end. This library automatically handles sending the
 * CSRF token as a header based on the value of the "XSRF" token cookie.
 */

window.axios = require('axios');

window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

/**
 * Echo exposes an expressive API for subscribing to channels and listening
 * for events that are broadcast by Laravel. Echo and event broadcasting
 * allows your team to easily build robust real-time web applications.
 */

import Echo from 'laravel-echo';

window.Pusher = require('pusher-js');

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: process.env.MIX_PUSHER_APP_KEY,
    encrypted: true,
    cluster: process.env.MIX_PUSHER_APP_CLUSTER,
    forceTLS: true,
    authEndpoint: "/broadcasting/auth",
    auth: {
        headers: {
            'X-CSRF-TOKEN': '{{ csrf_token() }}',
        }
    }
});

const userid = document.head.querySelector('meta[name="user-id"').content;

window.Echo.private('users.' + userid).listen('.Illuminate\\Notifications\\Events\\BroadcastNotificationCreated', (e) => {
    if(e.error) {
    	toastr.error(e.error);
    } else {
	    toastr.success(e.message);
	}
});
