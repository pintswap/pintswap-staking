// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import { ERC721Permit } from "./erc721/ERC721Permit.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract OPPS is ERC721Permit, Ownable {
  mapping (uint256 => uint256) public nonces;
  function version() public pure returns (string memory) { return "1"; }
  string private __baseURI;
  constructor() ERC721Permit("OPPS", "OPPS", "1") Ownable() {
    setBaseURI("ipfs://bafybeiezpbqq6favps74erwn35ircae2xqqdmczxjs7imosdkn6ahmuxme/");
  }
  function _baseURI() view internal override returns (string memory) {
    return __baseURI;
  }
  function _getAndIncrementNonce(uint256 _tokenId) internal override virtual returns (uint256) {
    uint256 nonce = nonces[_tokenId];
    nonces[_tokenId]++;
    return nonce;
  }
  function setBaseURI(string memory _uri) public onlyOwner {
    __baseURI = _uri;
  }
  function mint(address _to, uint256 _tokenId) public onlyOwner {
    _mint(_to, _tokenId);
  }
}
