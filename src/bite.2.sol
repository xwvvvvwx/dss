/// bite.2.sol -- Dai liquidation module

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
// Copyright (C) 2018 Lev Livnev <lev@liv.nev.org.uk>
// Copyright (C) 2018 Denis Erfurt <denis@dapp.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

interface CatI {
  function fuss(bytes32 ilk, address flip) external;
  function file(bytes32 what, uint256 risk) external;
  function vat() external returns (address);
  function bite(bytes32 ilk, address guy) external returns (uint256);
  function lump() external returns (uint256);
  function lad() external returns (address);
  function vow() external returns (address);
  function flips(uint256 n) external returns (bytes32 ilk, address guy, uint256 ink, uint256 tab);
  function nflip() external returns (uint256);
  function file(bytes32 ilk, bytes32 what, int256 risk) external;
  function ilks(bytes32 ilk) external returns (int256 chop, address flip);
  function flip(uint256 n, uint256 wad) external returns (uint256);
}

contract Cat {
  constructor (address vat_, address lad_, address vow_) public {
    assembly {
      codecopy(0, sub(codesize, 96), 96)

      // set vat = vat_
      sstore(0, mload(0))

      // set lad = lad_
      sstore(1, mload(32))

      // set vow = vow_
      sstore(2, mload(64))
    }
  }
  function () public {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if lt(sig, 0x626cb3c5/*   function vow() external returns (address); */) {
	if lt(sig, 0x45cf2230/*   function bite(bytes32 ilk, address guy) external returns (uint256); */) {
	  if eq(sig, 0x209dcd8c /*   function fuss(bytes32 ilk, address flip) external; */) {
            let hash_0 := hash2(4, calldataload(4))

            // set ilks[ilk].flip = flip
            sstore(add(hash_0, 1), calldataload(36))

            stop()
          }
          if eq(sig, 0x29ae8114 /*   function file(bytes32 what, uint256 risk) external; */) {
            // if what == "lump" set lump = risk
            if eq(calldataload(4), "lump") { sstore(3, calldataload(36)) }

            stop()
          }
          if eq(sig, 0x36569e77 /*   function vat() external returns (address); */) {
            mstore(64, sload(0))
            return(64, 32)
          }
        }
        if eq(sig, 0x45cf2230 /*   function bite(bytes32 ilk, address guy) external returns (uint256); */) {
          // put bytes4(keccak256("ilks(bytes32)")) << 28 bytes
          mstore(0, 0xd9638d3600000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // iff vat.call("ilks(bytes32)", ilk) != 0
          if iszero(call(gas, sload(0), 0, 0, 36, 0, 64)) { revert(0, 0) }

          // rate, Art := vat.ilks(ilk)
          let rate := mload(0)
          let Art := mload(32)

          // put bytes4(keccak256("ilks(bytes32)")) << 28 bytes
          mstore(0, 0xd9638d3600000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // iff vat.call("ilks(bytes32)", ilk) != 0
          if iszero(call(gas, sload(1), 0, 0, 36, 0, 64)) { revert(0, 0) }

          // rate, Art := vat.ilks(ilk)
          let spot := mload(0)
          let line := mload(32)

          // put bytes4(keccak256("urns(bytes32,address)")) << 28 bytes
          mstore(0, 0x2424be5c00000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // put guy
          mstore(36, calldataload(36))
          // iff vat.call("urns(bytes32,address)", ilk, guy) != 0
          if iszero(call(gas, sload(0), 0, 0, 68, 0, 96)) { revert(0, 0) }

          // _, ink, art := vat.urns(ilk, msg.sender)
          let ink := mload(32)
          let art := mload(64)

          // tab := rmul(art, rate)
          let tab := rmul(art, rate)

          // vow := vow
          let vow := sload(2)

          // iff rmul(ink, spot) < tab
          if iszero(lt(rmul(ink, spot), tab)) { revert(0, 0) }

          // put bytes4(keccak256("grab(bytes32,address,address,int256,int256)")) << 28 bytes
          mstore(0, 0x11045bee00000000000000000000000000000000000000000000000000000000)
          // put ilk
          mstore(4, calldataload(4))
          // put guy
          mstore(36, calldataload(36))
          // put vow
          mstore(68, vow)
          // put -ink
          mstore(100, sub(0, ink))
          // put -art
          mstore(132, sub(0, art))
          // iff vat.call("grab(bytes32,address,address,int256,int256", ilk, guy, vow, -ink, -art) != 0
          if iszero(call(gas, sload(0), 0, 0, 164, 0, 0)) { revert(0, 0) }

          // put bytes4(keccak256("fess(uint256)")) << 28 bytes
          mstore(0, 0x697efb7800000000000000000000000000000000000000000000000000000000)
          // put tab
          mstore(4, tab)
          // iff vow.call("fess(uint256)", tab) != 0
          if iszero(call(gas, vow, 0, 0, 36, 0, 0)) { revert(0, 0) }

          // nflip_ := nflip
          let nflip_ := sload(5)

          let hash_0 := hash2(6, nflip_)

          // set flips[nflip] = (ilk, guy, ink, tab)
          sstore(hash_0, calldataload(4))
          sstore(add(hash_0, 1), calldataload(36))
          sstore(add(hash_0, 2), ink)
          sstore(add(hash_0, 3), tab)

          // nflip++
          sstore(5, uiadd(nflip_, 1))

          mstore(64, nflip_)
          return(64, 32)
        }
        if eq(sig, 0x53cb8def /*   function lump() external returns (uint256); */) {
          mstore(64, sload(3))
          return(64, 32)
        }
        if eq(sig, 0x56cebd18 /*   function lad() external returns (address); */) {
          mstore(64, sload(1))
          return(64, 32)
        }
      }
      if lt(sig, 0x815d245d/*   function file(bytes32 ilk, bytes32 what, int256 risk) external; */) {
        if eq(sig, 0x626cb3c5 /*   function vow() external returns (address); */) {
          mstore(64, sload(2))
          return(64, 32)
        }
        if eq(sig, 0x70d9235a /*   function flips(uint256 n) external returns (bytes32 ilk, address guy, uint256 ink, uint256 tab); */) {
          let hash_0 := hash2(6, calldataload(4))

          mstore(64, sload(hash_0))
          mstore(96, sload(add(hash_0, 1)))
          mstore(128, sload(add(hash_0, 2)))
          mstore(160, sload(add(hash_0, 3)))
          return(64, 128)
        }
        if eq(sig, 0x76181a51 /*   function nflip() external returns (uint256); */) {
          mstore(64, sload(5))
          return(64, 32)
        }
      }
      if eq(sig, 0x815d245d /*   function file(bytes32 ilk, bytes32 what, int256 risk) external; */) {
        let hash_0 := hash2(4, calldataload(4))
        // if what == "chop" set ilks[ilk].chop = risk
        if eq(calldataload(36), "chop") { sstore(hash_0, calldataload(68)) }

        stop()
      }
      if eq(sig, 0xd9638d36 /*   function ilks(bytes32 ilk) external returns (int256 chop, address flip); */) {
        let hash_0 := hash2(4, calldataload(4))

        mstore(64, sload(hash_0))
        mstore(96, sload(add(hash_0, 1)))
        return(64, 64)

      }
      if eq(sig, 0xe6f95917 /*   function flip(uint256 n, uint256 wad) external returns (uint256); */) {
        let hash_0 := hash2(6, calldataload(4))

        // tab = flips[n].tab
        let tab := sload(add(hash_0, 3))

        // iff wad <= tab
        if gt(calldataload(36), tab) { revert(0, 0) }

        // lump := lump
        let lump := sload(3)

        // iff (wad == lump || (wad < lump && wad == tab))
        if iszero(or(eq(calldataload(36), lump), and(lt(calldataload(36), lump), eq(calldataload(36), tab)))) { revert(0, 0) }

        // ink_ = flips[n].ink
        let ink_ := sload(add(hash_0, 2))

        // ink := ink_ * wad / tab
        let ink := div(mul(ink_, calldataload(36)), tab)

        // set f.tab -= wad
        sstore(add(hash_0, 3), sub(tab, calldataload(36)))

        // set f.ink -= ink
        sstore(add(hash_0, 2), sub(ink_, ink))

        let hash_1 := hash2(4, sload(hash_0))

        // put bytes4(keccak256("kick(address,address,uint256,uint256,uint256)")) << 28 bytes
        mstore(0, 0x351de60000000000000000000000000000000000000000000000000000000000)
        // put flips[n].guy
        mstore(4, sload(add(hash_0, 1)))
        // put vow
        mstore(36, sload(2))
        // put rmul(wad, ilks[flips[n].ilk].chop)
        mstore(68, rmul(calldataload(36), sload(hash_1)))
        // put ink
        mstore(100, ink)
        // put 0
        mstore(132, 0)
        // iff .call("kick(address,address,uint256,uint256,uint256)", flips[n].guy, vow, rmul(wad, ilks[flips[n].ilk].chop), ink, 0) != 0
        if iszero(call(gas, sload(add(hash_1, 1)), 0, 0, 164, 64, 32)) { revert(0, 0) }
        return(64, 32)
      }
      function hash2(b, i) -> h {
        mstore(0, b)
        mstore(32, i)
        h := keccak256(0, 64)
      }
      function uiadd(x, y) -> z {
        z := add(x, y)
        if lt(z, x) { revert(0, 0) }
      }
      function rmul(x, y) -> z {
        z := div(mul(x, y), 1000000000000000000000000000)
      }
    }
  }
}
