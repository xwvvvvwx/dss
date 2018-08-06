// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

interface LadI {
  function vat() external returns (address);
  function frob(bytes32 ilk, int256 dink, int256 dart) external;
  function file(bytes32 ilk, bytes32 what, int256 risk) external;
  function live() external returns (bool);
  function file(bytes32 what, int256 risk) external;
  function Line() external returns (int256);
  function ilks(bytes32 ilk) external returns (int256 spot, int256 line);
}

contract Lad {
  constructor (address vat_) public {
    assembly {
      // set vat = vat_
      codecopy(0, sub(codesize, 32), 32)
      sstore(0, mload(0))

      // set live = true
      sstore(2, 1)
    }
  }   
  function () public {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if lt(sig, 0x957aa58c/*   function live() external returns (bool); */) {
        if eq(sig, 0x36569e77 /*   function vat() external returns (address); */) {
          mstore(64, sload(0))
          return(64, 32) 
        }
        if eq(sig, 0x5a984ded /*   function frob(bytes32 ilk, int256 dink, int256 dart) external; */) {
          // TODO g, v
          let g := 1000000
          let v := gasprice
          // put bytes4(keccak256("tune(bytes32,address,int256,int256)")) << 28 bytes
          mstore(0, 0xa4593c5200000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // put msg.sender (automatically pads to 32 bytes)
          mstore(36, caller)
          // put dink
          mstore(68, calldataload(36))
          // put dart
          mstore(100, calldataload(68))
          // iff vat.tune(ilk, msg.sender, dink, dart) != 0
          if iszero(call(g, sload(0), v, 0, 132, 0, 0)) { revert(0, 0) }

          // put bytes4(keccak256("ilks(bytes32)")) << 28 bytes
          mstore(0, 0xd9638d3600000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // iff vat.ilks(ilk) != 0
          if iszero(call(g, sload(0), v, 0, 36, 0, 64)) { revert(0, 0) }

          // rate, Art := vat.ilks(ilk)
          let rate := mload(0)
          let Art := mload(32)

          // put bytes4(keccak256("urns(bytes32,address)")) << 28 bytes
          mstore(0, 0x2424be5c00000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // put msg.sender
          mstore(36, caller)
          // iff vat.urns(ilk, msg.sender) != 0
          if iszero(call(g, sload(0), v, 0, 68, 0, 96)) { revert(0, 0) }

          // _, ink, art := vat.urns(ilk, msg.sender)
          let ink := mload(32)
          let art := mload(64)

          // put bytes4(keccak256("Tab()")) << 28 bytes
          mstore(0, 0xdc42e30900000000000000000000000000000000000000000000000000000000)
          // iff vat.Tab() != 0
          if iszero(call(g, sload(0), v, 0, 4, 0, 32)) { revert(0, 0) }

          // Tab := vat.Tab()
          let Tab := mload(0)

          let hash_0 := hash2(3, calldataload(4))

          // spot, line := ilks[ilk]
          let spot := sload(hash_0)
          let line := sload(add(hash_0, 1))
          
          // calm := (imul(Art, rate) <= imul(line, 10**27)) && (Tab < imul(Line, 10**27))
          let calm := and(iszero(sgt(imul(Art, rate), imul(line, 1000000000000000000000000000))),
                          slt(Tab, imul(sload(1), 1000000000000000000000000000)))

          // cool := dart <= 0
          let cool := iszero(sgt(calldataload(68), 0))
          
          // firm := dink >= 0
          let firm := iszero(slt(calldataload(36), 0))

          // safe := imul(ink, spot) >= imul(art, rate)
          let safe := iszero(slt(imul(ink, spot), imul(art, rate)))

          // iff (calm || cool) && (cool && firm || safe) && live
          if iszero(and(and(or(calm, cool), or(and(cool, firm), safe)), sload(2))) { revert(0, 0) }

          // iff rate != 0
          if eq(rate, 0) { revert(0, 0) }

          stop()
        }
        if eq(sig, 0x815d245d /*   function file(bytes32 ilk, bytes32 what, int256 risk) external; */) {
          let hash_0 := hash2(3, calldataload(4))
          if eq(calldataload(36), "spot") { sstore(hash_0, calldataload(68)) }
          if eq(calldataload(36), "line") { sstore(add(hash_0, 1), calldataload(68)) }          
          stop()
        }
      }
      if lt(sig, 0xbabe8a3f/*   function Line() external returns (int256); */) {
        if eq(sig, 0x957aa58c /*   function live() external returns (bool); */) {
          mstore(64, sload(2))
          return(64, 32)
        }
        if eq(sig, 0x9be85611 /*   function file(bytes32 what, int256 risk) external; */) {
          // if what == "Line" set Line = risk
          if eq(calldataload(4), "Line") { sstore(1, calldataload(36)) }
          stop()
        }
      }
      if eq(sig, 0xbabe8a3f /*   function Line() external returns (int256); */) {
        mstore(64, sload(1))
        return(64, 32)
      }
      if eq(sig, 0xd9638d36 /*   function ilks(bytes32 ) external returns (int256 spot, int256 line); */) {
        let hash_0 := hash2(3, calldataload(4))
        mstore(64, sload(hash_0))
        mstore(96, sload(add(hash_0, 1)))
        return(64, 64)
      }

      // failed to select any of the public methods:
      revert(0, 0)

      function hash2(b, i) -> h {
        mstore(0, b)
        mstore(32, i)
        h := keccak256(0, 64)
      }
      function hash3(b, i, j) -> h {
        mstore(0, b)
        mstore(32, i)
        mstore(0, keccak256(0, 64))
        mstore(32, j)
        h := keccak256(0, 64)
      }
      // concatenate keys instead of recursively hashing
      function hash3_alt(b, i, j) -> h {
        mstore(0, b)
        mstore(32, i)
        mstore(64, j)
        h := keccak256(0, 96)
      }
      function iadd(x, y) -> z {
        z := add(x, y)
        if iszero(or(iszero(sgt(y, 0)), sgt(z, x))) { revert(0, 0) }
        if iszero(or(iszero(slt(y, 0)), slt(z, x))) { revert(0, 0) }
      }
      function isub(x, y) -> z {
        let minus_pow255 := sub(0, 57896044618658097711785492504343953926634992332820282019728792003956564819968)
        if eq(y, minus_pow255) { revert(0, 0) }
        z := iadd(x, sub(0, y))
      }
      function imul(x, y) -> z {
        z := mul(x, y)
        let minus_pow255 := sub(0, 57896044618658097711785492504343953926634992332820282019728792003956564819968)
        if iszero(or(iszero(slt(y, 0)), iszero(eq(x, minus_pow255)))) { revert(0, 0) }
        if iszero(or(eq(y, 0), eq(sdiv(z, y), x))) { revert(0, 0) }
      }
    }
  }
}
      
