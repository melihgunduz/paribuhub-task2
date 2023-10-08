//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ParibuHubTask2 {

    address public owner;

    //mapping (address => Property[]) public userProperties;

    Property[] public properties;

    uint256 public counter;

    struct Property {
        address customer;
        address owner;
        bytes32 id;
        string name;
        string _type;
        uint256 price;
    }

    constructor() {
        owner = msg.sender;
        counter = 0;
    }

    function createProperty (string memory _name, string memory __type, uint256 _price) public {
        bytes32 id = generateHash();
        Property memory property;
        property.owner = msg.sender;
        property.id = id;
        property.name = _name;
        property._type = __type;
        property.price = _price;
        properties.push(property);
    }

    function generateHash() private returns(bytes32) {
        counter += 1;
        return keccak256(abi.encodePacked(counter + block.timestamp)); // Hash generated and returned
    }

    receive() external payable {
        revert();
     }

}