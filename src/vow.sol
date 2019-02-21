/// vow.sol -- Dai settlement module

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

// Auction Contract (flap / flop)
contract Fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
    function dai() public returns (address);
}

// GemMove / DaiMove
contract Hopeful {
    function hope(address) public;
    function nope(address) public;
}

// Vat
contract VatLike {
    function dai (bytes32) public view returns (uint);
    function sin (bytes32) public view returns (uint);
    function heal(bytes32,bytes32,int) public;
}

contract Vow is DSNote {
    // --- Auth ---
    // owners registry
    mapping (address => uint) public wards;
    // make guy an owner
    function rely(address guy) public note auth { wards[guy] = 1; }
    // remove guy as an owner
    function deny(address guy) public note auth { wards[guy] = 0; }
    // restrict functions to owners only
    modifier auth { require(wards[msg.sender] == 1); _; }


    // --- Data ---
    address public vat;
    address public cow;  // flapper
    address public row;  // flopper

    mapping (uint48 => uint256) public sin; // debt queue
    uint256 public Sin;   // queued debt
    uint256 public Ash;   // on-auction debt

    uint256 public wait;  // flop delay
    uint256 public sump;  // flop fixed lot size
    uint256 public bump;  // flap fixed lot size
    uint256 public hump;  // surplus buffer

    // --- Init ---
    constructor() public { wards[msg.sender] = 1; } // set creator as an owner

    // --- Math ---
    uint256 constant ONE = 10 ** 27; // ray

    // overflow safe uint addition
    function add(uint x, uint y) internal pure returns (uint z) {
        // add x and y
        z = x + y;
        // check that no overflow has occured
        require(z >= x);
    }
    // overflow save uint subtraction
    function sub(uint x, uint y) internal pure returns (uint z) {
        // subtract y from x
        z = x - y;
        // check that no overflow has occured
        require(z <= x);
    }
    // overflow safe uint multiplication
    function mul(uint x, uint y) internal pure returns (uint z) {
        // multiply x by y and check that no overflow has occured
        require(y == 0 || (z = x * y) / y == x);
    }

    // --- Administration ---
    function file(bytes32 what, uint data) public note auth {
        // set flop delay
        if (what == "wait") wait = data;
        // set flap lot size
        if (what == "bump") bump = data;
        // set flop lot size
        if (what == "sump") sump = data;
        // set surplus buffer size
        if (what == "hump") hump = data;
    }
    function file(bytes32 what, address addr) public note auth {
        // set DAI auction contract address
        if (what == "flap") cow = addr;
        // set MKR auction contract address
        if (what == "flop") row = addr;
        // set vat address
        if (what == "vat")  vat = addr;
    }

    // Total bad debt in the Vow (as a wad)
    function Awe() public view returns (uint) {
        return uint(VatLike(vat).sin(bytes32(bytes20(address(this))))) / ONE;
    }
    // Total dai in the Vow (as a wad)
    function Joy() public view returns (uint) {
        return uint(VatLike(vat).dai(bytes32(bytes20(address(this))))) / ONE;
    }
    // Unqueued, pre-auction debt
    function Woe() public view returns (uint) {
        // total debt - queued debt - unqueued debt
        return sub(sub(Awe(), Sin), Ash);
    }

    // Push to debt-queue
    function fess(uint tab) public note auth {
        // increment the debt queue entry for this block by tab
        sin[uint48(now)] = add(sin[uint48(now)], tab);
        // increment the total queued debt by tab
        Sin = add(Sin, tab);
    }

    // Pop from debt-queue
    // WHAT IS THIS FOR?
    function flog(uint48 era) public note {
        // check that flop delay has passed
        require(add(era, wait) <= now);
        // reduce total queued debt by amount of debt queued in block with timestamp era
        Sin = sub(Sin, sin[era]);
        // set queued debt for block with timestamp era to 0
        sin[era] = 0;
    }

    // Debt settlement

    // cover bad debt that is not on queued or auction by burning surplus DAI
    function heal(uint wad) public note {
        // check that amount to be settled is less than total surplus and total non queued, non auction debt
        require(wad <= Joy() && wad <= Woe());
        // convert wad to a rad and check that it can be represented as an int
        require(int(mul(wad, ONE)) >= 0);
        // destroy wad units of bad debt (sin) and dai
        VatLike(vat).heal(bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), int(mul(wad, ONE)));
    }

    // cover on auction bad debt by burning surplus DAI
    function kiss(uint wad) public note {
        // check that the amount to be settled is less than the total surplus and less than the total on auction debt
        require(wad <= Ash && wad <= Joy());
        // reduce total on auction debt by wad
        Ash = sub(Ash, wad);
        // convert wad to a rad and check that that result can be represented as an int
        require(int(mul(wad, ONE)) >= 0);
        // destroy wad units of bad debt and dai
        VatLike(vat).heal(bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), int(mul(wad, ONE)));
    }

    // Trigger debt auction (mint MKR to cover bad debt)
    function flop() public returns (uint id) {
        // check that total non auction non queued debt is larger than the flop auction lot size
        require(Woe() >= sump);
        // require that there is no surplus DAI
        require(Joy() == 0);
        // increase the total on auction debt by the flop auction lot size
        Ash = add(Ash, sump);
        // trigger a debt auction to cover `sump` units of bad debt
        return Fusspot(row).kick(address(this), uint(-1), sump);
    }

    // Trigger surplus auction (sell surplus DAI for MKR and then burn the MKR)
    function flap() public returns (uint id) {
        // check that surplus is greater total bad debt
        require(Joy() >= add(add(Awe(), bump), hump));
        // check that total non queued non auction debt is zero
        require(Woe() == 0);
        // allow auction contract to manage dai on behalf of the Vow
        Hopeful(Fusspot(cow).dai()).hope(cow);
        id = Fusspot(cow).kick(address(0), bump, 0);
        // auction contract can no longer manage dai on behalf of the Vow
        Hopeful(Fusspot(cow).dai()).nope(cow);
    }
}
