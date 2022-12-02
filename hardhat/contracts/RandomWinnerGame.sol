//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomWinnerGame is VRFConsumerBase, Ownable {
    uint256 public fee;
    bytes32 public keyHash;

    bool public gameStarted;
    address[] public players;
    uint256 maxPlayers;
    uint256 public gameId;
    uint256 entryFee;

    event GameStarted(uint256 gameId, uint256 maxPlayers, uint256 entryFee);
    event PlayerJoined(uint256 gameId, address player);
    event GameEnded(uint256 gameId, address winner, bytes32 requestId);

    constructor(
        address _vrfCoordinatorContractAddress,
        address _linkContractAddress,
        bytes32 _vrfKeyHash,
        uint256 _vrfFee
    ) VRFConsumerBase(_vrfCoordinatorContractAddress, _linkContractAddress) {
        fee = _vrfFee;
        keyHash = _vrfKeyHash;
    }

    function startGame(
        uint256 _maxPlayers,
        uint256 _entryFee
    ) public onlyOwner {
        require(!gameStarted, "Game is already started");

        delete players;
        maxPlayers = _maxPlayers;
        entryFee = _entryFee;

        gameId++;
        gameStarted = true;

        emit GameStarted(gameId, maxPlayers, entryFee);
    }

    function joinGame() public payable {
        require(gameStarted, "Game is not started yet");
        require(
            players.length < maxPlayers,
            "Can not participate. Maximum players have already joined the game."
        );
        require(msg.value == entryFee, "Insufficient funds provided");

        players.push(msg.sender);
        emit PlayerJoined(gameId, msg.sender);

        if (players.length == maxPlayers) {
            selectRandomWinner();
        }
    }

    function selectRandomWinner() private returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough Link to get randomness from chainlink"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal virtual override {
        uint256 winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to transfer ether");
        emit GameEnded(gameId, winner, requestId);
        gameStarted = false;
    }

    receive() external payable {}

    fallback() external payable {}
}

/*

RandomWinnerGame contract address is:  0x55c3EDcC3cf2584330e4AdaF9883B998d42E1ce2
Holding the process for 30 seconds ...please wait for the contract to become available on etherscan!
Nothing to compile
Successfully submitted source code for contract
contracts/RandomWinnerGame.sol:RandomWinnerGame at 0x55c3EDcC3cf2584330e4AdaF9883B998d42E1ce2
for verification on the block explorer. Waiting for verification result...

Successfully verified contract RandomWinnerGame on Etherscan.
https://mumbai.polygonscan.com/address/0x55c3EDcC3cf2584330e4AdaF9883B998d42E1ce2#code

https://mumbai.polygonscan.com/address/0x55c3EDcC3cf2584330e4AdaF9883B998d42E1ce2#events

*/
