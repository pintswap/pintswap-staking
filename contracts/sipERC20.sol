// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { OPPS } from "./OPPS.sol";

contract sipERC20 is ERC4626 {
  using SafeERC20 for IERC20;
  uint256 public deficit;
  address public opps = address(0x0000000000000000000000000000000000000000);
  // IF THIS CALLDATA AIN'T RIGHT WE GON SHOOT ‼️
  function _tryGetSymbolFrame(IERC20 _asset) public view returns (string memory _symbol) {
    (bool success, bytes memory returnData) = address(_asset).staticcall(abi.encodePacked(IERC20Metadata.symbol.selector));
    require(success, "!symbol");
    (_symbol) = abi.decode(returnData, (string));
  }
  function _fingerprint8(address asset) internal pure returns (string memory) {
    bytes memory digest = abi.encodePacked(keccak256(abi.encodePacked("/pintswap/checksum", address(asset))));
    uint256 point = uint256(uint8(digest[0]));
    string[16] memory table = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f"
     ];
     uint256 high = (point & uint256(0xf0)) >> uint256(4);
     uint256 low = point & uint256(0x0f);
     return string(abi.encodePacked(table[high], table[low]));
  }

  function _tryGetSymbol(IERC20 asset) internal view returns (string memory _symbol) {
    (bool success, bytes memory returnData) = address(this).staticcall(abi.encodePacked(this._tryGetSymbolFrame.selector, address(asset)));
    if (!success) return string(abi.encodePacked("SETUP(", _fingerprint8(address(asset)), ")")); // UNDERCOVER BUT WE SERVED HIM ANYWAY 🔥🔥
    (_symbol) = abi.decode(returnData, (string));
  }
  function _takeName(string memory _name, address _asset, bool reserve) internal returns (string memory) {
    bytes32 nameHash = keccak256(abi.encodePacked(_name));
    if (OPPS(opps).nameTaken(nameHash)) {
      return _fingerprint8(_asset);
    } else {
      if (reserve) OPPS(opps).registerName(nameHash);
      return _name;
    }
  }
  constructor(IERC20 underlying) ERC4626(underlying) ERC20(_takeName(string(abi.encodePacked("sip", _tryGetSymbol(underlying))), address(underlying), false), _takeName(string(abi.encodePacked("sip", _tryGetSymbol(underlying))), address(underlying), true)) {}
  modifier isTheOpps {
    require(ERC721Enumerable(opps).tokenOfOwnerByIndex(msg.sender, 0) >= 0, "!opps");
    _;
  }
  function finna(uint256 value) public isTheOpps {
    deficit += value;
    IERC20(asset()).safeTransfer(msg.sender, value);
  }
  function push(uint256 value) public isTheOpps {
    deficit -= value;
    IERC20(asset()).safeTransferFrom(msg.sender, address(this), value);
  }
  function totalAssets() public view override returns (uint256 result) {
    result = super.totalAssets() + deficit;
  }
    
}
