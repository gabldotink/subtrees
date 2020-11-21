if (process.env.NODE_ENV === "production") {
    const opt = require("./windows-opt.js");
    opt.main();
    module.exports = opt;
} else {
    var exports = window;
    exports.require = require("./windows-fastopt-entrypoint.js").require;
    window.global = window;

    const fastOpt = require("./windows-fastopt.js");
    fastOpt.main()
    module.exports = fastOpt;

    if (module.hot) {
        module.hot.accept();
    }
}
