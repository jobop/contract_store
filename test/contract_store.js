'use strict';

var ContractFactory= artifacts.require("./ContractFactory.sol");
var CCTokenGenerator= artifacts.require("CCTokenGenerator");

var TTokenGenerator= artifacts.require("TTokenGenerator");

var FCTokenGenerator= artifacts.require("FCTokenGenerator");

const assertJump=require('zeppelin-solidity/test/helpers/assertJump');

const CCToken=artifacts.require("CCToken");

const  Ownable= artifacts.require("zeppelin-solidity/contracts/ownership/Ownable");


async function setup_ContractFactory(accounts) {

    let cf=await ContractFactory.new({from:accounts[0]});
    let cctg=await CCTokenGenerator.new({from:accounts[0]});

    let ttg=await TTokenGenerator.new({from:accounts[0]});
    let fcg=await FCTokenGenerator.new({from:accounts[0]});

    await cf.publishContractTemplate(500000000000000000, "CCTContract",cctg.address,accounts[1],"123");
    
    await cf.publishContractTemplate(100000000000000000, "TestContract",ttg.address,accounts[1],"123");
    await cf.publishContractTemplate(1000000000000000000, "FCTContract",fcg.address,accounts[1],"123");
    
    return cf;

}

function ether_towei_rate(value){
    return web3.toWei(value,'ether');
}

contract('ContractFactory', function (accounts) {
        it("成功生成cct合约",async function () {
            let cf= await setup_ContractFactory(accounts);

            let contractTemplate= await cf.queryPublishedContractTemplate(500000000000000000);
            console.info("####"+contractTemplate[0]+contractTemplate[1]+contractTemplate[2]+contractTemplate[3]);

            await cf.sendTransaction({from:accounts[5],value:500000000000000000});
            let newContract=await cf.queryUserContract(accounts[5],0);
            console.info(newContract[2]);
            console.info(accounts[0]);
            let ucc=await cf.queryUserContractCount(accounts[5]);
            console.info(ucc);


        });

        it("成功生成测试合约",async function () {
            let cf= await setup_ContractFactory(accounts);

            let contractTemplate= await cf.queryPublishedContractTemplate(100000000000000000);
            console.info("####"+contractTemplate[0]+contractTemplate[1]+contractTemplate[2]+contractTemplate[3]);

            await cf.sendTransaction({from:accounts[5],value:100000000000000000});
            let newContract=await cf.queryUserContract(accounts[5],0);
            console.info(newContract[2]);
            console.info(accounts[0]);
            let ucc=await cf.queryUserContractCount(accounts[5]);
            console.info(ucc);


        });
        
        it("成功生成fct合约",async function () {
            let cf= await setup_ContractFactory(accounts);

            let contractTemplate= await cf.queryPublishedContractTemplate(1000000000000000000);
            console.info("####"+contractTemplate[0]+contractTemplate[1]+contractTemplate[2]+contractTemplate[3]);

            await cf.sendTransaction({from:accounts[5],value:1000000000000000000});
            let newContract=await cf.queryUserContract(accounts[5],0);
            console.info(newContract[2]);
            console.info(accounts[0]);
            let ucc=await cf.queryUserContractCount(accounts[5]);
            console.info(ucc);


        });        

})