export function getUserInfo() {
    var user = sessionStorage.getItem("login-user");
    if(user) {
        try {
            user = JSON.parse(user);
        } catch(e) {
            user = '';   
        }
        
    }
    return user;
}