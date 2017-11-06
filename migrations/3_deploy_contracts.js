var TTG = artifacts.require("TTokenGenerator");
var FCTG =artifacts.require("FCTokenGenerator");
module.exports = function(deployer) {
    deployer.deploy(TTG);
    deployer.deploy(FCTG);
};