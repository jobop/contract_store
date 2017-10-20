var ContractFactory = artifacts.require("./ContractFactory.sol");
module.exports = function(deployer) {
    deployer.deploy(ContractFactory);
};