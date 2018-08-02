// Copyright (C) 2018 AGPL

pragma solidity ^0.4.24;

interface VatI {
  function grab(bytes32 ilk, address lad, address vow, int256 dink, int256 dart) external;
  function era() external returns (uint48);
  function urns(bytes32 , address ) external returns (int256 gem, int256 ink, int256 art);
  function vice() external returns (int256);
  function Gem(bytes32 ilk, address lad) external returns (int256);
  function Art(bytes32 ilk, address lad) external returns (int256);
  function dai(address ) external returns (int256);
  function Ink(bytes32 ilk, address lad) external returns (int256);
  function slip(bytes32 ilk, address guy, int256 wad) external;
  function file(bytes32 ilk, bytes32 what, int256 risk) external;
  function tune(bytes32 ilk, address lad, int256 dink, int256 dart) external;
  function fold(bytes32 ilk, address vow, int256 rate) external;
  function move(address src, address dst, uint256 wad) external;
  function ilks(bytes32 ) external returns (int256 rate, int256 Art);
  function Tab() external returns (int256);
  function root() external returns (address);
  function heal(address u, address v, int256 wad) external;
  function sin(address ) external returns (int256);
}

contract Vat {
  function () public {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if lt(sig, 0x7cdd3fde/*   function slip(bytes32 ilk, address guy, int256 wad) external; */) {
        if lt(sig, 0x3af39c21/*   function undefined() external; */) {
          if lt(sig, 0x2424be5c/*   function urns(bytes32 , address ) external returns (int256 gem, int256 ink, int256 art); */) {
            if eq(sig, 0x11045bee /*   function grab(bytes32 ilk, address lad, address vow, int256 dink, int256 dart) external; */) {

            }
            if eq(sig, 0x143e55e0 /*   function era() external returns (uint48); */) {

            }
          }
          if eq(sig, 0x2424be5c /*   function urns(bytes32 , address ) external returns (int256 gem, int256 ink, int256 art); */) {

          }
          if eq(sig, 0x2d61a355 /*   function vice() external returns (int256); */) {

          }
        }
        if lt(sig, 0x673c17da/*   function Art(bytes32 ilk, address lad) external returns (int256); */) {
          if eq(sig, 0x3af39c21 /*   function undefined() external; */) {

          }
          if eq(sig, 0x4186706d /*   function Gem(bytes32 ilk, address lad) external returns (int256); */) {

          }
        }
        if eq(sig, 0x673c17da /*   function Art(bytes32 ilk, address lad) external returns (int256); */) {

        }
        if eq(sig, 0x6c25b346 /*   function dai(address ) external returns (int256); */) {

        }
        if eq(sig, 0x71854745 /*   function Ink(bytes32 ilk, address lad) external returns (int256); */) {

        }
      }
      if lt(sig, 0xd9638d36/*   function ilks(bytes32 ) external returns (int256 rate, int256 Art); */) {
        if lt(sig, 0xa4593c52/*   function tune(bytes32 ilk, address lad, int256 dink, int256 dart) external; */) {
          if eq(sig, 0x7cdd3fde /*   function slip(bytes32 ilk, address guy, int256 wad) external; */) {

          }
          if eq(sig, 0x815d245d /*   function file(bytes32 ilk, bytes32 what, int256 risk) external; */) {

          }
        }
        if eq(sig, 0xa4593c52 /*   function tune(bytes32 ilk, address lad, int256 dink, int256 dart) external; */) {

        }
        if eq(sig, 0xb65337df /*   function fold(bytes32 ilk, address vow, int256 rate) external; */) {

        }
        if eq(sig, 0xbb35783b /*   function move(address src, address dst, uint256 wad) external; */) {

        }
      }
      if lt(sig, 0xebf0c717/*   function root() external returns (address); */) {
        if eq(sig, 0xd9638d36 /*   function ilks(bytes32 ) external returns (int256 rate, int256 Art); */) {

        }
        if eq(sig, 0xdc42e309 /*   function Tab() external returns (int256); */) {

        }
      }
      if eq(sig, 0xebf0c717 /*   function root() external returns (address); */) {

      }
      if eq(sig, 0xee8cd748 /*   function heal(address u, address v, int256 wad) external; */) {

      }
      if eq(sig, 0xf059212a /*   function sin(address ) external returns (int256); */) {

      }
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
      function iadd(x, y) -> z {
        z := add(x, y);
        if and(or(jkgg),
               or())
        // TODO
      }
    }
  }
}
