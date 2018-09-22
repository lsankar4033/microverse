pragma solidity ^0.4.22;

import "./HexBoard2.sol";

// TODO: Make HexBoard4
contract LandGrab is HexBoard2 {
  // Tx methods:
  // - buy(tileId, newPrice) payable
  // - setPrice(tileId, newPrice) payable

  // Visibility methods:
  // - getPrice(tileId)
  // - getNeighbors(tileId)
  // - getJackpotSize()
  // - getJackpotTimeRemaining()
  // - getBalance()
  // - withdraw()

  // Annoying things:
  // - tile numbering/neighboring (likely has to be statically defined or generated code)
  // - round timer management
  // - fee splitting

  constructor() public {
  }
}
