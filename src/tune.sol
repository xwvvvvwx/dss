/// tune.sol -- Dai CDP database

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

contract Vat {
    // --- Auth ---
    // owners
    mapping (address => uint) public wards;
    // set guy as owner
    function rely(address guy) public note auth { wards[guy] = 1; }
    // remove guy as owner
    function deny(address guy) public note auth { wards[guy] = 0; }
    // restrict function to owners only
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Data ---

    // collateral type
    struct Ilk {
        // conversion rate between locked and unlocked collateral
        uint256 take;  // ray
        // conversion rate between cdp debt and dai
        uint256 rate;  // ray
        // total locked collateral across all cdps
        uint256 Ink;   // wad
        // total outstanding debt across all cdps
        uint256 Art;   // wad
    }

    // cdp
    struct Urn {
        // locked collateral
        uint256 ink;   // wad
        // outstanding debt
        uint256 art;   // wad
    }

    // ilk id -> Ilk
    mapping (bytes32 => Ilk)                       public ilks;
    // ilk id -> cdp id -> cdp
    mapping (bytes32 => mapping (bytes32 => Urn )) public urns;
    // ilk id -> cdp id -> collateral
    mapping (bytes32 => mapping (bytes32 => uint)) public gem;  // rad
    // ilk id -> dai
    mapping (bytes32 => uint256)                   public dai;  // rad
    // ilk id -> dai
    mapping (bytes32 => uint256)                   public sin;  // rad

    // total dai
    uint256 public debt;  // rad
    // total bad debt
    uint256 public vice;  // rad

    // --- Logs ---
    event Note(
        bytes4   indexed  sig,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        bytes32  indexed  too,
        bytes             fax
    ) anonymous;
    modifier note {
        bytes32 foo;
        bytes32 bar;
        bytes32 too;
        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            too := calldataload(68)
        }
        emit Note(msg.sig, foo, bar, too, msg.data);
        _;
    }

    // --- Init ---
    constructor() public { wards[msg.sender] = 1; }

    // --- Math ---

    // add an int to a uint and revert if anything overflows
    function add(uint x, int y) internal pure returns (uint z) {
      assembly {
        // add y to x (modulo 2^256)
        z := add(x, y)
        // if y is > 0, check that the result of adding y to x is greater than x
        if sgt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
        // if y is < 0, check that the result of adding y to x is less than x
        if slt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    // subtract an int from a uint and revert if anything overflows
    function sub(uint x, int y) internal pure returns (uint z) {
      assembly {
        // subtract y from x (modulo 2^256)
        z := sub(x, y)
        // if y is < 0, check that the result of subtracting y from x is greater than x
        if slt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
        // if y is > 0, check that the result of subtracting y from x is less than x
        if sgt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    // multiply a uint by an int and revert if anything overflows
    function mul(uint x, int y) internal pure returns (int z) {
      assembly {
        // multiply x by y (modulo 2^256)
        z := mul(x, y)
        // x must be representable as an int
        if slt(x, 0) { revert(0, 0) }
        // if y is not zero, check that x == z / y
        if iszero(eq(y, 0)) { if iszero(eq(sdiv(z, y), x)) { revert(0, 0) } }
      }
    }

    // --- Administration ---

    // initialize a new ilk
    function init(bytes32 ilk) public note auth {
        // ensure that the ilk has not already been initialized
        require(ilks[ilk].rate == 0);
        require(ilks[ilk].take == 0);
        // set rates to ONE (they are rays)
        ilks[ilk].rate = 10 ** 27;
        ilks[ilk].take = 10 ** 27;
    }

    // --- Fungibility ---

    // increment guys ilk balance by rad units
    function slip(bytes32 ilk, bytes32 guy, int256 rad) public note auth {
        // increment gem[ilk][guy] by rad
        gem[ilk][guy] = add(gem[ilk][guy], rad);
    }
    // move rad units of ilk from src to dst
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 rad) public note auth {
        // decrement gem[ilk][src] by rad
        gem[ilk][src] = sub(gem[ilk][src], rad);
        // increment gem[ilk][dst] by rad
        gem[ilk][dst] = add(gem[ilk][dst], rad);
    }
    // move rad units of dai from src to dst
    function move(bytes32 src, bytes32 dst, int256 rad) public note auth {
        // decrement dai[src] by rad
        dai[src] = sub(dai[src], rad);
        // increment dai[dst] by rad
        dai[dst] = add(dai[dst], rad);
    }

    // --- CDP ---

    // normal cdp management (lock, draw, wipe, free)
    // For cdp u on ilk i:
    //   - lock ink.take * dink collateral from user v
    //   - generate ink.rate * dart dai and give it to user w
    function tune(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public note auth {
        // get reference to relevant cdp (urn)
        Urn storage urn = urns[i][u];
        // get reference to relevant collateral type (ilk)
        Ilk storage ilk = ilks[i];

        // increase debt in cdp by dink
        urn.ink = add(urn.ink, dink);
        // increase locked collateral by dart
        urn.art = add(urn.art, dart);
        // increase total debt by dink
        ilk.Ink = add(ilk.Ink, dink);
        // increase total locked collateral by dart
        ilk.Art = add(ilk.Art, dart);

        // decrement v's gem balance by dink * ilk.take
        gem[i][v] = sub(gem[i][v], mul(ilk.take, dink));
        // increment w's dai balance by dart * ilk.rate
        dai[w]    = add(dai[w],    mul(ilk.rate, dart));
        // increment the total dai balance by dart * ilk.rate
        debt      = add(debt,      mul(ilk.rate, dart));
    }

    // liquidation: confiscate collateral and move debt to bad debt (normally called with negative dink & dart)
    // for cdp u on ilk i:
    //   - lock ilk.take * dink collateral from v
    //   - destroy ilk.rate * dart bad debt from w and add it to cdp u
    function grab(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public note auth {
        // get reference to relevant cdp
        Urn storage urn = urns[i][u];
        // get reference to relevant collateral type
        Ilk storage ilk = ilks[i];

        // increment cdp debt by dink
        urn.ink = add(urn.ink, dink);
        // lock dart collateral
        urn.art = add(urn.art, dart);
        // increment total debt by dink
        ilk.Ink = add(ilk.Ink, dink);
        // increment total collateral by dart
        ilk.Art = add(ilk.Art, dart);

        // decrement v's gem balance by dink * ilk.take
        gem[i][v] = sub(gem[i][v], mul(ilk.take, dink));
        // decrement w's bad debt balance by dart * ilk.rate
        sin[w]    = sub(sin[w],    mul(ilk.rate, dart));
        // decrement total bad debt balance by dart * ilk.rate
        vice      = sub(vice,      mul(ilk.rate, dart));
    }

    // --- Settlement ---

    // pay down u's bad debt by burning v's dai
    function heal(bytes32 u, bytes32 v, int rad) public note auth {
        // reduce u's bad debt balance by rad
        sin[u] = sub(sin[u], rad);
        // reduce v's dai balance by rad
        dai[v] = sub(dai[v], rad);
        // reduce total bad debt balance by rad
        vice   = sub(vice,   rad);
        // reduce total dai balance by rad
        debt   = sub(debt,   rad);
    }

    // --- Rates ---

    // collect stability fees on ilk i and give them to u
    function fold(bytes32 i, bytes32 u, int rate) public note auth {
        // get ref to ilk i
        Ilk storage ilk = ilks[i];
        // increase cdp debt -> vat dai multiplier by rate (each unit cdp debt is worth rate more vat dai)
        ilk.rate = add(ilk.rate, rate);
        // calculate total amount of new dai needed to pay down stability fees
        int rad  = mul(ilk.Art, rate);
        // increment u's dai balance by rad
        dai[u]   = add(dai[u], rad);
        // increment total dai supply by rad
        debt     = add(debt,   rad);
    }

    // take gems of type i from u and give them to everyone else by manipulating take
    function toll(bytes32 i, bytes32 u, int take) public note auth {
        // get ref to ilk i
        Ilk storage ilk = ilks[i];
        // increase cdp gem -> gem multiplier by take (everyone has more gems)
        ilk.take  = add(ilk.take, take);
        // decrease u's gem[i] balance to pay for everyone elses gem increase
        gem[i][u] = sub(gem[i][u], mul(ilk.Ink, take));
    }
}
