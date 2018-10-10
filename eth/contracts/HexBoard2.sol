pragma solidity ^0.4.22;

// Static board representation for a 'Settlers of Catan' style board with radius 2 (7 tiles)
// Tile numbering starts at 1 in the top-left corner and spirals around clockwise
contract HexBoard2 {

  // To ease iteration
  uint8 constant public minTileId= 1;
  uint8 constant public maxTileId = 7;
  uint8 constant public numTiles = 7;

  // Any 0s in the neighbor array represent non-neighbors. There might be a better way to do this, but w/e
  mapping(uint8 => uint8[6]) public tileToNeighbors;
  uint8 constant public nullNeighborValue = 0;

  constructor() public {
    tileToNeighbors[1] = [6, 7, 2, 0, 0, 0];
    tileToNeighbors[2] = [1, 7, 3, 0, 0, 0];
    tileToNeighbors[3] = [2, 7, 4, 0, 0, 0];
    tileToNeighbors[4] = [3, 7, 5, 0, 0, 0];
    tileToNeighbors[5] = [4, 7, 6, 0, 0, 0];
    tileToNeighbors[6] = [5, 7, 1, 0, 0, 0];
    tileToNeighbors[7] = [1, 2, 3, 4, 5, 6];
  }
}
