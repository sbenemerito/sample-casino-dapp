pragma solidity ^0.4.23;

contract Casino {
    address public owner;
    address[] public players;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maximumNumberOfBets = 5;

    struct Player {
        uint256 amountBet;
        uint8 numberSelected;
    }

    mapping (address => Player) public playerInfo;

    function() public payable {}

    constructor (uint256 _minimumBet, uint256 _maximumPlayers) public {
        owner = msg.sender;
        if (_minimumBet != 0) minimumBet = _minimumBet;
        if (_maximumPlayers > 1) maximumNumberOfBets = _maximumPlayers;
    }

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }

    function checkPlayerExists(address _player) public view returns (bool) {
        for (uint8 i = 0; i < players.length; i++) {
            if (players[i] == _player) return true;
        }
        return false;
    }

    function _resetData() private {
        players.length = 0;
        totalBet = 0;
        numberOfBets = 0;
    }

    function _generateNumberWinner() private view returns (uint8) {
        return uint8(block.number % 10 + 1);  // bad implementation of randomness, just for testing
    }

    function _rewardWinners() private {
        uint8 winningNumber = _generateNumberWinner();
        uint8 winnerCounter = 0;
        address[5] memory winners;

        for (uint8 x = 0; x < players.length; x++) {
            address playerAddress = players[x];

            if (playerInfo[playerAddress].numberSelected == winningNumber) {
                winners[winnerCounter] = playerAddress;
                winnerCounter++;
            }
            delete playerInfo[playerAddress];
        }

        uint256 winningAmount = totalBet / winnerCounter;

        for (uint8 y = 0; y < winners.length; y++) {
            if (winners[y] != address(0)) winners[y].transfer(winningAmount);
        }

        _resetData();
    } 

    function bet(uint8 _numberSelected) public payable {
        require(!checkPlayerExists(msg.sender), "Player has already placed a bet");
        require(_numberSelected >= 1 && _numberSelected <= 10, "Selected number should be 1-10");
        require(msg.value >= minimumBet, "Placed bet is not greater than or equal to minimum bet");

        playerInfo[msg.sender] = Player(msg.value, _numberSelected);
        players.push(msg.sender);
        totalBet += msg.value;
        numberOfBets++;

        if (numberOfBets == maximumNumberOfBets) _rewardWinners();
    }
}