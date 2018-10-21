pragma solidity ^0.4.22;

// Static board representation for a 'Settlers of Catan' style board with radius 3 (19 tiles)
// Tile numbering starts at 1 in the top-left corner and spirals around clockwise
contract HexBoard3 {

  // To ease iteration
  uint8 constant public minTileId= 1;
  uint8 constant public maxTileId = 19;
  uint8 constant public numTiles = 19;

  // Any 0s in the neighbor array represent non-neighbors. There might be a better way to do this, but w/e
  mapping(uint8 => uint8[6]) public tileToNeighbors;
  uint8 constant public nullNeighborValue = 0;

  // TODO: Add neighbor calculation in if we want to use neighbors in jackpot calculation
  constructor() public {
  }
}
