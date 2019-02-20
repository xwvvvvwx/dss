/// move.sol -- Basic token fungibility

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
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

pragma solidity >=0.5.0;

// vat interface
contract VatLike {
    // move dai
    function move(bytes32,bytes32,int) public;
    // move collateral
    function flux(bytes32,bytes32,bytes32,int) public;
}

// Public interface to move vat collateral around.
// - Enforces vat addressing scheme (first 20 bytes of vat id's correspond to owners address)
// - adds approvals for vat collateral tokens
contract GemMove {
    VatLike public vat; // vat
    bytes32 public ilk; // ilk id

    constructor(address vat_, bytes32 ilk_) public {
        // set vat address
        vat = VatLike(vat_);
        // set ilk id
        ilk = ilk_;
    }

    uint constant ONE = 10 ** 27; // ray

    // overflow safe uint multiplication
    function mul(uint x, uint y) internal pure returns (int z) {
        // multiply x and y
        z = int(x * y);
        // ensure that result is representable as an int
        require(int(z) >= 0);
        // ensure that no overflow occured
        require(y == 0 || uint(z) / y == x);
    }

    // approvals (who can transfer tokens on my behalf)
    mapping(address => mapping (address => uint)) public can;
    // allow guy to perform transfers on behalf of msg.sender
    function hope(address guy) public { can[msg.sender][guy] = 1; }
    // guy can no longer perform transfers on behalf of msg.sender
    function nope(address guy) public { can[msg.sender][guy] = 0; }

    // transfer wad units of ilk from src to dst
    function move(bytes32 src, bytes32 dst, uint wad) public {
        // either msg.sender is transfering their own money, or they are authorised to transfer on behalf of src
        require(bytes20(src) == bytes20(msg.sender) || can[address(bytes20(src))][msg.sender] == 1);
        // perform transfer in the vat
        vat.flux(ilk, src, dst, mul(ONE, wad));
    }

    // shorthand for move(msg.sender, urn, wad)
    function push(bytes32 urn, uint wad) public {
        // convert sending address to a vat id
        bytes32 guy = bytes32(bytes20(msg.sender));
        // move the gems :)
        vat.flux(ilk, guy, urn, mul(ONE,wad));
    }
}

// Public interface to move vat DAI around.
// - Enforces vat addressing scheme (first 20 bytes of vat id's correspond to owners address)
// - adds approvals for vat collateral tokens
contract DaiMove {
    VatLike public vat; // vat

    constructor(address vat_) public {
        // set vat address
        vat = VatLike(vat_);
    }

    uint constant ONE = 10 ** 27; // ray

    // overflow safe multiplication
    function mul(uint x, uint y) internal pure returns (int z) {
        // perform multiplication and convert to an int
        z = int(x * y);
        // check that z can be safely converted to an int
        require(int(z) >= 0);
        // check that no overflows occured
        require(y == 0 || uint(z) / y == x);
    }

    // approvals (who can transfer on anothers behalf)
    mapping(address => mapping (address => uint)) public can;
    // guy can move msg.senders tokens around
    function hope(address guy) public { can[msg.sender][guy] = 1; }
    // guy cannot move msg.senders tokens around
    function nope(address guy) public { can[msg.sender][guy] = 0; }

    // move wad units of dai from src to dst
    function move(bytes32 src, bytes32 dst, uint wad) public {
        // either msg.sender is the same as src, or msg.sender is approved by src
        require(bytes20(src) == bytes20(msg.sender) || can[address(bytes20(src))][msg.sender] == 1);
        // move the tokens :)
        vat.move(src, dst, mul(ONE, wad));
    }
}
