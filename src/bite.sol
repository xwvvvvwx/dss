/// bite.sol -- Dai liquidation module

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
pragma experimental ABIEncoderV2;

import "ds-note/note.sol";

// Collateral -> DAI auction
contract Flippy {
    function kick(bytes32 urn, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
    function gem() public returns (address);
}

// Token move adapter (GemMove, DaiMove, etc.)
contract Hopeful {
    function hope(address) public;
    function nope(address) public;
}

// Core
contract VatLike {
    struct Ilk {
        uint256 take;  // ray
        uint256 rate;  // ray
        uint256 Ink;   // wad
        uint256 Art;   // wad
    }
    struct Urn {
        uint256 ink;   // wad
        uint256 art;   // wad
    }
    function ilks(bytes32) public view returns (Ilk memory);
    function urns(bytes32,bytes32) public view returns (Urn memory);
    function grab(bytes32,bytes32,bytes32,bytes32,int,int) public;
}

// Public CDP interface
contract PitLike {
    function ilks(bytes32) public view returns (uint,uint);
}

// Debt (MKR -> DAI) & Surplus (DAI -> MKR) auction manager
contract VowLike {
    function fess(uint) public;
}

contract Cat is DSNote {
    // --- Auth ---
    // ownership register
    mapping (address => uint) public wards;
    // set guy as an owner
    function rely(address guy) public note auth { wards[guy] = 1; }
    // remove guy as an owner
    function deny(address guy) public note auth { wards[guy] = 0; }
    // restrict function to owners only
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Data ---
    // per collateral auction parameters
    struct Ilk {
        address flip;  // Liquidator
        uint256 chop;  // Liquidation Penalty   [ray]
        uint256 lump;  // Liquidation Quantity  [wad]
    }
    // liquidated CDP
    struct Flip {
        bytes32 ilk;  // Collateral Type
        bytes32 urn;  // CDP Identifier
        uint256 ink;  // Collateral Quantity [wad]
        uint256 tab;  // Debt Outstanding    [wad]
    }

    // auction parameters
    mapping (bytes32 => Ilk)  public ilks;
    // lots ready for auction
    mapping (uint256 => Flip) public flips;
    // number of auction lots to date
    uint256                   public nflip;

    uint256 public live; // emergency shutdown flag
    VatLike public vat;  // core
    PitLike public pit;  // public cdp interface
    VowLike public vow;  // debt & surplus auction manager

    // --- Events ---
    // liquidation
    event Bite(
      bytes32 indexed ilk,
      bytes32 indexed urn,
      uint256 ink,
      uint256 art,
      uint256 tab,
      uint256 flip
    );

    // auction triggered
    event FlipKick(
      uint256 nflip,
      uint256 bid
    );

    // --- Init ---
    constructor(address vat_) public {
        wards[msg.sender] = 1; // set creator as owner
        vat = VatLike(vat_);   // set vat address
        live = 1;              // emergency shutdown has not yet occured
    }

    // --- Math ---
    uint constant ONE = 10 ** 27; // ray

    // overflow safe integer multiplication
    function mul(uint x, uint y) internal pure returns (uint z) {
        // multiply x by y
        z = x * y;
        // check that no overflows have occured
        require(y == 0 || z / y == x);
    }

    // overflow safe fixed point multiplication (with rays)
    function rmul(uint x, uint y) internal pure returns (uint z) {
        // multiply x by y
        z = x * y;
        // check that no overflows have occured
        require(y == 0 || z / y == x);
        // drop 27 digits of precision
        z = z / ONE;
    }

    // --- Administration ---
    function file(bytes32 what, address data) public note auth {
        // set pit address
        if (what == "pit") pit = PitLike(data);
        // set vow address
        if (what == "vow") vow = VowLike(data);
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        // set liquidation penalty for ilk
        if (what == "chop") ilks[ilk].chop = data;
        // set lot size for ilk
        if (what == "lump") ilks[ilk].lump = data;
    }
    function file(bytes32 ilk, bytes32 what, address flip) public note auth {
        // set auction contract for ilk
        if (what == "flip") ilks[ilk].flip = flip;
    }

    // --- CDP Liquidation ---

    // liquidate cdp & prepare collateral auction
    function bite(bytes32 ilk, bytes32 urn) public returns (uint) {
        // check for emergency shutdown
        require(live == 1);

        // get ref to ilk from vat
        VatLike.Ilk memory i = vat.ilks(ilk);
        // get ref to cdp from vat
        VatLike.Urn memory u = vat.urns(ilk, urn);

        // get liquidation ratio adjusted price feed from pit
        (uint spot, uint line) = pit.ilks(ilk); line;
        // calculate total outstanding debt
        uint tab = rmul(u.art, i.rate);

        // value of collateral should be less than total outstanding debt * liquidation ratio
        require(rmul(u.ink, spot) < tab);  // !safe

        // - transfer all collateral from urn to this contract
        // - increase the vows bad debt balance by the value of the outstanding debt on urn
        vat.grab(ilk, urn, bytes32(bytes20(address(this))), bytes32(bytes20(address(vow))), -int(u.ink), -int(u.art));

        // ?
        vow.fess(tab);

        // schedule collateral auction
        flips[nflip] = Flip(ilk, urn, u.ink, tab);

        // logging
        emit Bite(ilk, urn, u.ink, u.art, tab, nflip);

        // return the current value of nflip and then increment it ready for the next execution
        return nflip++;
    }

    // trigger an auction from liquidation with id n to cover wad units of debt
    function flip(uint n, uint wad) public note returns (uint id) {
        // check for emergency shutdown
        require(live == 1);

        // get ref to auction
        Flip storage f = flips[n];
        // get ref to per ilk params
        Ilk  storage i = ilks[f.ilk];

        // check that the amount of debt to be covered does not exceed the total outstanding debt
        require(wad <= f.tab);
        // check that the amount of debt to be covered is either:
        // - the lot size from the per ilk params
        // - less than the lot size and equal to the amount of total outstanding debt
        require(wad == i.lump || (wad < i.lump && wad == f.tab));

        // save amount of current outstanding debt
        uint tab = f.tab;
        // calculate ammount of collateral to be sold
        uint ink = mul(f.ink, wad) / tab;

        // reduce outstanding debt by wad
        f.tab -= wad;
        // reduce remaining collateral by ink
        f.ink -= ink;

        // allow auction contract to move collateral tokens
        Hopeful(Flippy(i.flip).gem()).hope(i.flip);

        // trigger collateral auction
        id = Flippy(i.flip).kick({ urn: f.urn
                                 , gal: address(vow)
                                 , tab: rmul(wad, i.chop)
                                 , lot: ink
                                 , bid: 0
                                 });

        // logging
        emit FlipKick(n, id);

        // auction contract cannot move collateral tokens
        Hopeful(Flippy(i.flip).gem()).nope(i.flip);
    }
}
