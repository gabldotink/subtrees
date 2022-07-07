module.exports = (app) => {
    app.on(
        [ "pull_request.opened", "pull_request.edited", "pull_request.synchronize", "pull_request.reopened" ], 
        async (context) => {
            
    });
};
