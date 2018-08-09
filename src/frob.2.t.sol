pragma solidity ^0.4.24;

import "ds-test/test.sol";
import "ds-token/token.sol";

import {Lad, LadI} from './frob.2.sol';
import {Vat, VatI} from './tune.2.sol';
import './bite.sol';
import {Vow, VowI} from './heal.2.sol';
import {Dai20} from './transferFrom.sol';
import {Adapter, AdapterI} from './join.2.sol';

import {WarpFlip as Flipper} from './flip.t.sol';
import {WarpFlop as Flopper} from './flop.t.sol';
import {WarpFlap as Flapper} from './flap.t.sol';


// interfaces can't inherit :|
contract WarpVatI is VatI {
  function era() external returns (uint48 _era);
  function mint(address guy, uint256 wad) external;
}

contract WarpVowI is VowI {
}

contract WarpVat is Vat {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }

    int256 constant ONE = 10 ** 27;
    function mint(address guy, uint256 wad) public {
      assembly {
        function hash2(b, i) -> h {
          mstore(0, b)
          mstore(32, i)
          h := keccak256(0, 64)
        }
        let hash_0 := hash2(1, calldataload(4))

        // set dai[guy] += wad
        sstore(hash_0, add(sload(hash_0), mul(calldataload(36), 1000000000000000000000000000)))

        // set Tab += wad
        sstore(5, add(sload(5), mul(calldataload(36), 1000000000000000000000000000)))
      }
    }
}

contract WarpVow is Vow {}

contract Frob2Test is DSTest {
    VatI     vat;
    LadI     lad;
    Dai20    pie;
    DSToken gold;

    AdapterI adapter;

    function try_frob(bytes32 ilk, int ink, int art) public returns(bool) {
        bytes4 sig = bytes4(keccak256("frob(bytes32,int256,int256)"));
        return address(lad).call(sig, ilk, ink, art);
    }

    function ray(int wad) internal pure returns (int) {
        return wad * 10 ** 9;
    }

    function setUp() public {
        vat = VatI(new Vat());
        lad = LadI(new Lad(vat));
        pie = new Dai20(vat);

        gold = new DSToken("GEM");
        gold.mint(1000 ether);

        vat.file("gold", "rate", int(ray(1 ether)));
        adapter = AdapterI(new Adapter(vat, "gold", gold));
        gold.approve(adapter);
        adapter.join(1000 ether);

        lad.file("gold", "spot", int(ray(1 ether)));
        lad.file("gold", "line", 1000 ether);
        lad.file("Line", 1000 ether);

        gold.approve(vat);
    }

    function test_join() public {
        gold.mint(500 ether);
        assertEq(gold.balanceOf(this),     500 ether);
        assertEq(gold.balanceOf(adapter), 1000 ether);
        adapter.join(500 ether);
        assertEq(gold.balanceOf(this),       0 ether);
        assertEq(gold.balanceOf(adapter), 1500 ether);
        adapter.exit(250 ether);
        assertEq(gold.balanceOf(this),     250 ether);
        assertEq(gold.balanceOf(adapter), 1250 ether);
    }
    function test_lock() public {
    	(int Gem, int Ink, int Art) = vat.urns("gold", this); Gem; Art;
        assertEq(Ink, 0 ether);
        assertEq(Gem, 1000 ether);
        lad.frob("gold", 6 ether, 0);
	(Gem, Ink, Art) = vat.urns("gold", this);
        assertEq(Ink, 6 ether);
        assertEq(Gem, 994 ether);
        lad.frob("gold", -6 ether, 0);
	(Gem, Ink, Art) = vat.urns("gold", this);
        assertEq(Ink, 0 ether);
        assertEq(Gem, 1000 ether);
    }
    function test_calm() public {
        // calm means that the debt ceiling is not exceeded
        // it's ok to increase debt as long as you remain calm
        lad.file("gold", 'line', 10 ether);
        assertTrue( try_frob("gold", 10 ether, 9 ether));
        // only if under debt ceiling
        assertTrue(!try_frob("gold",  0 ether, 2 ether));
    }
    function test_cool() public {
        // cool means that the debt has decreased
        // it's ok to be over the debt ceiling as long as you're cool
        lad.file("gold", 'line', 10 ether);
        assertTrue(try_frob("gold", 10 ether,  8 ether));
        lad.file("gold", 'line', 5 ether);
        // can decrease debt when over ceiling
        assertTrue(try_frob("gold",  0 ether, -1 ether));
    }
    function test_safe() public {
        // safe means that the cdp is not risky
        // you can't frob a cdp into unsafe
        lad.frob("gold", 10 ether, 5 ether);                // safe draw
        assertTrue(!try_frob("gold", 0 ether, 6 ether));  // unsafe draw
    }
    function test_nice() public {
        // nice means that the collateral has increased or the debt has
        // decreased. remaining unsafe is ok as long as you're nice

        lad.frob("gold", 10 ether, 10 ether);
        lad.file("gold", 'spot', int(ray(0.5 ether)));  // now unsafe

        // debt can't increase if unsafe
        assertTrue(!try_frob("gold",  0 ether,  1 ether));
        // debt can decrease
        assertTrue( try_frob("gold",  0 ether, -1 ether));
        // ink can't decrease
        assertTrue(!try_frob("gold", -1 ether,  0 ether));
        // ink can increase
        assertTrue( try_frob("gold",  1 ether,  0 ether));

        // cdp is still unsafe
        // ink can't decrease, even if debt decreases more
        assertTrue(!this.try_frob("gold", -2 ether, -4 ether));
        // debt can't increase, even if ink increases more
        assertTrue(!this.try_frob("gold",  5 ether,  1 ether));

        // ink can decrease if end state is safe
        assertTrue( this.try_frob("gold", -1 ether, -4 ether));
        lad.file("gold", 'spot', int(ray(0.4 ether)));  // now unsafe
        // debt can increase if end state is safe
        assertTrue( this.try_frob("gold",  5 ether, 1 ether));
    }
}

contract BiteTest is DSTest {
    WarpVatI vat;
    LadI     lad;
    VowI     vow;
    Cat      cat;
    Dai20    pie;
    DSToken gold;

    AdapterI adapter;

    Flipper flip;
    Flopper flop;
    Flapper flap;

    DSToken gov;

    function try_frob(bytes32 ilk, int ink, int art) public returns(bool) {
        bytes4 sig = bytes4(keccak256("frob(bytes32,int256,int256)"));
        return address(vat).call(sig, ilk, ink, art);
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }

    function gem(bytes32 ilk, address lad_) internal view returns (int) {
        (int gem_, int ink_, int art_) = vat.urns(ilk, lad_); gem_; ink_; art_;
        return gem_;
    }
    function ink(bytes32 ilk, address lad_) internal view returns (int) {
        (int gem_, int ink_, int art_) = vat.urns(ilk, lad_); gem_; ink_; art_;
        return ink_;
    }
    function art(bytes32 ilk, address lad_) internal view returns (int) {
        (int gem_, int ink_, int art_) = vat.urns(ilk, lad_); gem_; ink_; art_;
        return art_;
    }

    function setUp() public {
        gov = new DSToken('GOV');
        gov.mint(100 ether);

        vat = WarpVatI(new WarpVat());
        lad = LadI(new Lad(vat));
        pie = new Dai20(vat);

        flap = new Flapper(vat, gov);
        flop = new Flopper(vat, gov);
        gov.setOwner(flop);

        vow = VowI(new Vow());
        vow.file("vat", address(vat));
        vow.file("flap", address(flap));
        vow.file("flop", address(flop));

        cat = new Cat(vat, lad, vow);

        gold = new DSToken("GEM");
        gold.mint(1000 ether);

        vat.file("gold", "rate", int(ray(1 ether)));
        adapter = AdapterI(new Adapter(vat, "gold", gold));
        gold.approve(adapter);
        adapter.join(1000 ether);

        lad.file("gold", "spot", int(ray(1 ether)));
        lad.file("gold", "line", 1000 ether);
        lad.file("Line", 1000 ether);
        flip = new Flipper(vat, "gold");
        cat.fuss("gold", flip);
        cat.file("gold", "chop", int(ray(1 ether)));

        gold.approve(vat);
        gov.approve(flap);
    }
    function test_happy_bite() public {
        // spot = tag / (par . mat)
        // tag=5, mat=2
        lad.file("gold", 'spot', int(ray(2.5 ether)));
        lad.frob("gold",  40 ether, 100 ether);

        // tag=4, mat=2
        lad.file("gold", 'spot', int(ray(2 ether)));  // now unsafe

        assertEq(ink("gold", this),  40 ether);
        assertEq(art("gold", this), 100 ether);
        assertEq(vow.Woe(), 0 ether);
        assertEq(gem("gold", this), 960 ether);
        uint id = cat.bite("gold", this);
        assertEq(ink("gold", this), 0);
        assertEq(art("gold", this), 0);
        assertEq(vow.sin(vow.era()), 100 ether);
        assertEq(gem("gold", this), 960 ether);

        cat.file("lump", uint(100 ether));
        uint auction = cat.flip(id, 100 ether);  // flip all the tab

        assertEq(pie.balanceOf(vow),   0 ether);
        flip.tend(auction, 40 ether,   1 ether);
        assertEq(pie.balanceOf(vow),   1 ether);
        flip.tend(auction, 40 ether, 100 ether);
        assertEq(pie.balanceOf(vow), 100 ether);

        assertEq(pie.balanceOf(this),       0 ether);
        assertEq(gem("gold", this), 960 ether);
        vat.mint(this, 100 ether);  // magic up some pie for bidding
        flip.dent(auction, 38 ether,  100 ether);
        assertEq(pie.balanceOf(this), 100 ether);
        assertEq(pie.balanceOf(vow),  100 ether);
        assertEq(gem("gold", this), 962 ether);
        assertEq(gem("gold", this), 962 ether);

        assertEq(vow.sin(vow.era()), 100 ether);
        assertEq(pie.balanceOf(vow), 100 ether);
    }

    function test_floppy_bite() public {
        lad.file("gold", 'spot', int(ray(2.5 ether)));
        lad.frob("gold",  40 ether, 100 ether);
        lad.file("gold", 'spot', int(ray(2 ether)));  // now unsafe

        assertEq(vow.sin(vow.era()),   0 ether);
        cat.bite("gold", this);
        assertEq(vow.sin(vow.era()), 100 ether);

        assertEq(vow.Sin(), 100 ether);
        vow.flog(vow.era());
        assertEq(vow.Sin(),   0 ether);
        assertEq(vow.Woe(), 100 ether);
        assertEq(vow.Joy(),   0 ether);
        assertEq(vow.Ash(),   0 ether);

        vow.file("lump", uint(10 ether));
        uint f1 = vow.flop();
        assertEq(vow.Woe(),  90 ether);
        assertEq(vow.Joy(),   0 ether);
        assertEq(vow.Ash(),  10 ether);
        flop.dent(f1, 1000 ether, 10 ether);
        assertEq(vow.Woe(),  90 ether);
        assertEq(vow.Joy(),  10 ether);
        assertEq(vow.Ash(),  10 ether);

        assertEq(gov.balanceOf(this),  100 ether);
        flop.warp(4 hours);
        flop.deal(f1);
        assertEq(gov.balanceOf(this), 1100 ether);
    }

    function test_flappy_bite() public {
        // get some surplus
        vat.mint(vow, 100 ether);
        assertEq(pie.balanceOf(vow),  100 ether);
        assertEq(gov.balanceOf(this), 100 ether);

        vow.file("lump", uint(100 ether));
        assertEq(vow.Awe(), 0 ether);
        uint id = vow.flap();

        assertEq(pie.balanceOf(this),   0 ether);
        assertEq(gov.balanceOf(this), 100 ether);
        flap.tend(id, 100 ether, 10 ether);
        flap.warp(4 hours);
        flap.deal(id);
        assertEq(pie.balanceOf(this),   100 ether);
        assertEq(gov.balanceOf(this),    90 ether);
    }
}