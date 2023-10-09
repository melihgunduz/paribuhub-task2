// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract RentalContract {

    uint256 counter;

    bytes32[] public PropertyIDs;
    
    struct Tenant {
        address _address;
        string name;
    }

    struct Property {
        Tenant tenant;
        address owner;
        string _type;
        string propertyAddress;
        bytes32 propertyID;
        uint256 startTime;
        uint256 endTime;
        bool active;
    }

    mapping(bytes32 => Property) public properties;
    mapping(address => Tenant) public tenants;

    event CreateRental(address indexed owner, string indexed _type, string indexed adres);
    event StartRental(uint256 startTime, uint256 endTime);
    event FinishRental(address indexed owner, address indexed Tenant, string indexed adres);

    modifier onlyOwner(bytes32 _propertyID) {
        require(msg.sender == properties[_propertyID].owner, "Only owner can run this function.");
        _;
    }

    modifier onlyTenant() {
        require(tenants[msg.sender]._address != address(0), "Only tenant can run this function.");
        _;
    }

    // Create property for rent
    function createProperty(string memory __type, string memory _adres) public  {
        bytes32 _propertyID = generateHash();

        properties[_propertyID].owner = msg.sender;
        properties[_propertyID]._type = __type;
        properties[_propertyID].propertyAddress = _adres;
        properties[_propertyID].propertyID = _propertyID;
        properties[_propertyID].active = true;

        PropertyIDs.push(_propertyID);
        emit CreateRental(msg.sender, __type,_adres);
    }

    // Start rental
    function startRental(string memory tenantName,bytes32 _propertyID, uint256 _startTime, uint256 _endTime) public {
        require(properties[_propertyID].active == true, "This property already in use.");
        require(_startTime < _endTime, "Start time must be small than end time.");

        properties[_propertyID].startTime = block.timestamp + _startTime;
        properties[_propertyID].endTime = block.timestamp + _endTime;
        properties[_propertyID].active = false;
        properties[_propertyID].tenant._address = msg.sender;
        properties[_propertyID].tenant.name = tenantName;
        emit StartRental(_startTime, _endTime);
    } 

    // Finish rental
    function finishRental(bytes32 _propertyID) external onlyOwner(_propertyID) {
        require(!properties[_propertyID].active, "This property is not rented.");
        require(properties[_propertyID].endTime < block.timestamp, "You can't finish rent now");

        Property storage property = properties[_propertyID];
        address TenantAdres = property.owner; // Geçici olarak sahibi al
        property.active = true;
        delete properties[_propertyID];

        emit FinishRental(msg.sender, TenantAdres, property.propertyAddress);
    }

    // generate uinque hash for property id
    function generateHash() private returns(bytes32) {
        counter += 1;
        return keccak256(abi.encodePacked(counter + block.timestamp)); // Hash generated and returned
    }

    // return all properties ids
    function getPropertyIDs() public view returns(bytes32[] memory) {
        return PropertyIDs;
    }

    function checkRentStatus(bytes32 propertyID) external view returns (bool) {
        return properties[propertyID].active && block.timestamp >= properties[propertyID].startTime && block.timestamp <= properties[propertyID].endTime;
    }

    function report() external onlyTenant {
        // reporting error situations
    }
}
