importScripts("https://www.gstatic.com/firebasejs/7.23.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.23.0/firebase-messaging.js");
firebase.initializeApp({
    apiKey: "AIzaSyD6KlWQgZtGhRSIC3dbgDU7P21rqMKSjL4",
        authDomain: "bookdoctorappointment-ac303.firebaseapp.com",
        databaseURL: "https://bookdoctorappointment-ac303.firebaseio.com",
        projectId: "bookdoctorappointment-ac303",
        storageBucket: "bookdoctorappointment-ac303.appspot.com",
        messagingSenderId: "1097653836729",
        appId: "1:1097653836729:web:7fc4f2138a56e8a32ab468",
        measurementId: "G-9NL05ECN74"
});
const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});