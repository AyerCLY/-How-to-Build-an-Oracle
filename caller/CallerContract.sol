/*
Now, instead of jumping directly to the oracle smart contract, we'll continue by looking into the caller smart contract. 
This is to help you understand the process from start to finish.
So the way you'd want to go about this is to write a simple function that saves the address of the oracle smart contract in a variable. 
Then, it instantiates the oracle smart contract so your contract can call its functions at any time.
*/

/*
For the caller contract to interact with the oracle, you must first define something called an interface.

Interfaces are somehow similar to contracts, but they only declare functions. In other words, an interface can't:

define state variables,
constructors,
or inherit from other contracts.
You can think of an interface as of an ABI. Since they're used to allow different contracts to interact with each other, all functions must be external

// add The onlyOwner Function Modifier to protect from "public"

//Using a Mapping to Keep Track of Requests
Mappings
Every user of your dapp can initiate an operation that'll require the caller contract to make request to update the ETH price. Since the caller has no control over when it'll get a response, you must find a way to keep track of these pending requests. Doing so, you'll be able to make sure that each call to the callback function is associated with a legit request.
To keep track of requests, you will use a mapping called myRequests. In Solidity, a mapping is basically a hash table in which all possible keys exist. But there's a catch. Initially, each value is initialized with the type's default value.
You can define a mapping using something like the following:
mapping(address => uint) public balances;

As mentioned in the previous chapter, calling the Binance public API is an asynchronous operation. Thus, the caller smart contract must provide a callback function which the oracle should call at a later time, namely when the ETH price is fetched.
Here's how the callback function works:
First, you would want to make sure that the function can only be called for a valid id. For that, you'll use a require statement.
Simply put, a require statement throws an error and stops the execution of the function if a condition is false.
Let's look at an example from the Solidity official documentation:
require(msg.sender == chairperson, "Only chairperson can give right to vote.");
The first parameter evaluates to true or false. If it's false, the function execution will stop and the smart contract will throw an error- "Only chairperson can give right to vote."
Once you know that the id is valid, you can go ahead and remove it from the myRequests mapping.
Note: To remove an element from a mapping, you can use something like the following: delete myMapping[key];
Lastly, your function should fire an event to let the front-end know the price was successfully updated.

Before you wrap up the callback function, you must make sure that only the oracle contract is allowed to call it.
In this chapter, you'll create a modifier that prevents other contracts from calling your callback function.
Note: We'll not delve into how modifiers work. If the details are fuzzy, go ahead and check out our previous lessons.

*/

pragma solidity 0.5.0;
//how you can call a function from a different contract?
// create interface e.g. EthPriceOracleInterface.sol
//1. Import from the "./EthPriceOracleInterface.sol" file
import "./EthPriceOracleInterface.sol";

// add The onlyOwner Function Modifier to protect "public" 
//1. import the contents of "openzeppelin-solidity/contracts/ownership/Ownable.sol"
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CallerContract is Ownable{
        // 1. Declare ethPrice
  uint256 private ethPrice;
  // 2. Declare `EthPriceOracleInterface`
  //Let's add an EthPriceOracleInterface variable named oracleInstance. Place it above the line of code that declares the oracleAddress variable. Let's make it private.
  EthPriceOracleInterface private oracleInstance;
 
  address private oracleAddress;
  
  //declared the myRequests mapping.The key is an uint256 and the value a bool.
  mapping(uint256=>bool) myRequests;
  
  event newOracleAddressEvent(address oracleAddress);
  event ReceivedNewRequestIdEvent(uint256 id);
  
  // 2. Declare PriceUpdatedEvent   
  event PriceUpdatedEvent(uint256 ethPrice, uint256 id);
  
  // 3. On the next line, add the `onlyOwner` modifier to the `setOracleInstanceAddress` function definition
  function setOracleInstanceAddress (address _oracleInstanceAddress) public onlyOwner {   
    oracleAddress = _oracleInstanceAddress;
    //3. Instantiate `EthPriceOracleInterface`
    oracleInstance = EthPriceOracleInterface(oracleAddress);
    // 4. Fire `newOracleAddressEvent`
    emit newOracleAddressEvent(oracleAddress);
  }
  
   // Define the `updateEthPrice` function
   //Make a function called updateEthPrice. It doesn't take any parameters, and it should be a public function.
   function updateEthPrice() public {
   //call the oracleInstance.getLatestEthPrice function. Store the returned value in a uint256 called id.
     uint256 id = oracleInstance.getLatestEthPrice() ;
     //Next, set the myRequests mapping for id to true.
     myRequests[id] = true;
     //The last line of your function should fire the ReceivedNewRequestIdEvent event. Pass it id as an argument.
     emit ReceivedNewRequestIdEvent(id);
    }
    
          //declared a public function called callback. It takes two arguments of type uint256: _ethPrice and _id.
   function callback(uint256 _ethPrice, uint256 _id) public onlyOracle {
        // 3. Continue here
     require(myRequests[_id] , "This request is not in my pending list.");
     ethPrice = _ethPrice;
     delete myRequests[_id];
     emit PriceUpdatedEvent(_ethPrice, _id);
   }
   
    modifier onlyOracle() {
      require(msg.sender == oracleAddress, "You are not authorized to call this function.");
      //The first line of code should use require to make sure that msg.sender equals oracleAddress. If not, it should throw the following error: "You are not authorized to call this function."
      //Remember from our previous lessons that, to execute the rest of the function, you should place an _; inside your modifier. Don't forget to add it.
      _;
    }
}
