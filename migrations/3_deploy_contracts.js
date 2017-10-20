var CCTG = artifacts.require("CCTokenGenerator");
var FCTG =artifacts.require("FCTokenGenerator");
module.exports = function(deployer) {
    deployer.deploy(CCTG);
    deployer.deploy(FCTG);
};