// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from  "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    address USER  = makeAddr("USER");
    uint256 constant SEND_VALUE = 10**18;
    uint256 constant STARTING_BALANCE = 10* 10**18;// 0r 10e18
    
 function setUp() external {
   // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
   DeployFundMe deployFundMe = new DeployFundMe();
   fundMe = deployFundMe.run();
   vm.deal(USER,STARTING_BALANCE);
  }
  //this function is to check if truly the minimum usd is 5
   function testMinimumDollarIsFive() public view {
      assertEq(fundMe.MINIMUM_USD(), 5e18);
}
 // this function is to check if truly the i_owner is this contract FundMetest.sol because it is it that deployed FundMe
  function testOwnerIsMsgsender() public view {
   assertEq(fundMe.getOwner(), msg.sender);
   
  }
   function testPriceFeedVersionIsAccurate() public view {
      uint256 version = fundMe.getVersion();
      assertEq (version,4);
   }
 function testFundFailsWithoutEnoughETH() public {
   vm.expectRevert(); // this means the next line should revert
   fundMe.fund();
}
function testFundUpdatesFundsDataStructure() public {
   vm.prank(USER); // the next tx will be sent by USER
   fundMe.fund{value: SEND_VALUE}();
   uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
   assertEq(amountFunded, SEND_VALUE);
}
 function testAddsFundersToArrayOfFunders() public {
   vm.prank(USER);
   fundMe.fund{value: SEND_VALUE}();
   address funder = fundMe.getFunder(0);
   assertEq(funder, USER); 
 }

modifier funded(){
    vm.prank(USER);
   fundMe.fund{value: SEND_VALUE}();
   _;
}
 function testOnlyOnwerCanWithdraw() public funded{
   vm.prank(USER);
   vm.expectRevert();
   fundMe.withdraw();
   }

   function testWithdrawWithASingleFunder() public funded {
   //Arrange
   uint256 startingOwnerBalance = fundMe.getOwner().balance;
   uint256 startingFundMeBalance = address(fundMe).balance;
   //Act
    vm.prank(fundMe.getOwner());
   fundMe.withdraw();
   
   //Assert
   uint256 endingOwnerBalance = fundMe.getOwner().balance;
   uint256 endingFundMeBalance = address(fundMe).balance;
   assertEq(endingFundMeBalance, 0);
   assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
   }

   function testWithdrawFromMuiltiplyFunders() public funded{
   uint160 numberOfFunders = 10;
   uint160 startingFunderIndex = 1;
   for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value:SEND_VALUE}();
  }
  uint256 startingOwnerBalance = fundMe.getOwner().balance;
   uint256 startingFundMeBalance = address(fundMe).balance;
   //Act
   vm.startPrank(fundMe.getOwner());
   fundMe.withdraw();
   vm.stopPrank();
  //Assert
  assert(address(fundMe).balance == 0);
  assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
}

 function testWithdrawFromMuiltiplyFundersCheaper() public funded{
   uint160 numberOfFunders = 10;
   uint160 startingFunderIndex = 1;
   for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value:SEND_VALUE}();
  }
  uint256 startingOwnerBalance = fundMe.getOwner().balance;
   uint256 startingFundMeBalance = address(fundMe).balance;
   //Act
   vm.startPrank(fundMe.getOwner());
   fundMe.cheaperWithdraw();
   vm.stopPrank();
  //Assert
  assert(address(fundMe).balance == 0);
  assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
}

}