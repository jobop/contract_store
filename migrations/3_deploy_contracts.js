var CCTG = artifacts.require("CCTokenGenerator");
var FCTG =artifacts.require("FCTokenGenerator");
var CCToken =artifacts.require("./CCToken.sol");
module.exports = function(deployer) {
    deployer.deploy(CCTG);
    deployer.deploy(FCTG);
};