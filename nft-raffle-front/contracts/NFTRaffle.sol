pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTRaffle is Ownable, ERC721 {
    address host;
    address[] public players;
    uint256 public ticketPrice;

    event Transfer(address to, uint tokenId);

    function lottery() public {
        host = msg.sender;
    }

    function createRaffle() {}

    function purchaseTicket(uint amount) payable, external {
        require(msg.value >= ticketPrice);
        uint numberOfTickets = ticketPrice * amount;
        payable(numberOfTickets).transfer(address(this).balance);
    }

    function pickWinner(address tokenContract, uint tokenId, ) external onlyOwner {
        // does each need their own ID?
        uint index = random() % players.length;
        address winner = players[index];
        payable (winner).transfer(address(this).balance); // token transfer?
        payable approve(winner, tokenId);
        players = new address[](0);
    }

    function transfer(address to, uint tokenId) external {
        transferFrom(address(this), to, tokenId);
        emit Transfer(to, tokenId);
    }

    // creates a random hash that will become our winner
    function random() private view returns(uint){
        return  uint (keccak256(abi.encode(block.timestamp,  players)));
    }
}
