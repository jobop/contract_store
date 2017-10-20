'use strict';

var ContractFactory= artifacts.require("./ContractFactory.sol");
var CCTokenGenerator= artifacts.require("CCTokenGenerator");
const assertJump=require('zeppelin-solidity/test/helpers/assertJump');

const CCToken=artifacts.require("CCToken");

const  Ownable= artifacts.require("zeppelin-solidity/contracts/ownership/Ownable");


async function setup_ContractFactory(accounts) {

    let cf=await ContractFactory.new({from:accounts[0]});
    let cctg=await CCTokenGenerator.new({from:accounts[0]});
    await cf.publishContractTemplate(100000000000000000, "testContract",cctg.address,accounts[1],"123");
    return cf;
}

function ether_towei_rate(value){
    return web3.toWei(value,'ether');
}

contract('ContractFactory', function (accounts) {
        it("成功生成合约",async function () {
            let cf= await setup_ContractFactory(accounts);

            let contractTemplate= await cf.queryPublishedContractTemplate(100000000000000000);
            console.info(contractTemplate[0]+contractTemplate[1]+contractTemplate[2]+contractTemplate[3]);

            await cf.sendTransaction({from:accounts[5],value:100000000000000000});
            let newContract=await cf.queryUserContract(accounts[5],0);
            console.info(newContract[2]);
            console.info(accounts[0]);
            // let ucc=await cf.queryUserContractCount(account[5]);
            // console.info(ucc);


        });

})