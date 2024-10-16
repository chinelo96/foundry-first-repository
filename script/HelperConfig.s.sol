// SPDX-License-Identifier: MIT


// we will do two things in this contract
// geploy mocks when we are on a glocal local anvil chain
// keep track of contract address across diffrent chains

pragma solidity ^0.8.18;
import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {
//if we are on a local anvil we deploy mock
//otherwise grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;  //Eth/Usd pricefeed address
       }

    constructor() {
        if (block.chainid == 11155111) {
                activeNetworkConfig = getSepoliaEthConfig();}

                else if (block.chainid == 1)
                {activeNetworkConfig = getMainnetEthConfig();}
           else {
            activeNetworkConfig = getOrCreateAnvilEthconfig();}   
    }
 
      function getSepoliaEthConfig()  public pure returns(NetworkConfig memory) {
        // we need the pricefeed addrress
         NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
          return sepoliaConfig;
       }

      function getMainnetEthConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory MainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return MainnetConfig;
      }

      function getOrCreateAnvilEthconfig()  public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
        return activeNetworkConfig;}
       vm.startBroadcast();
       MockV3Aggregator mockpricesFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
       vm.stopBroadcast();
       NetworkConfig memory AnvilEthconfig = NetworkConfig({priceFeed: address(mockpricesFeed)});
       return AnvilEthconfig;
     }



} 
