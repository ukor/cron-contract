// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/*
    ## Overview

    Accept ETH from users, deduct 0.25% from the value sent
    store the new amount in the smart contract (valut).
    It emits an event for every new storage to the valut
    When the lock time elapses, the stored value is sent to the intended recipient

    The smart contract is uses an admin priviliage to prevent anyone from sending ETH out.
    Only the smart contract creator has priviliage to send ETH out.
*/

contract CronContract {
    // locks sending ether out of contract(vault) to this admin addreess
    address public admin;

    uint256 internal feePercentage;

    // address to pay fee to
    address payable internal feeAddress;

    constructor(address _feeAddress) {
        admin = msg.sender;
        // 0.25% of value stored in the contract
        feePercentage = 25;
        feeAddress = payable(_feeAddress);
    }

    // balances of sender
    mapping(address => uint256) internal balances;

    struct Keeper {
        address sender;
        uint256 value;
        address recipient;
        uint256 dateLocked;
        uint256 lockUntill;
    }

    event NewKeeper(
        address indexed sender,
        uint256 value,
        address indexed recipient,
        uint256 dateLocked, // block.timestamp
        uint256 indexed lockUntill, // timestamp (millisecond)
        bytes32 hash
    );

    mapping(bytes32 => Keeper) internal keepers;

    // recieves ether from recipient
    function vault(address _recipient, uint256 _lockTime) external payable {
        uint256 fee = calculateFee(msg.value);
        uint256 value = deductFeeFromValue(msg.value);
        balances[msg.sender] += value;

        bytes32 hash = makeHash(msg.sender, _recipient, _lockTime);

        // register keeper
        keepers[hash] = (Keeper(msg.sender, value, _recipient, block.timestamp, _lockTime));

        feeAddress.transfer(fee);
        emit NewKeeper(msg.sender, value, _recipient, block.timestamp, _lockTime, hash);
    }

    function calculateFee(uint256 _valueSent) public view largerThen10000wie(_valueSent) returns (uint256) {
        uint256 fee = (_valueSent * feePercentage) / 10000;

        return fee;
    }

    function deductFeeFromValue(uint256 _valueSent) public view largerThen10000wie(_valueSent) returns (uint256) {
        uint256 _value = _valueSent - calculateFee(_valueSent);

        return _value;
    }

    function makeHash(
        address _sender,
        address _recipient,
        uint256 _lockTime
    ) internal pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encode(_sender, _recipient, _lockTime));

        return hash;
    }

    /// Returns sender balance
    function balanceOf() external view returns (uint256) {
        return balances[msg.sender];
    }

    /// Returns balance in the valut after fee has been deducted
    function balanceOfValut() external view returns (uint256) {
        return address(this).balance;
    }

    /// Returns  the balnce of the address fees are been paid to
    /// restricted to onlyAdmin
    function balanceOfFeeAddress() external view onlyAdmin returns (uint256) {
        return address(feeAddress).balance;
    }

    /// Returns the record of a keeper
    function getKeeper(bytes32 _hash) external view returns (Keeper memory) {
        return keepers[_hash];
    }

    /// withdraw from the valut. Restricted to onlyAdmin
    function withdraw(bytes32 _hash) external onlyAdmin {
        address payable recipient = payable(keepers[_hash].recipient);
        uint256 value = keepers[_hash].value;

        _withdrawFromValut(recipient, value);
    }

    // transfer ether from this smart contract to recipient
    function _withdrawFromValut(address payable _recipient, uint256 _value) internal {
        _recipient.transfer(_value);
    }

    modifier largerThen10000wie(uint256 _value) {
        require((_value / 10000) * 10000 == _value, 'Amount is too low.');
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, 'Only admin can withdraw');

        _;
    }
}
