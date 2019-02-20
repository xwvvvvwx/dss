/// join.sol -- Basic token adapters

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

import "ds-note/note.sol";

// ERC20 w./ mint & burn
contract GemLike {
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
    function mint(address,uint) public;
    function burn(address,uint) public;
}

// Vat
contract VatLike {
    function slip(bytes32,bytes32,int) public;
    function move(bytes32,bytes32,int) public;
    function flux(bytes32,bytes32,bytes32,int) public;
}

// Swap ERC20 tokens from the outside world with the internal "play money"
contract GemJoin is DSNote {

    VatLike public vat; // vat
    bytes32 public ilk; // ilk id
    GemLike public gem; // erc20

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        // set vat address
        vat = VatLike(vat_);
        // set ilk id
        ilk = ilk_;
        // set collateral token address
        gem = GemLike(gem_);
    }

    uint constant ONE = 10 ** 27; // ray

    // overflow safe uint multiplication. cast to int as this is what is accepted in the vat functions.
    function mul(uint x, uint y) internal pure returns (int z) {
        // multiple x and y. cast the result to an int
        z = int(x * y);
        // check that the result is representable as an int
        require(int(z) >= 0);
        // check that no overflow has occured
        require(y == 0 || uint(z) / y == x);
    }

    // pay wad external tokens to recieve wad vat tokens at urn
    function join(bytes32 urn, uint wad) public note {
        // increment gem balance of urn by wad
        vat.slip(ilk, urn, mul(ONE, wad));
        // move erc20 tokens from msg.sender to this contract
        require(gem.transferFrom(msg.sender, address(this), wad));
    }


    // pay wad vat tokens and receive wad external tokens at guy
    function exit(bytes32 urn, address guy, uint wad) public note {
        // only owner of vat tokens can exit
        require(bytes20(urn) == bytes20(msg.sender));
        // decrement ilk balance at urn by wad
        vat.slip(ilk, urn, -mul(ONE, wad));
        // send wad external tokens to guy
        require(gem.transfer(guy, wad));
    }
}

// Swap ETH from the outside world for it's vat representation
contract ETHJoin is DSNote {

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
        // multiply x and y and cast result to an int
        z = int(x * y);
        // check that result can be represented as an int
        require(int(z) >= 0);
        // check that no overflows have occured
        require(y == 0 || uint(z) / y == x);
    }

    // swap ETH for the vat representation
    function join(bytes32 urn) public payable note {
        vat.slip(ilk, urn, mul(ONE, msg.value));
    }

    // swap vat ETH for real ETH
    function exit(bytes32 urn, address payable guy, uint wad) public note {
        // only the owner can exit
        require(bytes20(urn) == bytes20(msg.sender));
        // reduce the vat ETH balance at urn by wad
        vat.slip(ilk, urn, -mul(ONE, wad));
        // transfer wad ETH to guy
        guy.transfer(wad);
    }
}

// swap DAI ERC20 for vat dai
contract DaiJoin is DSNote {

    VatLike public vat; // vat contracct
    GemLike public dai; // dai erc20 contract

    constructor(address vat_, address dai_) public {
        // set vat address
        vat = VatLike(vat_);
        // set dai address
        dai = GemLike(dai_);
    }

    uint constant ONE = 10 ** 27; // ray

    // overflow safe uint multiplication, returns an int cos thats what the vat expects
    function mul(uint x, uint y) internal pure returns (int z) {
        // multiply x and y, cast result to an int
        z = int(x * y);
        // check that result can safely be represented as an int
        require(int(z) >= 0);
        // ensure that no overflow has occured
        require(y == 0 || uint(z) / y == x);
    }

    // swap wad erc20 dai for wad vat dai
    function join(bytes32 urn, uint wad) public note {
        // send wad vat dai tokens from this contract to urn
        vat.move(bytes32(bytes20(address(this))), urn, mul(ONE, wad));
        // burn wad erc20 dai tokens belonging to msg.sender
        dai.burn(msg.sender, wad);
    }

    // swap wad vat dai for wad erc20 dai
    function exit(bytes32 urn, address guy, uint wad) public note {
        // can only be used on vat dai belonging to msg.sender
        require(bytes20(urn) == bytes20(msg.sender));
        // move wad vat dai from urn to this contract
        vat.move(urn, bytes32(bytes20(address(this))), mul(ONE, wad));
        // mint wad dai for guy
        dai.mint(guy, wad);
    }
}
