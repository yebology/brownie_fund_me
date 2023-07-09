// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // using SafeMathChainlink for uint256;
    mapping(address => uint256) public addressToValueFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    // constructor hanya dieksekusi sekali dan otomatis
    constructor(address _priceFeed) public {
        owner = msg.sender; // siapapun yang deploy smart contract itu msg.sender
        // mengapa declare owner = msg.sender di constructor?
        // tujuan : menetapkan pemilik kontrak pada saat penciptaan kontrak itu sendiri (saat di deploy)
        // constructor akan jalan saat di deploy
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        // pake WEI, makanya 1e18
        uint256 minimumUSD = 10 * 1e18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "Please spend more ETH! "
        );
        // ini itu artie saldoe nambah dari saldo sebelumnya
        // funfact : value yang muncul itu dalam bentuk WEI nantinya
        addressToValueFunded[msg.sender] += msg.value;
        // what the ETH -> USD conversion rate
        funders.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10 ** 18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10 ** 18;
        return (minimumUSD * precision) / price;
    }

    function getVersion() public view returns (uint256) {
        // addressnya di parameter ambil dari sini
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        // di sepolia ETH/USD
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // addressnya di parameter ambil dari sini
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        // di sepolia ETH/USD
        // nandain kalo ada 5 variabel, cm 1 yang mau di return, biar rapi codenya
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // buat nggeser 10 angka desimal makanya dikali 10^10
        uint256 convertedAnswer = uint256(answer * 1e10);
        return convertedAnswer;
    }

    // Wei : 10^18
    // Gwei : 10^9
    // Ether : 1
    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        // convert pake 1 ether alias 10^9 Gwei
        uint256 ethPrice = getPrice();
        // mengubah satuan wei ke satuan ether
        uint256 ethAmountInUSD = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUSD;
        // 1,844.498224900
    }

    // mengubah behaviour function --> modifier
    modifier onlyOwner() {
        require(msg.sender == owner); // yang bisa cuma owner
        _; // artinya kalau requirenya true, maka logika selanjutnya jalan
    }

    function withdraw() public payable onlyOwner {
        // transfer semua isi balancenya
        // buat transfer balik dari kontrak ke pengirim
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 i; i < funders.length; i++) {
            addressToValueFunded[funders[i]] = 0;
        }
        funders = new address[](0);
    }
}
