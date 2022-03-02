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

*/

pragma solidity 0.5.0;
//how you can call a function from a different contract?
// create interface e.g. EthPriceOracleInterface.sol
//1. Import from the "./EthPriceOracleInterface.sol" file
import "./EthPriceOracleInterface.sol";

contract CallerContract {
  // 2. Declare `EthPriceOracleInterface`
  //Let's add an EthPriceOracleInterface variable named oracleInstance. Place it above the line of code that declares the oracleAddress variable. Let's make it private.
  EthPriceOracleInterface private oracleInstance;
 
  address private oracleAddress;
  
  function setOracleInstanceAddress (address _oracleInstanceAddress) public {
    oracleAddress = _oracleInstanceAddress;
    //3. Instantiate `EthPriceOracleInterface`
    oracleInstance = EthPriceOracleInterface(oracleAddress);
  }
}
