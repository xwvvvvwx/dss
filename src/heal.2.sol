// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

interface VowI {
  function Awe() external returns (uint256);
  function Joy() external returns (uint256);
  function flap() external returns (uint256);
  function era() external returns (uint48);
  function kiss(uint256 wad) external;
  function file(bytes32 what, uint256 risk) external;
  function Ash() external returns (uint256);
  function flog(uint48 era_) external;
  function Woe() external returns (uint256);
  function lump() external returns (uint256);
  function wait() external returns (uint256);
  function fess(uint256 tab) external;
  function sin(uint48 era_) external returns (uint256);
  function pad() external returns (uint256);
  function flop() external returns (uint256);
  function Sin() external returns (uint256);
  function file(bytes32 what, address fuss) external;
  function heal(uint256 wad) external;
}

contract Vow {
  constructor (address vat_) public {
    assembly {
      // set vat = vat_
      codecopy(0, sub(codesize, 32), 32)
      sstore(0, mload(0))
    }
  }

  function () public {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if lt(sig, 0x53cb8def/*   function lump() external returns (uint256); */) {
        if lt(sig, 0x2506855a/*   function kiss(uint256 wad) external; */) {
          if lt(sig, 0x0e01198b/*   function flap() external returns (uint256); */) {
            if eq(sig, 0x05db4538 /*   function Awe() external returns (uint256); */) {
              mstore(64, Awe())
              return(64, 32)
            }
            if eq(sig, 0x07a832b4 /*   function Joy() external returns (uint256); */) {
              mstore(64, Joy())
              return(64, 32)
            }
          }
	  if eq(sig, 0x0e01198b /*   function flap() external returns (uint256); */) {
            // lump := lump
            let lump := sload(8)

            // iff Joy() >= Awe() + lump + pad
            if lt(Joy(), uiadd(uiadd(Awe(), lump), sload(9))) { revert(0, 0) }

            // iff Woe == 0
            if iszero(eq(sload(5), 0)) { revert(0, 0) }

            // put bytes4(keccak256("kick(address,uint256,uint256)")) << 28 bytes
            mstore(0, 0xb7e9cd2400000000000000000000000000000000000000000000000000000000)
            // put this
            mstore(4, address)
            // put lump
            mstore(36, lump)
            // put 0
            mstore(68, 0)
            // iff cow.call("kick(address,uint256, uint256)", this, lump, 0) != 0
            if iszero(call(gas, sload(1), 0, 0, 100, 64, 32)) { revert(0, 0) }
            
            return(64, 32)
          }
          if eq(sig, 0x143e55e0 /*   function era() external returns (uint48); */) {
            mstore(64, era())
            return(64, 32)
          }
        }
        if lt(sig, 0x2a1d2b3c/*   function Ash() external returns (uint256); */) {
	  if eq(sig, 0x2506855a /*   function kiss(uint256 wad) external; */) {
            // Ash_ := Ash
            let Ash_ := sload(6)
            
            // iff wad <= Ash && wad <= Joy() && int(wad) >= 0
            if or(or(gt(calldataload(4), Ash_), gt(calldataload(4), Joy())), slt(calldataload(4), 0)) { revert(0, 0) }

            // set Ash = Ash_ + wad
            sstore(6, uisub(Ash_, calldataload(4)))

            // put bytes4(keccak256("heal(address,address,int256)")) << 28 bytes
            mstore(0, 0xee8cd74800000000000000000000000000000000000000000000000000000000)
            // put this
            mstore(4, address)
            // put this
            mstore(36, address)
            // put wad
            mstore(68, calldataload(4))
            // iff vat.call("heal(address,address,int256)", this, this, wad) != 0
            if iszero(call(gas, sload(0), 0, 0, 100, 0, 0)) { revert(0, 0) }

            stop()
          }
          if eq(sig, 0x29ae8114 /*   function file(bytes32 what, uint256 risk) external; */) {

            // if what == "lump" set lump = risk
            if eq(calldataload(4), "lump") { sstore(8, calldataload(36)) }

            // if what == "pad" set pad = risk
            if eq(calldataload(4), "pad") { sstore(9, calldataload(36)) }

            stop()
          }
        }
        if eq(sig, 0x2a1d2b3c /*   function Ash() external returns (uint256); */) {
          mstore(64, sload(6))
          return(64, 32)
        }
        if eq(sig, 0x35aee16f /*   function flog(uint48 era_) external; */) {
          let hash_0 := hash2(3, calldataload(4))

          // sin_era_ := sin[era_]
          let sin_era_ := sload(hash_0)

          // set Sin -= sin_era_
          sstore(4, uisub(sload(4), sin_era_))

          // set Woe += sin_era_
          sstore(5, uiadd(sload(5), sin_era_))

          // set sin[era_] = 0
          sstore(hash_0, 0)

          stop()
        }
        if eq(sig, 0x49dd5bb2 /*   function Woe() external returns (uint256); */) {
          mstore(64, sload(5))
          return(64, 32)
        }
      }
      if lt(sig, 0x9361266c/*   function pad() external returns (uint256); */) {
        if lt(sig, 0x697efb78/*   function fess(uint256 tab) external; */) {
          if eq(sig, 0x53cb8def /*   function lump() external returns (uint256); */) {
            mstore(64, sload(8))
            return(64, 32)
          }
          if eq(sig, 0x64bd7013 /*   function wait() external returns (uint256); */) {
            mstore(64, sload(7))
            return(64, 32)
          }
        }
        if eq(sig, 0x697efb78 /*   function fess(uint256 tab) external; */) {
          let hash_0 := hash2(3, era())

          // set sin[era()] += tab
          sstore(hash_0, uiadd(sload(hash_0), calldataload(4)))

          // set Sin += tab
          sstore(4, uiadd(sload(4), calldataload(4)))

          stop()
        }
        if eq(sig, 0x7f49edc4 /*   function sin(uint48 era_) external returns (uint256); */) {
          let hash_0 := hash2(3, calldataload(4))
          mstore(64, sload(hash_0))
          return(64, 32)
        }
      }
      if lt(sig, 0xd0adc35f/*   function Sin() external returns (uint256); */) {
        if eq(sig, 0x9361266c /*   function pad() external returns (uint256); */) {
          mstore(64, sload(9))
          return(64, 32)
        }
        if eq(sig, 0xbbbb0d7b /*   function flop() external returns (uint256); */) {

          // Woe_ := Woe
          let Woe_ := sload(5)

          let lump := sload(8)
          
          // iff Woe_ >= lump
          if lt(Woe_, lump) { revert(0, 0) }

          // iff Joy() == 0
          if iszero(eq(Joy(), 0)) { revert(0, 0) }

          // set Woe -= lump
          sstore(5, uisub(Woe_, lump))

          // set Ash += lump
          sstore(6, uiadd(sload(6), lump))

          // put bytes4(keccak256("kick(address,uint256,uint256)")) << 28 bytes
          mstore(0, 0xb7e9cd2400000000000000000000000000000000000000000000000000000000)
          // put this
          mstore(4, address)
          // put uint(-1)
          mstore(36, 115792089237316195423570985008687907853269984665640564039457584007913129639935)
          // put lump
          mstore(68, lump)
          // iff row.call("kick(address,uint256, uint256)", this, uint(-1), lump) != 0
          if iszero(call(gas, sload(2), 0, 0, 100, 64, 32)) { revert(0, 0) }
          
          return(64, 32)
        }
      }
      if eq(sig, 0xd0adc35f /*   function Sin() external returns (uint256); */) {
        mstore(64, sload(4))
        return(64, 32)
      }
      if eq(sig, 0xd4e8be83 /*   function file(bytes32 what, address fuss) external; */) {
        // if what == "flap" set cow = fuss
        if eq(calldataload(4), "flap") { sstore(1, calldataload(36)) }

        // if what == "flop" set row = fuss
        if eq(calldataload(4), "flop") { sstore(2, calldataload(36)) }

        stop()
      }
      if eq(sig, 0xf37ac61c /*   function heal(uint256 wad) external; */) {

        // Woe_ := Woe
        let Woe_ := sload(5)
        
        // iff wad <= Joy() && wad <= Woe && int(wad) >= 0
        if or(or(gt(calldataload(4), Joy()), gt(calldataload(4), Woe_)), slt(calldataload(4), 0)) { revert(0, 0) }

        // set Woe = Woe_ + wad
        sstore(5, uisub(Woe_, calldataload(4)))

        // put bytes4(keccak256("heal(address,address,int256)")) << 28 bytes
        mstore(0, 0xee8cd74800000000000000000000000000000000000000000000000000000000)
        // put this
        mstore(4, address)
        // put this
        mstore(36, address)
        // put wad
        mstore(68, calldataload(4))
        // iff vat.call("heal(address,address,int256)", this, this, wad) != 0
        if iszero(call(gas, sload(0), 0, 0, 100, 0, 0)) { revert(0, 0) }

        stop()
      }
      
      // failed to select any of the public methods:
      revert(0, 0)

      function era() -> era_ {
        era_ := timestamp
      }
      function Awe() -> wad {
        wad := uiadd(uiadd(sload(4), sload(5)), sload(6))
      }
      function Joy() -> wad {
        // put bytes4(keccak256("dai(address)")) << 28 bytes
        mstore(0, 0x6c25b34600000000000000000000000000000000000000000000000000000000)
        // put this
        mstore(4, address)
        // iff vat.call("dai(address)", this) != 0
        if iszero(call(gas, sload(0), 0, 0, 36, 0, 32)) { revert(0, 0) }
        
        let vat_dai := mload(0)
        
        // iff vat.dai(this) >= 0
        if slt(vat_dai, 0) { revert(0, 0) }
        
        wad := div(vat_dai, 1000000000000000000000000000)
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
      function uisub(x, y) -> z {
        z := sub(x, y)
        if gt(z, x) { revert(0, 0) }
      }
    }
  }
}
