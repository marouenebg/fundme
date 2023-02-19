// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error NotOwner();
contract FundMe {

uint256 public constant minimumUsd = 50 * 1e18;
mapping (address => uint256) public addressToAmountFunded;
address[] public funders ;
address public immutable owner;

constructor() {
    owner = msg.sender;
}
function fund() public payable {
  //  want to be able to set a minimum amount in USD
  require (getConversionRate(msg.value) >= minimumUsd, "Didn't send enough eth");
  addressToAmountFunded[msg.sender] += getConversionRate(msg.value) ;
  funders.push(msg.sender);


}
function getPrice() public view returns (uint256) {
    //ABI
    //ADDRESS 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    (,int256 price,,,) = priceFeed.latestRoundData();
    //price of ETH in terms of USD
    return uint256(price * 1e10);
}
function getConversionRate(uint256 ethAmount) public view returns (uint256) {
    uint256 ethPrice = getPrice();
    uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    return ethAmountInUsd ;
}
function withdraw() public onlyOwner {
(bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
require(callSuccess, "call function failed");
}
receive() external payable {
fund();
}
fallback() external payable {
fund();
}

modifier onlyOwner {
    if (msg.sender != owner)
    revert NotOwner();
    _;
}
}