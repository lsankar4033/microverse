pragma solidity ^0.4.22;

// Static board representation for a 'Settlers of Catan' style board with radius 4 (7 tiles)
// Tile numbering starts at 1 in the top-left corner and spirals around clockwise
contract HexBoard4 {

  // To ease iteration
  uint8 constant public minTileId= 1;
  uint8 constant public maxTileId = 37;
  uint8 constant public numTiles = 37;

  // Any 0s in the neighbor array represent non-neighbors. There might be a better way to do this, but w/e
  mapping(uint8 => uint8[6]) public tileToNeighbors;
  uint8 constant public nullNeighborValue = 0;

  constructor() public {
      tileToNeighbors[1] = [2, 5, 6, 0, 0, 0];
      tileToNeighbors[2] = [1, 3, 6, 7, 0, 0];
      tileToNeighbors[3] = [2, 4, 7, 8, 0, 0];
      tileToNeighbors[4] = [3, 8, 9, 0, 0, 0];
      tileToNeighbors[5] = [1, 6, 10, 11, 0, 0];
      tileToNeighbors[6] = [1, 2, 5, 7, 11, 12];
      tileToNeighbors[7] = [2, 3, 6, 8, 12, 13];
      tileToNeighbors[8] = [3, 4, 7, 9, 13, 14];
      tileToNeighbors[9] = [4, 8, 14, 15, 0, 0];
      tileToNeighbors[10] = [5, 11, 16, 17, 0, 0];
      tileToNeighbors[11] = [5, 6, 10, 12, 17, 18];
      tileToNeighbors[12] = [6, 7, 11, 13, 18, 19];
      tileToNeighbors[13] = [7, 8, 12, 14, 19, 20];
      tileToNeighbors[14] = [8, 9, 13, 15, 20, 21];
      tileToNeighbors[15] = [9, 14, 21, 22, 0, 0];
      tileToNeighbors[16] = [10, 17, 23, 0, 0, 0];
      tileToNeighbors[17] = [10, 11, 16, 18, 23, 24];
      tileToNeighbors[18] = [11, 12, 17, 19, 24, 25];
      tileToNeighbors[19] = [12, 13, 18, 20, 25, 26];
      tileToNeighbors[20] = [13, 14, 19, 21, 26, 27];
      tileToNeighbors[21] = [14, 15, 20, 22, 27, 28];
      tileToNeighbors[22] = [15, 21, 28, 0, 0, 0];
      tileToNeighbors[23] = [16, 17, 24, 29, 0, 0];
      tileToNeighbors[24] = [17, 18, 23, 25, 29, 30];
      tileToNeighbors[25] = [18, 19, 24, 26, 30, 31];
      tileToNeighbors[26] = [19, 20, 25, 27, 31, 32];
      tileToNeighbors[27] = [20, 21, 26, 28, 32, 33];
      tileToNeighbors[28] = [21, 22, 27, 33, 0, 0];
      tileToNeighbors[29] = [23, 24, 30, 34, 0, 0];
      tileToNeighbors[30] = [24, 25, 29, 31, 34, 35];
      tileToNeighbors[31] = [25, 26, 30, 32, 35, 36];
      tileToNeighbors[32] = [26, 27, 31, 33, 36, 37];
      tileToNeighbors[33] = [27, 28, 32, 37, 0, 0];
      tileToNeighbors[34] = [29, 30, 35, 0, 0, 0];
      tileToNeighbors[35] = [30, 31, 34, 36, 0, 0];
      tileToNeighbors[36] = [31, 32, 35, 37, 0, 0];
      tileToNeighbors[37] = [32, 33, 36, 0, 0, 0];
  }
}
