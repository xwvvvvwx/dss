/// flip.sol -- Collateral auction

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

// DaiMove
contract DaiLike {
    function move(bytes32,bytes32,uint) public;
}

// GemMove
contract GemLike {
    function move(bytes32,bytes32,uint) public;
    function push(bytes32,uint) public;
}

/*
   This thing lets you flip some gems for a given amount of dai.
   Once the given amount of dai is raised, gems are forgone instead.

 - `lot` gems for sale
 - `tab` total dai wanted
 - `bid` dai paid
 - `gal` receives dai income
 - `urn` receives gem forgone
 - `ttl` single bid lifetime
 - `beg` minimum bid increase
 - `end` max auction duration
*/

contract Flipper is DSNote {
    // --- Data ---

    // auction lot
    struct Bid {
        uint256 bid;  // dai paid
        uint256 lot;  // gems for sale
        address guy;  // highest bidder
        uint48  tic;  // current expiry time
        uint48  end;  // maximum auction duration
        bytes32 urn;  // receives gem forgone
        address gal;  // receives dai income
        uint256 tab;  // total dai wanted
    }

    // auctions registry
    mapping (uint => Bid) public bids;

    DaiLike public   dai; // DaiMove
    GemLike public   gem; // GemMove

    uint256 constant ONE = 1.00E27;  // ray
    uint256 public   beg = 1.05E27;  // 5% minimum bid increase
    uint48  public   ttl = 3 hours;  // 3 hours bid duration
    uint48  public   tau = 2 days;   // 2 days total auction length
    uint256 public kicks = 0;        // total number of auctions started

    // --- Events ---

    // auction started
    event Kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      uint256 tab,
      bytes32 indexed urn,
      address indexed gal
    );

    // --- Init ---
    constructor(address dai_, address gem_) public {
        // set DaiMove address
        dai = DaiLike(dai_);
        // set GemMove address
        gem = GemLike(gem_);
    }

    // --- Math ---

    // overflow safe uint48 addition
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        // add x and y
        z = x + y;
        // check that the result has not overflown
        require(z >= x);
    }

    // overflow safe uint multiplication
    function mul(uint x, uint y) internal pure returns (int z) {
        // multiply x and y
        z = int(x * y);
        // check that the result can be represented as an int
        require(int(z) >= 0);
        // check that the result has not overflown
        require(y == 0 || uint(z) / y == x);
    }

    // convert an address to a 32 byte vat id
    function b32(address a) internal pure returns (bytes32) {
        // first 20 bytes of the bytes32 are the address
        return bytes32(bytes20(a));
    }

    // --- Auction ---

    // trigger a collateral auction (usually called by the cat)
    function kick(bytes32 urn, address gal, uint tab, uint lot, uint bid)
        public note returns (uint id)
    {
        // auction counter cannot overflow
        require(kicks < uint(-1));
        // increment auction counter and use it as the auction id
        id = ++kicks;

        // construct bid
        bids[id].bid = bid;                   // starting bid
        bids[id].lot = lot;                   // gems for sale
        bids[id].guy = msg.sender;            // initiator is the high bidder
        bids[id].end = add(uint48(now), tau); // max lifetime = now + max auction duration
        bids[id].urn = urn;                   // receives forgone gems
        bids[id].gal = gal;                   // receives dai profits
        bids[id].tab = tab;                   // total dai wanted

        // transfer lot gems from msg.sender (usually the cat)
        gem.move(b32(msg.sender), b32(address(this)), lot);

        // logging
        emit Kick(id, lot, bid, tab, urn, gal);
    }

    // extend lifetime of expired auctions that received no bids
    function tick(uint id) public note {
        // check that auction has expired
        require(bids[id].end < now);
        // check that no bids have been made
        require(bids[id].tic == 0);
        // set end time to now + auction length
        bids[id].end = add(uint48(now), tau);
    }


    // increase the price while keeping the amount of collateral sold constant
    function tend(uint id, uint lot, uint bid) public note {
        // id must reference a valid auction
        require(bids[id].guy != address(0));
        // check that per bid expiry time has not passed
        require(bids[id].tic > now || bids[id].tic == 0);
        // check that per auction expirty time has not passed
        require(bids[id].end > now);

        // check that collateral amount matches the amount on the auction
        require(lot == bids[id].lot);
        // check that tend phase has not finished
        require(bid <= bids[id].tab);
        // check that new bid is larger
        require(bid >  bids[id].bid);
        // check that new bid is at least 5% larger than prev highest bid (or we have hit the max dai payable for this auction)
        require(mul(bid, ONE) >= mul(beg, bids[id].bid) || bid == bids[id].tab);

        // new highest bidder refunds previous highest bidder
        dai.move(b32(msg.sender), b32(bids[id].guy), bids[id].bid);
        // new highest bidder pays difference between new and prev bids to auction beneficiary
        dai.move(b32(msg.sender), b32(bids[id].gal), bid - bids[id].bid);

        // set new highest bidder
        bids[id].guy = msg.sender;
        // set new highest bid amount
        bids[id].bid = bid;
        // reset per bid auction expiry timer
        bids[id].tic = add(uint48(now), ttl);
    }

    // reduce the amount of collateral purchased while keeping the price constant
    function dent(uint id, uint lot, uint bid) public note {
        // check that id references a valid auction
        require(bids[id].guy != address(0));
        // check that the auction has not expired due to the per bid timer
        require(bids[id].tic > now || bids[id].tic == 0);
        // check that the auction has not expired due to the per auction timer
        require(bids[id].end > now);

        // ensure that the bid param matches the current highest bid
        require(bid == bids[id].bid);
        // ensure that the tend phase has been completed
        require(bid == bids[id].tab);
        // ensure that the collateral to be sold is less than the current amount
        require(lot < bids[id].lot);
        // ensure that the amount to be sold decreases by at least 5%
        require(mul(beg, lot) <= mul(bids[id].lot, ONE));

        // new highest bidder refunds the previous highest bidder
        dai.move(b32(msg.sender), b32(bids[id].guy), bid);
        // send the forgone gems back to the liquidated cdp
        gem.push(bids[id].urn, bids[id].lot - lot);

        // update new highest bidder
        bids[id].guy = msg.sender;
        // update amount of gems to be sold
        bids[id].lot = lot;
        // reset per bid expiry timer
        bids[id].tic = add(uint48(now), ttl);
    }

    // winner collects their winnings
    function deal(uint id) public note {
        // check that there have been bids on this auction, and that it is over
        require(bids[id].tic != 0 && (bids[id].tic < now || bids[id].end < now));
        // send the gems to the winner
        gem.push(b32(bids[id].guy), bids[id].lot);
        // remove the auction from the registry
        delete bids[id];
    }
}
