// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;
/*
    ## Overview

    Accept ETH from users and store them in the smart contract (valut).
    It emits an event for every new storage to the valut
    When the lock time elapses, the stored value is sent to the intended recipient

    The smart contract is uses an admin priviliage to prevent anyone from sending ETH out.
    Only the smart contract creator has priviliage to send ETH out.
*/

contract CronContract {

    // locks sending ether out of contract(vault) to this admin addreess
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    // balances of sender
    mapping(address => uint)  balances;

    struct Keeper {
        address sender;
        uint value;
        address recipient;
        uint dateLocked;
        uint lockUntill;
    }

    event newKeeper(
        address indexed sender,
        uint value,
        address indexed recipient,
        uint dateLocked,            // block.timestamp
        uint indexed lockUntill,  // timestamp (millisecond)
        bytes32 hash
    );

    mapping(bytes32 => Keeper) internal keepers;

    // recieves ether from recipient
    function vault(address _recipient, uint _lockTime) external payable {

        balances[msg.sender]  += msg.value;

        bytes32 hash = makeHash(msg.sender, _recipient,  _lockTime);

        // register keeper
        keepers[hash] = (Keeper(msg.sender, msg.value, _recipient, block.timestamp, _lockTime));

        emit newKeeper(msg.sender, msg.value, _recipient, block.timestamp, _lockTime, hash);
    }


    function makeHash(address _sender, address _recipient, uint _lockTime) internal pure returns(bytes32){
        bytes32 hash = keccak256(abi.encode(_sender, _recipient, _lockTime));

        return hash;
    }

    // sender balance
    function balance() external view returns(uint){
        return balances[msg.sender];
    }


    function balanceOfValut() external view returns(uint){
        return address(this).balance;
    }

    function getKeeper(bytes32 _hash) external view returns(Keeper memory){
        return keepers[_hash];
    }

    function withdraw(bytes32 _hash) external {
        require(msg.sender == admin, 'Only admin can withdraw from valut');

        address payable recipient = payable(keepers[_hash].recipient);
        uint value = keepers[_hash].value;

        _withdrawFromValut(recipient,  value);
    }

    // transfer ether from this smart contract to recipient
    function _withdrawFromValut(address payable _recipient, uint  _value) internal {

        _recipient.transfer(_value);
    }
}
