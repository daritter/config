console.log("Adding KEK kds login callback");

function kds_login(details, callback) {
    var match = details.realm.match(/password:\s*(.*?)\s*\(/);
    if(match){
        var password = match[1].replace(" ", "");
        console.log("Logging in to kds with user 'kds', password '" + password + "'");
        callback({authCredentials: {username: "kds", password: password}});
    }else{
        console.error("Cannot find password in realm '" + details.realm + "'");
        callback();
    }
};

chrome.webRequest.onAuthRequired.addListener(kds_login, {urls: ["https://kds.kek.jp/*"]}, ["asyncBlocking"]);
