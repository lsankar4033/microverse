pragma solidity ^0.4.22;

// Zeppelin libs
import "./Math.sol";
import "./Ownable.sol";
import "./PullPayment.sol";
import "./SafeMath.sol";

// Microverse libs
import "./HexBoard3.sol";
import "./JackpotRules.sol";
import "./TaxRules.sol";

contract Microverse is
    HexBoard3,
    PullPayment,
    Ownable,
    TaxRules,
    JackpotRules {
    using SafeMath for uint256;
    using Math for uint256;

    // states this contract progresses through
    enum Stage {
        DutchAuction,
        GameRounds
    }
    Stage public stage = Stage.DutchAuction;

    modifier atStage(Stage _stage) {
        require(
            stage == _stage,
            "Function cannot be called at this time."
        );
        _;
    }

    // NOTE: stage arg for debugging purposes only! Should just be set to 0 by default
    constructor(uint startingStage) public {
        if (startingStage == uint(Stage.GameRounds)) {
            stage = Stage.GameRounds;
            _startGameRound();
        } else {
            _startAuction();
        }
    }

    mapping(uint8 => address) public tileToOwner;
    mapping(uint8 => uint256) public tileToPrice;
    uint256 public totalTileValue;

    // TODO: Change this once we define 'team'
    function _sendToTeam(uint256 amount) private {
        asyncSend(owner, amount);
    }

    function _changeTilePrice(uint8 tileId, uint256 newPrice) private {
        uint256 oldPrice = tileToPrice[tileId];
        tileToPrice[tileId] = newPrice;
        totalTileValue = (totalTileValue.sub(oldPrice)).add(newPrice);
    }

    event TileOwnerChanged(
        uint8 indexed tileId,
        address indexed oldOwner,
        address indexed newOwner,
        uint256 oldPrice,
        uint256 newPrice
    );

    //////////
    // Auction
    //////////

    event AuctionStarted(
        uint256 startingAuctionPrice,
        uint256 endingAuctionPrice,
        uint256 auctionDuration,
        uint256 startTime
    );

    event AuctionEnded(
        uint256 endTime
    );

    // NOTE: Beta test values
    uint256 constant public startingAuctionPrice = 0.1 ether;
    uint256 constant public endingAuctionPrice = 0.01 ether;
    uint256 constant public auctionDuration = 2 days; // period over which land price decreases linearly

    uint256 public numBoughtTiles;
    uint256 public auctionStartTime;

    function buyTileAuction(uint8 tileId, uint256 newPrice, address referrer) public payable atStage(Stage.DutchAuction) {
        require(
            tileToOwner[tileId] == address(0) && tileToPrice[tileId] == 0,
            "Can't buy a tile that's already been auctioned off"
        );

        uint256 tax = _priceToTax(newPrice);
        uint256 price = getTilePriceAuction();

        require(
            msg.value >= tax.add(price),
            "Must pay the full price and tax for a tile on auction"
        );

        // NOTE: *entire* payment distributed as Game taxes
        _distributeAuctionTax(msg.value, referrer);

        tileToOwner[tileId] = msg.sender;
        _changeTilePrice(tileId, newPrice);

        numBoughtTiles = numBoughtTiles.add(1);

        emit TileOwnerChanged(tileId, address(0), msg.sender, price, newPrice);

        if (numBoughtTiles >= numTiles) {
            endAuction();
        }
    }

    // NOTE: Some common logic with _distributeTax
    function _distributeAuctionTax(uint256 tax, address referrer) private {
        _distributeLandholderTax(_totalLandholderTax(tax));

        // NOTE: Because no notion of 'current jackpot', everything added to next pot
        uint256 totalJackpotTax = _jackpotTax(tax).add(_nextPotTax(tax));
        nextJackpot = nextJackpot.add(totalJackpotTax);

        // NOTE: referrer tax comes out of dev team tax
        bool hasReferrer = referrer != address(0);
        _sendToTeam(_teamTax(tax, hasReferrer));
        asyncSend(referrer, _referrerTax(tax, hasReferrer));
    }

    function getTilePriceAuction() public view atStage(Stage.DutchAuction) returns (uint256) {
        uint256 secondsPassed = 0;

        // This should always be the case...
        if (now > auctionStartTime) {
            secondsPassed = now.sub(auctionStartTime);
        }

        if (secondsPassed >= auctionDuration) {
            return endingAuctionPrice;
        } else {
            uint256 maxPriceDelta = startingAuctionPrice.sub(endingAuctionPrice);
            uint256 actualPriceDelta = (maxPriceDelta.mul(secondsPassed)).div(auctionDuration);

            return startingAuctionPrice.sub(actualPriceDelta);
        }
    }

    function endAuction() private {
        require(
            numBoughtTiles >= numTiles,
            "Can't end auction if are unbought tiles"
        );

        stage = Stage.GameRounds;
        _startGameRound();

        emit AuctionEnded(now);
    }

    function _startAuction() private {
        auctionStartTime = now;
        numBoughtTiles = 0;

        emit AuctionStarted(startingAuctionPrice,
                            endingAuctionPrice,
                            auctionDuration,
                            auctionStartTime);
    }

    ///////
    // Game
    ///////

    // NOTE: Beta test values
    uint256 constant public startingRoundExtension = 4 hours;
    uint256 constant public halvingVolume = 10 ether; // tx volume before next duration halving
    uint256 constant public minRoundExtension = 10 seconds; // could set to 1 second

    uint256 public curExtensionVolume;
    uint256 public curRoundExtension;

    uint256 public roundEndTime;

    uint256 public jackpot;
    uint256 public nextJackpot;

    // Only emitted if owner doesn't *also* change
    event TilePriceChanged(
        uint8 indexed tileId,
        address indexed owner,
        uint256 oldPrice,
        uint256 newPrice
    );

    event GameRoundStarted(
        uint256 initJackpot,
        uint256 endTime
    );

    event GameRoundExtended(
        uint256 endTime
    );

    event GameRoundEnded(
        uint256 jackpot
    );

    ////////////////////////////////////
    // [Game] Round extension management
    ////////////////////////////////////

    function roundTimeRemaining() public view atStage(Stage.GameRounds) returns (uint256)  {
        if (_roundOver()) {
            return 0;
        } else {
            return roundEndTime.sub(now);
        }
    }

    function _extendRound() private {
        roundEndTime = now + curRoundExtension;

        emit GameRoundExtended(roundEndTime);
    }

    function _startGameRound() private {
        curExtensionVolume = 0 ether;
        curRoundExtension = startingRoundExtension;

        jackpot = nextJackpot;
        nextJackpot = 0;

        _extendRound();

        emit GameRoundStarted(jackpot, roundEndTime);
    }

    function _roundOver() private view returns (bool) {
        return now >= roundEndTime;
    }

    modifier duringRound() {
        require(
            !_roundOver(),
            "Round can't be over!"
        );
        _;
    }

    // NOTE: Must be called for all volume we want to count towards round extension halving
    function _logRoundExtensionVolume(uint256 amount) private {
        curExtensionVolume = curExtensionVolume.add(amount);

        if (curExtensionVolume >= halvingVolume) {
            curRoundExtension = curRoundExtension.div(2).max(minRoundExtension);
            curExtensionVolume = 0 ether;
        }
    }

    ////////////////////////
    // [Game] Player actions
    ////////////////////////

    function endGameRound() public atStage(Stage.GameRounds) {
        require(
            _roundOver(),
            "Round must be over!"
        );

        _distributeJackpot();

        emit GameRoundEnded(jackpot);

        _startGameRound();
    }

    function setTilePrice(uint8 tileId, uint256 newPrice, address referrer)
        public
        payable
        atStage(Stage.GameRounds)
        duringRound {
        require(
            tileToOwner[tileId] == msg.sender,
            "Can't set tile price for a tile you don't own!"
        );

        uint256 tax = _priceToTax(newPrice);

        require(
            msg.value >= tax,
            "Must pay tax on new tile price!"
        );

        uint256 oldPrice = tileToPrice[tileId];
        _distributeTax(msg.value, referrer);
        _changeTilePrice(tileId, newPrice);

        // NOTE: Currently we extend round for 'every' tile price change. Alternatively could do only on
        // increases or decreases or changes exceeding some magnitude
        _extendRound();
        _logRoundExtensionVolume(msg.value);

        emit TilePriceChanged(tileId, tileToOwner[tileId], oldPrice, newPrice);
    }

    function buyTile(uint8 tileId, uint256 newPrice, address referrer)
        public
        payable
        atStage(Stage.GameRounds)
        duringRound {
        address oldOwner = tileToOwner[tileId];
        require(
            oldOwner != msg.sender,
            "Can't buy a tile you already own"
        );

        uint256 tax = _priceToTax(newPrice);

        uint256 oldPrice = tileToPrice[tileId];
        require(
            msg.value >= tax.add(oldPrice),
            "Must pay full price and tax for tile"
        );

        // pay seller
        asyncSend(oldOwner, tileToPrice[tileId]);
        tileToOwner[tileId] = msg.sender;

        uint256 actualTax = msg.value.sub(oldPrice);
        _distributeTax(actualTax, referrer);

        _changeTilePrice(tileId, newPrice);
        _extendRound();
        _logRoundExtensionVolume(msg.value);

        emit TileOwnerChanged(tileId, oldOwner, msg.sender, oldPrice, newPrice);
    }

    ///////////////////////////////////////
    // [Game] Dividend/jackpot distribution
    ///////////////////////////////////////

    function _distributeJackpot() private {
        uint256 winnerJackpot = _winnerJackpot(jackpot);
        uint256 landholderJackpot = _landholderJackpot(jackpot);
        _distributeWinnerAndLandholderJackpot(winnerJackpot, landholderJackpot);

        _sendToTeam(_teamJackpot(jackpot));
        nextJackpot = nextJackpot.add(_nextPotJackpot(jackpot));
    }

    function _calculatePriceComplement(uint8 tileId) private view returns (uint256) {
        return totalTileValue.sub(tileToPrice[tileId]);
    }

    // NOTE: These are bundled together so that we only have to compute complements once
    function _distributeWinnerAndLandholderJackpot(uint256 winnerJackpot, uint256 landholderJackpot) private {
        uint256[] memory complements = new uint256[](numTiles + 1); // inc necessary b/c tiles are 1-indexed
        uint256 totalPriceComplement = 0;

        uint256 bestComplement = 0;
        uint8 lastWinningTileId = 0;
        for (uint8 i = minTileId; i <= maxTileId; i++) {
            uint256 priceComplement = _calculatePriceComplement(i);

            // update winner
            if (bestComplement == 0 || priceComplement > bestComplement) {
                bestComplement = priceComplement;
                lastWinningTileId = i;
            }

            complements[i] = priceComplement;
            totalPriceComplement = totalPriceComplement.add(priceComplement);
        }
        uint256 numWinners = 0;
        for (i = minTileId; i <= maxTileId; i++) {
            if (_calculatePriceComplement(i) == bestComplement) {
                numWinners++;
            }
        }

        // distribute jackpot among all winners. save time on the majority (1-winner) case
        if (numWinners == 1) {
            asyncSend(tileToOwner[lastWinningTileId], winnerJackpot);
        } else {
            for (i = minTileId; i <= maxTileId; i++) {
                if (_calculatePriceComplement(i) == bestComplement) {
                    asyncSend(tileToOwner[i], winnerJackpot.div(numWinners));
                }
            }
        }

        // distribute landholder things
        for (i = minTileId; i <= maxTileId; i++) {
            // NOTE: We don't exclude the jackpot winner(s) here, so the winner(s) is paid 'twice'
            uint256 landholderAllocation = complements[i].mul(landholderJackpot).div(totalPriceComplement);

            asyncSend(tileToOwner[i], landholderAllocation);
        }
    }

    function _distributeTax(uint256 tax, address referrer) private {
        jackpot = jackpot.add(_jackpotTax(tax));

        _distributeLandholderTax(_totalLandholderTax(tax));
        nextJackpot = nextJackpot.add(_nextPotTax(tax));

        // NOTE: referrer tax comes out of dev team tax
        bool hasReferrer = referrer != address(0);
        _sendToTeam(_teamTax(tax, hasReferrer));
        asyncSend(referrer, _referrerTax(tax, hasReferrer));
    }

    function _distributeLandholderTax(uint256 tax) private {
        for (uint8 tile = minTileId; tile <= maxTileId; tile++) {
            if (tileToOwner[tile] != address(0) && tileToPrice[tile] != 0) {
                uint256 tilePrice = tileToPrice[tile];
                uint256 allocation = tax.mul(tilePrice).div(totalTileValue);

                asyncSend(tileToOwner[tile], allocation);
            }
        }
    }
}
