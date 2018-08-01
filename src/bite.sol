pragma solidity ^0.4.24;

contract Flippy{
    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract VatLike {
    function ilks(bytes32) public view returns (int,int);
    function urns(bytes32,address) public view returns (int,int,int);
    function grab(bytes32,address,address,int,int) public returns (uint);
}

contract LadLike {
    function ilks(bytes32) public view returns (int,int);
}

contract VowLike {
    function fess(uint) public;
}

contract Cat {
    address public vat;
    address public lad;
    address public vow;
    uint256 public lump;  // rad // fixed lot size

    modifier auth { _; }  // todo: require(msg.sender == root);

    struct Ilk {
        int256  chop;  // ray
        address flip;
    }
    mapping (bytes32 => Ilk) public ilks;

    struct Flip {
        bytes32 ilk;
        address lad;
        uint256 ink;
        uint256 tab;  // rad
    }
    Flip[] public flips;

    constructor(address vat_, address lad_, address vow_) public {
        vat = vat_;
        lad = lad_;
        vow = vow_;
    }

    function file(bytes32 what, uint risk) public auth {
        if (what == "lump") lump = risk;
    }
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == "chop") ilks[ilk].chop = risk;
    }
    function fuss(bytes32 ilk, address flip) public auth {
        ilks[ilk].flip = flip;
    }

    function bite(bytes32 ilk, address guy) public returns (uint) {
        (int rate, int Art)           = VatLike(vat).ilks(ilk); Art;
        (int spot, int line)          = LadLike(lad).ilks(ilk); line;
        (int gem , int ink , int art) = VatLike(vat).urns(ilk, guy); gem;
        int tab = mul(art, rate);

        require(mul(ink, spot) < tab);  // !safe

        VatLike(vat).grab(ilk, guy, vow, -ink, -art);
        VowLike(vow).fess(uint(tab));

        return flips.push(Flip(ilk, guy, uint(ink), uint(tab))) - 1;
    }

    function flip(uint n, uint rad) public returns (uint) {
        Flip storage f = flips[n];
        Ilk  storage i = ilks[f.ilk];

        require(rad <= f.tab);
        require(rad == lump || (rad < lump && rad == f.tab));

        uint tab = f.tab;
        uint ink = f.ink * rad / tab;

        f.tab -= rad;
        f.ink -= ink;

        return Flippy(i.flip).kick({ lad: f.lad
                                   , gal: vow
                                   , tab: uint(rmul(int(rad), i.chop))
                                   , lot: uint(ink)
                                   , bid: uint(0)
                                   });
    }

    function mul(int x, int y) internal pure returns (int z) {
        z = x * y;
        require(y >= 0 || x != -2**255);
        require(y == 0 || z / y == x);
    }

    int constant RAY = 10 ** 27;
    function rmul(int x, int y) internal pure returns (int z) {
        z = x * y;
        require(y >= 0 || x != -2**255);
        require(y == 0 || z / y == x);
	z = z / RAY;
    }
}
