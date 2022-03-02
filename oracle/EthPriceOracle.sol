/*
Now it's time to move forward to the oracle contract. Let's start by taking a look into what this contract should do.

The gist of it is that the oracle contract acts as a bridge, enabling the caller contracts to access the ETH price feed. To achieve this, it just implements two functions: getLatestEthPrice and setLatestEthPrice.
*/

pragma solidity 0.5.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./CallerContractInterface.sol";
contract EthPriceOracle is Ownable {
  uint private randNonce = 0;
  uint private modulus = 1000;
  mapping(uint256=>bool) pendingRequests;
  event GetLatestEthPriceEvent(address callerAddress, uint id);
  event SetLatestEthPriceEvent(uint256 ethPrice, address callerAddress);
  //To allow the callers to track their requests, the getLatestEthPrice function should first compute the request id and, for security reasons, this number should be hard to guess.
  function getLatestEthPrice() public returns (uint256) {
    randNonce++;
    uint id = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % modulus;
    //Next, you would want to implement a simple system that keeps tracks of pending requests. Just like you did for the caller contract, for this you'll be using a mapping. This time let's call it pendingRequests.
    //The getLatestEthPrice function should also fire an event and, lastly, it should return the request id.
    pendingRequests[id] = true;
    emit GetLatestEthPriceEvent(msg.sender, id);
    return id;
  }
/*
Awesome! In this chapter, you'll be putting together what you've learned so far to write the setLatestEthPrice function. This is going be a bit more complex, but there's nothing to be afraid of. I'll avoid big leaps of thought and make sure each step is well explained.
So, the JavaScript component of the oracle (the one we'll write in the next lesson) retrieves the ETH price from the Binance public API and then calls the setLatestEthPrice, passing it the following arguments:
The ETH price,
The address of the contract that initiated the request
The id of the request.
First, your function must make sure that only the owner can call this function. Then, similarly to the code you've written in Chapter 6, your function should check whether the request id is valid. If so, it should remove it from pendingRequests.
*/
   function setLatestEthPrice(uint256 _ethPrice, address _callerAddress, uint256 _id) public onlyOwner {
   //Use require to check if pendingRequests[_id] is true. The second parameter should be "This request is not in my pending list.". If you don't know how to do this, revisit Chapter 6 to refresh your memory.
   require(pendingRequests[_id], "This request is not in my pending list.");
   //Remove id from the pendingRequests mapping. In case you're stuck, here's how you can remove a key from a mapping:
   delete pendingRequests[_id];
   
   /*
The setLatestEthPrice function is almost finished. Next, you'll have to:

Instantiate the CallerContractInstance. In case you forgot how to do this or you need a bit of inspiration, take a quick glance at the following example:
MyContractInterface myContractInstance;
myContractInstance = MyContractInterface(contractAddress)
With the caller contract instantiated, you can now execute its callback method and pass it the new ETH price and the id of the request.
Lastly, you'd want to fire an event to notify the front-end that the price has been successfully updated.
*/

         //Let's create a CallerContractInterface named callerContractInstance.   
    CallerContractInterface callerContractInstance;
    //Initialize callerContractInstance with the address of the caller contract, just like we did with myContractInstance above. Note that the address of the caller contract should come from the function parameters.
    callerContractInstance = CallerContractInterface(_callerAddress);
    callerContractInstance.callback(_ethPrice, _id);
    emit SetLatestEthPriceEvent(_ethPrice, _callerAddress);
  }
 }


}
