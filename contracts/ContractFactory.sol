pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/payment/PullPayment.sol';
import 'contract_store_api/contracts/Generatable.sol';

contract ContractFactory is Destructible,PullPayment{

    uint256 public diviRate;
    uint256 public developerTemplateAmountLimit;
    address public platformWithdrawAccount;


	struct userContract{
		string contractName;
		uint256 templateKey;
		address contractAddress;
	}

	struct contractTemplate{
		string templateName;
		address contractGeneratorAddress;
		address developerWithAddress;
		string abiStr;
	}

    mapping(address => userContract[]) public userContractsMap;
    mapping(uint256 => contractTemplate) public contractTemplateAddresses;
    mapping(uint256 => uint256) public skipMap;

    event ContractCreated(address indexed creator,string templateName,uint256 templateKey,address contractAddress);
    event ContractTemplatePublished(uint256 indexed distinctNeedAmountByWei,address  creator,string templateName,address contractGeneratorAddress);

    function ContractFactory(){
        //0~10
        diviRate=5;
        platformWithdrawAccount=0xbe62b2978bc887f0600a3ffc78b043b549e41e33;
        developerTemplateAmountLimit=500000000000000000;
    }

    //验证合约模板，只能是owner使用
    function verifyContractTemplate(uint256 key) public onlyOwner
    {
        //根据支付金额找到相应模板
        contractTemplate storage ct = contractTemplateAddresses[key];
        if(ct.contractGeneratorAddress!=0x0){
            address contractTemplateAddress = ct.contractGeneratorAddress;
            string templateName = ct.templateName;
            address developerWithAddress=ct.developerWithAddress;

            //找到相应生成器并生产目标合约
            Generatable generator = Generatable(contractTemplateAddress);
            address target = generator.generate(msg.sender);

            //记录用户合约
            userContract[] storage userContracts = userContractsMap[msg.sender];
            userContracts.push(userContract(templateName,key,target));
            }
    }

    function () payable external{
        //不存在忽略列表中才能继续
        require(skipMap[msg.value]==0);
        //根据支付金额找到相应模板
        contractTemplate storage ct = contractTemplateAddresses[msg.value];
        if(ct.contractGeneratorAddress!=0x0){
            address contractTemplateAddress = ct.contractGeneratorAddress;
            string templateName = ct.templateName;
            address developerWithAddress=ct.developerWithAddress;

            //找到相应生成器并生产目标合约
            Generatable generator = Generatable(contractTemplateAddress);
            address target = generator.generate(msg.sender);

            //记录用户合约
            userContract[] storage userContracts = userContractsMap[msg.sender];
            userContracts.push(userContract(templateName,msg.value,target));

            //开发者分成
            //按分成比例计算分成
            if(diviRate==0){
                 asyncSend(platformWithdrawAccount,msg.value);
            }else{
                uint256 developerAmount=msg.value.mul(diviRate).div(10);
                uint256 platformAmount=msg.value.sub(developerAmount);
                asyncSend(developerWithAddress,developerAmount);
                asyncSend(platformWithdrawAccount,platformAmount);
            }
            ContractCreated(msg.sender,templateName,msg.value,target);
        }else{
            revert();
        }
    }

    /**
    *生成器实现Generatable接口,并且合约实现了ownerable接口，都可以通过此函数上传（TODO：如何校验？）
    */
    function publishContractTemplate(uint256 distinctNeedAmountByWei, string _templateName,address _contractGeneratorAddress,address _developerWithAddress,string _abiStr) public
    {
         //非owner，不允许发布0.5eth以下的模板
         if(msg.sender!=owner){
            require(distinctNeedAmountByWei > developerTemplateAmountLimit);
         }

         contractTemplate storage ct = contractTemplateAddresses[distinctNeedAmountByWei];
         if(ct.contractGeneratorAddress!=0x0){
            revert();
         }else{
            ct.templateName=_templateName;
            ct.contractGeneratorAddress=_contractGeneratorAddress;
            ct.developerWithAddress=_developerWithAddress;
            ct.abiStr=_abiStr;
            ContractTemplatePublished(distinctNeedAmountByWei,msg.sender,_templateName,_contractGeneratorAddress);
         }
    }

    function queryPublishedContractTemplate(uint256 distinctNeedAmountByWei) public constant returns(string,address,address,string) {
        contractTemplate storage ct = contractTemplateAddresses[distinctNeedAmountByWei];
        if(ct.contractGeneratorAddress!=0x0){
            return (ct.templateName,ct.contractGeneratorAddress,ct.developerWithAddress,ct.abiStr);
        }else{
            return ('',0x0,0x0,'');
        }
    }

    function queryUserContract(address user,uint256 _index) public constant returns(string,uint256,address){
        userContract[] storage ucs = userContractsMap[user];
        return (ucs[_index].contractName,ucs[_index].templateKey,ucs[_index].contractAddress);
    }

    function queryUserContractCount(address user) public constant returns (uint256){
        userContract[] storage ucs = userContractsMap[user];
        return ucs.length;
    }

    function changeDiviRate(uint256 _diviRate) external onlyOwner(){
        diviRate=_diviRate;
    }

    function changePlatformWithdrawAccount(address _platformWithdrawAccount) external onlyOwner(){
        platformWithdrawAccount=_platformWithdrawAccount;
    }

    function changeDeveloperTemplateAmountLimit(uint256 _developerTemplateAmountLimit) external onlyOwner(){
        developerTemplateAmountLimit=_developerTemplateAmountLimit;
    }
    function addSkipPrice(uint256 price) external onlyOwner(){
        skipMap[price]=1;
    }

    function removeSkipPrice(uint256 price) external onlyOwner(){
        skipMap[price]=0;
    }
}

