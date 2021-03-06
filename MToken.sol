pragma solidity ^0.4.16;

import "./IERC223.sol";
import "./IERC223ReceivingContract.sol";
import "./LSafeMath.sol";
import "./LContractReceiver.sol";

contract Token is ERC223 {
	
	string  tokenName;
    string public tokenSymbol;
	uint8 public tokenDecimals;
	
	address creator;
	uint public totalSupply;
	
    using SafeMath for uint;
	
	mapping (address => uint256) public balances;
	
	event Transfer(address indexed from, address indexed to, uint value, bytes data);
	
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }
    
    /**
	 * constructor
	 * parameters - for eg. "GIG9", "GIG", 8, "0xC7B38600299ab2657c6F341310DAdD9E1ba7398a", 268000000
     */

	function Token(string _tokenName, string _tokenSymbol, uint8 _tokenDecimals, address _creator, uint _totalSupply) public payable{
	
		tokenName = _tokenName;
		tokenSymbol = _tokenSymbol;
		tokenDecimals = _tokenDecimals;
		
		creator = _creator;
		
		totalSupply = _totalSupply;
		
		balances[creator] = _totalSupply;
		totalSupply = _totalSupply;	
	}
	
	function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
      
		if(isContract(_to)) {
			if (balanceOf(msg.sender) < _value) revert();
			balances[msg.sender] = SafeMath.sub(balanceOf(msg.sender), _value);
			balances[_to] = SafeMath.add(balanceOf(_to), _value);
			assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
			Transfer(msg.sender, _to, _value, _data);
			return true;
		}
		else {
			return transferToAddress(_to, _value, _data);
		}
	}
  
	function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
		  
		if(isContract(_to)) {
			return transferToContract(_to, _value, _data);
		}
		else {
			return transferToAddress(_to, _value, _data);
		}
	}
  
	function transfer(address _to, uint _value) public returns (bool success) {
      
		bytes memory empty;

		if(isContract(_to)) {
			return transferToContract(_to, _value, empty);
		}
		else {
			return transferToAddress(_to, _value, empty);
		}
	}

	function isContract(address _addr) private view returns (bool is_contract) {
		
		uint length;
		
		assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
		}
      
		return (length>0);
    }

	function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
	
		if (balanceOf(msg.sender) < _value) revert();
		
		balances[msg.sender] = SafeMath.sub(balanceOf(msg.sender), _value);
		balances[_to] = SafeMath.add(balanceOf(_to), _value);
		
		Transfer(msg.sender, _to, _value, _data);
		
		return true;
	}
  
	function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
		
		if (balanceOf(msg.sender) < _value) revert();
		
		balances[msg.sender] = SafeMath.sub(balanceOf(msg.sender), _value);
		balances[_to] = SafeMath.add(balanceOf(_to), _value);
		ContractReceiver receiver = ContractReceiver(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		Transfer(msg.sender, _to, _value, _data);
		return true;
	}
	
    function teamTransfer(uint amount) isCreator public{
		balances[msg.sender] = SafeMath.sub(balances[msg.sender], amount);
        transfer(msg.sender, amount);
    }
	
	function burnToken() isCreator public{
        balances[msg.sender] = 0;
    }
    
	function removeContract() isCreator public{
		selfdestruct(msg.sender);	
    }

  function getCreator() public view returns (address){
      return creator;
  }
    
    modifier isCreator() {
		require(msg.sender == creator) ;
        _;		
    }
  function name() public view returns (string _name){
      return tokenName;
  }
  
  function symbol() public view returns (string _symbol){
      return tokenSymbol;
  }
  
  function decimals() public view returns (uint8 _decimals){
      return tokenDecimals;
  }
  
  function totalSupply() public view returns (uint256 _supply){
      return totalSupply;
  }
}