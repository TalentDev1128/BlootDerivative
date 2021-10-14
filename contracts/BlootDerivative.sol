// SPDX-License-Identifier: MIT
pragma solidity ^0.6.5;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BlootDerivative is ERC721Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter internal toyTokenIDs;
    CountersUpgradeable.Counter internal paintingTokenIDs;
    CountersUpgradeable.Counter internal statuetteTokenIDs;

    uint256 internal toyTokenIDBase;
    uint256 internal paintingTokenIDBase;
    uint256 internal statuetteTokenIDBase;

    address internal _owner;
    bool public isOpenPayment;

    mapping(address => uint256) internal addressToClaimedToy;
    mapping(address => uint256) internal addressToClaimedPainting;
    mapping(address => uint256) internal addressToClaimedStatteute;

    mapping(address => uint256) internal addressToMigratedCameo;
    mapping(address => uint256) internal addressToMigratedHonorary;
    
    mapping(address => uint256) internal addressToRoyalty;
    ERC721 blootNFT;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function initialize() initializer external {
        __ERC721_init("BlootDerivative", "BlootDerivative");
        _owner = msg.sender;

        toyTokenIDBase = 0;
        paintingTokenIDBase = 300;
        statuetteTokenIDBase = 400;
        blootNFT = ERC721(0xCAccb157236B0969fe21eb486f2Bc5dc0662a5c5);
    }

    function claim(uint256 _category, uint256 _count) external payable {
        require(_category >= 1, "out of range");
        require(_category <= 3, "out of range");
        
        uint256 totalDerivative = getTotalDerivative(msg.sender, _category);
        if (_category == 1)
            totalDerivative += addressToMigratedCameo[msg.sender];
        else if (_category == 2)
            totalDerivative += addressToMigratedHonorary[msg.sender];

        require(totalDerivative >= _count, "claim count mismatch");

        uint256 tokenID = 0;
        if (_category == 1)
            require(totalDerivative >= addressToClaimedToy[msg.sender] + _count, "already claimed toy");
        else if (_category == 2)
            require(totalDerivative >= addressToClaimedPainting[msg.sender] + _count, "already claimed painting");
        else if (_category == 3)
            require(totalDerivative >= addressToClaimedStatteute[msg.sender] + _count, "already claimed statteute");
    
        for (uint8 i = 0; i < _count; i++) {
            if (_category == 1) {
                toyTokenIDs.increment();
                tokenID = toyTokenIDs.current() + toyTokenIDBase;
            } else if (_category == 2) {
                paintingTokenIDs.increment();
                tokenID = paintingTokenIDs.current() + paintingTokenIDBase;
            } else if (_category == 3) {
                statuetteTokenIDs.increment();
                tokenID = statuetteTokenIDs.current() + statuetteTokenIDBase;
            }
            _safeMint(msg.sender, tokenID);
            _setTokenURI(tokenID, uint2str(tokenID));
        }

        if (_category == 1)
            addressToClaimedToy[msg.sender] += _count;
        else if (_category == 2)
            addressToClaimedPainting[msg.sender] += _count;
        else if (_category == 3)
            addressToClaimedStatteute[msg.sender] += _count;
    }

    function getTotalDerivative(address _claimer, uint256 _category) internal view returns(uint256) {
        uint256 result = 0;
        if (blootNFT.balanceOf(msg.sender) == 0)
            return result;
        uint256 tokenIdMin;
        uint256 tokenIdMax;
        if (_category == 1) {
            tokenIdMin = 4790;
            tokenIdMax = 4962;
        } else if (_category == 2) {
            tokenIdMin = 4963;
            tokenIdMax = 5000;
        } else if (_category == 3) {
            tokenIdMin = 1;
            tokenIdMax = 1484;
        }

        for (uint256 i = 0; i < blootNFT.balanceOf(msg.sender); i++) {
            uint256 tokenId = blootNFT.tokenOfOwnerByIndex(_claimer, i);
            if (tokenId >= tokenIdMin && tokenId <= tokenIdMax)
                result ++;
        }
        return result;
    }

    function setBatchMigratedCameo(address[] calldata _whitelist, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            addressToMigratedCameo[_whitelist[i]] += 1;
        }
    }

    function setBatchMigratedHonorary(address[] calldata _whitelist, uint256 _count) external onlyOwner {
        for (uint256 i = 0; i < _count; i++) {
            addressToMigratedHonorary[_whitelist[i]] += 1;
        }
    }

    function setMigratedCameo(address _person, uint256 _count) external onlyOwner {
        addressToMigratedCameo[_person] += _count;
    }

    function setMigratedHonorary(address _person, uint256 _count) external onlyOwner {
        addressToMigratedHonorary[_person] += _count;
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        super._setBaseURI(_baseURI);
    }

    function setTokenURI(uint256 _tokenID, string calldata _tokenURI) external onlyOwner {
        super._setTokenURI(_tokenID, _tokenURI);
    }

    function openPayment(bool _open) external onlyOwner {
        isOpenPayment = _open;
    }

    function setRoyalty(address _person, uint256 _amount) external onlyOwner {
        addressToRoyalty[_person] = _amount;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = _owner.call{value: address(this).balance}("");
        require(success, "Failed to send");
    }

    function withdrawRoyalty() external {
        require(isOpenPayment == true, "Payment is closed");
        require(addressToRoyalty[msg.sender] > 0, "You don't have any royalties");
        require(address(this).balance >= addressToRoyalty[msg.sender], "Insufficient balance in the contract");
        require(msg.sender != address(0x0), "invalid caller");

        (bool success, ) = msg.sender.call{value: addressToRoyalty[msg.sender]}("");
        require(success, "Failed to send eth");
        addressToRoyalty[msg.sender] = 0;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}