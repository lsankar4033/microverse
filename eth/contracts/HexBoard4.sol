pragma solidity ^0.4.22;

// Static board representation for a 'Settlers of Catan' style board with radius 4 (7 tiles)
// Tile numbering starts at 1 in the top-left corner and spirals around clockwise
contract HexBoard4 {

  // To ease iteration
  uint8 constant public minTileId= 1;
  uint8 constant public maxTileId = 7;
  uint8 constant public numTiles = 7;

  // Any 0s in the neighbor array represent non-neighbors. There might be a better way to do this, but w/e
  mapping(uint8 => uint8[6]) public tileToNeighbors;
  uint8 constant public nullNeighborValue = 0;

  constructor() public {
    tileToNeighbors[1] = [2, 18, 19, 0, 0, 0];
    tileToNeighbors[2] = [1, 3, 19, 20, 0, 0];
    tileToNeighbors[3] = [2, 4, 20, 21, 0, 0];
    tileToNeighbors[4] = [3, 5, 21, 0, 0, 0];
    tileToNeighbors[5] = [4, 6, 21, 22, 0, 0];
    tileToNeighbors[6] = [5, 7, 22, 23, 0, 0];
    tileToNeighbors[7] = [6, 8, 23, 0, 0, 0];
    tileToNeighbors[8] = [7, 9, 23, 24, 0, 0];
    tileToNeighbors[9] = [8, 10, 24, 25, 0, 0];
    tileToNeighbors[10] = [9, 11, 25, 0, 0, 0];
    tileToNeighbors[11] = [10, 12, 25, 26, 0, 0];
    tileToNeighbors[12] = [11, 13, 26, 27, 0, 0];
    tileToNeighbors[13] = [12, 14, 27, 0, 0, 0];
    tileToNeighbors[14] = [13, 15, 27, 28, 0, 0];
    tileToNeighbors[15] = [14, 16, 28, 29, 0, 0];
    tileToNeighbors[16] = [15, 17, 29, 0, 0, 0];
    tileToNeighbors[17] = [16, 18, 29, 30, 0, 0];
    tileToNeighbors[18] = [1, 17, 19, 30, 0, 0];
    tileToNeighbors[19] = [1, 2, 18, 20, 30, 31];
    tileToNeighbors[20] = [2, 3, 19, 21, 31, 32];
    tileToNeighbors[21] = [3, 4, 5, 20, 22, 32];
    tileToNeighbors[22] = [5, 6, 21, 23, 32, 33];
    tileToNeighbors[23] = [6, 7, 8, 22, 24, 33];
    tileToNeighbors[24] = [8, 9, 23, 25, 33, 34];
    tileToNeighbors[25] = [9, 10, 11, 24, 26, 34];
    tileToNeighbors[26] = [11, 12, 25, 27, 34, 35];
    tileToNeighbors[27] = [12, 13, 14, 26, 28, 35];
    tileToNeighbors[28] = [14, 15, 27, 29, 35, 36];
    tileToNeighbors[29] = [15, 16, 17, 28, 30, 36];
    tileToNeighbors[30] = [17, 18, 19, 29, 31, 36];
    tileToNeighbors[31] = [19, 20, 30, 32, 36, 37];
    tileToNeighbors[32] = [20, 21, 22, 31, 33, 37];
    tileToNeighbors[33] = [22, 23, 24, 32, 34, 37];
    tileToNeighbors[34] = [24, 25, 26, 33, 35, 37];
    tileToNeighbors[35] = [26, 27, 28, 34, 36, 37];
    tileToNeighbors[36] = [28, 29, 30, 31, 35, 37];
    tileToNeighbors[37] = [31, 32, 33, 34, 35, 36];
  }
}
