// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

interface LadI {
}

contract Lad {
  constructor (address vat_) public {
    assembly {
 
      // set vat = vat_
      sstore(1, calldataload(4))

      
      stop()
    }
  }   
  function () public {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if eq(sig, 0x0 /*  function live() external; */) { 
      }
      if eq(sig, 0x0 /*  function vat() external; */) { 
      }
      if eq(sig, 0x0 /*  function Line() external; */) { 
      }
      if eq(sig, 0x0 /*  function ilks(bytes32 ilk) external; */) { 
      }
      if eq(sig, 0x0 /*  function file(bytes32 what, int256 risk) external; */) { 
      }
      if eq(sig, 0x0 /*  function file(bytes32 ilk, bytes32 what, int256 risk) external; */) { 
      }
      if eq(sig, 0x0 /*  function frob(bytes32 ilk, int256 dink, int256 dart) external; */) { 
      }
    }
  }
}
      