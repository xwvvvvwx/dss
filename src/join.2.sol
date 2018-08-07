// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

interface AdapterI {
  function join(uint256 wad) external;
  function vat() external returns (address);
  function gem() external returns (address);
  function exit(uint256 wad) external;
  function ilk() external returns (bytes32);
}

contract Adapter {
  constructor (address vat_, bytes32 ilk_, address gem_) public {
    assembly {
      codecopy(0, sub(codesize, 96), 96)

      // set vat = vat_
      sstore(0, mload(0))

      // set ilk = ilk_
      sstore(1, mload(32))

      // set gem = gem_
      sstore(2, mload(64))
    }
  }   
  function () public {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if lt(sig, 0x7bd2bea7/*   function gem() external returns (address); */) {
	if eq(sig, 0x049878f3 /*   function join(uint256 wad) external; */) {
          
          // iff int(wad) >= 0
          if slt(calldataload(4), 0) { revert(0, 0) }
          
          // put bytes4(keccak256("move(address,address,uint256)")) << 28 bytes
          mstore(0, 0xbb35783b00000000000000000000000000000000000000000000000000000000)
          // put msg.sender
          mstore(4, caller)
          // put this
          mstore(36, address)
          // put wad
          mstore(68, calldataload(4))
          // iff gem.move(msg.sender, this, wad) != 0
          if iszero(call(gas, sload(2), 0, 0, 100, 0, 0)) { revert(0, 0) }
          
          // put bytes4(keccak256("slip(bytes32,address,int256)")) << 28 bytes
          mstore(0, 0x7cdd3fde00000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, sload(1))
          // put msg.sender
          mstore(36, caller)
          // put wad
          mstore(68, calldataload(4))
          // iff vat.slip(ilk, msg.sender, wad) != 0
          if iszero(call(gas, sload(0), 0, 0, 100, 0, 0)) { revert(0, 0) }
          
          stop()
        }
        if eq(sig, 0x36569e77 /*   function vat() external returns (address); */) {
          mstore(64, sload(0))
          return(64, 32)
        }
      }
      if eq(sig, 0x7bd2bea7 /*   function gem() external returns (address); */) {
        mstore(64, sload(2))
        return(64, 32)
      }
      if eq(sig, 0x7f8661a1 /*   function exit(uint256 wad) external; */) {
        
        // iff int(wad) >= 0
        if slt(calldataload(4), 0) { revert(0, 0) }
        
        // put bytes4(keccak256("move(address,address,uint256)")) << 28 bytes
        mstore(0, 0xbb35783b00000000000000000000000000000000000000000000000000000000)
        // put this
        mstore(4, address)
        // put msg.sender
        mstore(36, caller)
        // put wad
        mstore(68, calldataload(4))
        // iff gem.move(this, msg.sender, wad) != 0
        if iszero(call(gas, sload(2), 0, 0, 100, 0, 0)) { revert(0, 0) }

        // put bytes4(keccak256("slip(bytes32,address,int256)")) << 28 bytes
        mstore(0, 0x7cdd3fde00000000000000000000000000000000000000000000000000000000)
        // put ilk
        mstore(4, sload(1))
        // put msg.sender
        mstore(36, caller)
        // put -wad
        mstore(68, sub(0, calldataload(4)))
        // iff vat.slip(ilk, msg.sender, -wad) != 0
        if iszero(call(gas, sload(0), 0, 0, 100, 0, 0)) { revert(0, 0) }
      
        stop()
      }
      if eq(sig, 0xc5ce281e /*   function ilk() external returns (bytes32); */) {
        mstore(64, sload(1))
        return(64, 32)
      }
    }
  }
}
