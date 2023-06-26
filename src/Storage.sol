// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// contract Storage {
//     uint256 favouriteNumber;
//     bool someBool;
//     uint256[] myArray;

//     constructor() {
//         favouriteNumber = 25;
//         someBool = true;
//         myArray.push(22);
//     }

//     function addFive() public {
//         uint256 newFavNumber = favouriteNumber + 5;
//         string memory name = "Name";
//     }
// }

// Explanation about Storage

// forge inspect FundMe storageLayout
// this will show the storageLayout of FundMe contract

//////////////////////////
// Storage Variables
//////////////////////////

// Whenever we have global variables like ${favouriteNumber} in this case
// It will be stored in something called "Storage" and they persist throught the contract
// Storage will be like big array each slot is 32bytes long and all the variables will be alloted there
// these persisted variables are called state varaibles.
// ie.,
// [0]
// [1]
// [2]
// [3]
// ..............
// first state variable will be automatically alloted to slot[0]
// next state variable will be alloted to slot[1]
// for eg., favourtieNumber is 25;
// this 25 should be sored in slot[0], before it get's stored values will be converted into hex representation
// then hex representation will be stored in that particular slot
// hex representation of 25 is 0x19
// hex representation of uint256 25 is 0x0000000000000000000000000000000000000000000000000000000000000019
// The uint256 representation of 25 in hexadecimal has 64 digits, which corresponds to 256 bits.
// [0] 0x00...19
///////////////////////////////
// next we have another varibale called someBool
// the value of some bool will be stored in slot[1], its hex representation
// [1] 0x00...01
//////////////////////////////
// before 2 global variables were static in length
// let's see about variables which are dynamic in length [arrays]

//////////////////////////
// Constants and Immutables
//////////////////////////

// Constants: Constants are replaced with their actual values during compilation,
// so they are not stored in storage at runtime.
// Instead, their values are directly substituted into the bytecode wherever they are referenced.
// This means that constants are effectively "hard-coded" into the compiled contract and do not consume any storage space.

// Immutable variables are not stored in the storage of Solidity contracts.
// Instead, their values are directly inserted into the runtime code during contract deployment.
// This optimization makes accessing immutable variables more efficient in terms of gas costs compared to regular state variables.

//////////////////////////
// Dynamic and Fixed length Arrays
//////////////////////////

// When you declare a dynamic array in Solidity, such as uint256[] values,
// the array itself is stored as a reference in storage, while the actual elements of the array are stored separately in memory.
// Let's consider an example with a dynamic array uint256[] values that contains three elements: 10, 20, and 30.
// uint256[] values = [10, 20, 30];
// In storage, a slot is allocated to store the reference to the dynamic array.
// This reference points to the location in memory where the actual array elements are stored.
// For arrays, a sequential storage spot is taken up for the length of the array.
// For mappings, a sequential storage spot is taken up, but left blank.
// ---------------------------
// |     Storage Slot 0      |
// ---------------------------
// |   values (reference)    |
// ---------------------------
// The actual array elements (10, 20, 30) are stored in memory, which is separate from storage.
// ---------------------------
// |      Memory Slot 0      |
// ---------------------------
// |         10              |
// ---------------------------
// |         20              |
// ---------------------------
// |         30              |
// ---------------------------
/////////////////////////////////////////
// If the array is fixed length, it will be directly stored in the storage, because it's size is known at compile time
// uint256[3] values = [10, 20, 30];
// ---------------------------
// |     Storage Slot 0      |
// ---------------------------
// |   values (10, 20, 30)   |
// ---------------------------
/////////////////////////////////////////

//////////////////////////
// Structs
//////////////////////////

// Structs in Solidity are stored in a straightforward and contiguous manner within the contract's storage.

// When a struct is defined and used in a contract, the storage layout for the struct follows these rules:

// Each member of the struct is stored sequentially, one after another, in storage slots.
// The size of each member is determined by its data type, and it may occupy multiple storage slots if necessary.
// The struct itself starts at a new storage slot, and its members are packed tightly according to their data types.
// Let's illustrate this with an example:
// struct Person {
//     uint256 id;
//     string name;
//     uint8 age;
// }
// In this example, the Person struct has three members: id of type uint256, name of type string, and age of type uint8.
// When you declare a variable of type Person and store values in it,
// the struct members will be stored contiguously in storage slots, like this:
// -------------------------------
// |       Storage Slot 0        |
// -------------------------------
// |          Person             |
// -------------------------------
// |           id                |
// -------------------------------
// |          name               |
// -------------------------------
// |           age               |
// -------------------------------
// Sample data:

// id: 12345
// name: "John Doe"
// age: 30
// When we store this Person struct in Solidity, it will be stored in storage slots as follows:

// -------------------------------
// |       Storage Slot 0        |
// -------------------------------
// |          Person             |
// -------------------------------
// |           12345             |
// -------------------------------
// |       Storage Slot 1        |
// -------------------------------
// |         "John Doe"          |
// -------------------------------
// |           age               |
// -------------------------------
// |            30               |
// -------------------------------

// The id member of type uint256 will occupy a single storage slot and store the value 12345.

// The name member of type string will also occupy a single storage slot.
// However, the actual string data "John Doe" will be stored in a separate storage slot outside the struct.
// The name member within the struct will store a reference (a pointer) to the storage slot where the string data is stored.

// The age member of type uint8 will occupy a single storage slot and store the value 30.
///////////////////////////////////////

//////////////////////////
// Mapping
//////////////////////////

// Mappings in Solidity are stored differently compared to arrays or structs.
// Mappings use a key-value data structure for efficient lookup and retrieval of values.

// Internally, mappings in Solidity are implemented as hash tables or hash maps.
// Let's explore how mappings are stored in Solidity using a visual example.

// Consider the following mapping declaration:
// mapping(uint256 => string) names;
// In this example, the mapping names associates uint256 keys with corresponding string values.

// When a value is assigned to a specific key in the mapping,
// Solidity computes the hash of the key and uses it as an index to store the corresponding value.

// Let's assume we store the following key-value pairs in the mapping:
// names[100] = "Alice";
// names[200] = "Bob";
// names[300] = "Charlie";

// ---------------------------
// |     Storage Slot 0      |
// ---------------------------
// |  Key  |      Value      |
// ---------------------------
// |  100  |    "Alice"      |
// |  200  |     "Bob"       |
// |  300  |   "Charlie"     |
// ---------------------------

// Each key-value pair is stored in a separate entry within the storage slot.
// The hash of the key determines the location where the value is stored within the slot.

// When you access a value in the mapping using its key,
// Solidity computes the hash of the key and retrieves the corresponding value from the storage slot.

// Mappings provide efficient lookup and retrieval of values based on their keys.
// The underlying hash table data structure allows for fast access and efficient storage of key-value pairs.

// It's important to note that mappings in Solidity are not iterable.
// You cannot iterate over the keys or values in a mapping directly.
// However, you can access individual values using their corresponding keys.

/////////////////////////////////
// Variables inside Function
/////////////////////////////////

// When we have variables inside fn, for eg in addFive()
// those variable only exist for the duration of the function.
// so they will stored in memory instead of storage
// memory in Solidity functions can be visualized as a temporary storage space
// that is created during function execution and destroyed after the function call ends.
// Variables declared inside functions are stored in memory for the duration of the function call,
// ensuring efficient usage of temporary storage.
// whenver you declare string inside a fn, you have to explicitly mention it should be stored in memory.
