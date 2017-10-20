var ContractFactory = artifacts.require("./ContractFactory.sol");
var CFToken =artifacts.require("./FCToken.sol");
var CCToken =artifacts.require("./CCToken.sol");
module.exports = function(deployer) {
    deployer.deploy(ContractFactory);
    deployer.deploy(CFToken);
    deployer.deploy(CCToken);
};