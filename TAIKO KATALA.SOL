// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


contract cryptoncalls {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    uint256 public maxAmountPerAddressPercentage;
    uint256 public maxAmountPerTransactionPercentage;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed account, uint256 amount);
    event OwnershipRenounced(address indexed previousOwner);
    event MaxAmountPerAddressSet(uint256 percentage);
    event MaxAmountPerTransactionSet(uint256 percentage);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        maxAmountPerAddressPercentage = 100; // 100% of total supply at first
        maxAmountPerTransactionPercentage = 100; // 100% of total supply at first
    }

    function setMaxAmountPerAddress(uint256 _percentage) public onlyOwner {
        require(_percentage <= 100, "Invalid percentage");
        maxAmountPerAddressPercentage = _percentage;
        emit MaxAmountPerAddressSet(_percentage);
    }

    function setMaxAmountPerTransaction(uint256 _percentage) public onlyOwner {
        require(_percentage <= 100, "Invalid percentage");
        maxAmountPerTransactionPercentage = _percentage;
        emit MaxAmountPerTransactionSet(_percentage);
    }

    function mint(address _recipient, uint256 _amount) public onlyOwner {
        require(_recipient != address(0), "Invalid recipient address");

        totalSupply += _amount;
        balanceOf[_recipient] += _amount;

        emit Mint(_recipient, _amount);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_value <= totalSupply * maxAmountPerTransactionPercentage / 100, "Exceeds maximum amount per transaction");
        require(balanceOf[_to] + _value <= totalSupply * maxAmountPerAddressPercentage / 100, "Exceeds maximum amount per address");

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
        require(balanceOf[_to] + _value <= totalSupply * maxAmountPerAddressPercentage / 100, "Exceeds maximum amount per address");

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}
