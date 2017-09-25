pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'contract_store_api/contracts/Generatable.sol';
contract ContractFactory is Destructible {


	struct userContract{
		string contractName;
		address contractAddress;
	}

	struct contractTemplate{
		string contractName;
		address contractGeneratorAddress;
	}

    mapping(address => userContract[]) public userContracts;
    mapping(uint256 => contractTemplate) public contractTemplateAddresses;

    event ContractCreated(address indexed creator,address contractAddress);

    function ContractFactory(){
    }

    function creditSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        CreditContractTemplate target = new CreditContractTemplate();
        target.setBaseInfo(msg.sender,0x0,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate,crcTokenAddress,tokenPriceManagerAddress);
        address[] storage contracts = creditSideContracts[msg.sender];
        contracts.push(target);
        CreditContractCreated(1,msg.sender,target);
        return target;
    }


    function debitSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        CreditContractTemplate target = new CreditContractTemplate();
        target.setBaseInfo(0x0,msg.sender,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate,crcTokenAddress,tokenPriceManagerAddress);
        address[] storage contracts = debitSideContracts[msg.sender];
        contracts.push(target);
        CreditContractCreated(2,msg.sender,target);
        return target;
    }


    function queryCreditSideContract(address _creditSide)  constant public returns(address[]){
        return creditSideContracts[_creditSide];
    }

    function queryDebitSideContract(address _debitSide)  constant public returns(address[]){
        return debitSideContracts[_debitSide];
    }

    function changeCrcTokenAddress(address _crcTokenAddress) external onlyOwner(){
        crcTokenAddress=_crcTokenAddress;
    }

    function changeTokenPriceManagerAddress(address _tokenPriceManagerAddress) external onlyOwner(){
        tokenPriceManagerAddress=_tokenPriceManagerAddress;
    }
}

