// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
line 972
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
    
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }



// @title  Main contract for NFTfi. This contract manages the ability to create
//         NFT-backed peer-to-peer loans.
// @author smartcontractdev.eth, creator of wrappedkitties.eth, cwhelper.eth, and
//         kittybounties.eth
// @notice There are five steps needed to commence an NFT-backed loan. 
        First,
//         the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi
//         contract to move their NFT's on their behalf. 
        Second, the borrower
//         signs an off-chain message for each NFT that they would like to
//         put up for collateral. This prevents borrowers from accidentally
//         lending an NFT that they didn't mean to lend, due to approveAll()
//         approving their entire collection. 
        Third, the lender calls
//         erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's
//         ERC20 tokens on their behalf. 
        Fourth, the lender signs an off-chain
//         message, proposing the amount, rate, and duration of a loan for a
//         particular NFT. 
        Fifth, the borrower calls NFTfi.beginLoan() to
//         accept these terms and enter into the loan. The NFT is stored in the
//         contract, the borrower receives the loan principal in the specified
//         ERC20 currency, and the lender receives an NFTfi promissory note (in
//         ERC721 form) that represents the rights to either the
//         principal-plus-interest, or the underlying NFT collateral if the
//         borrower does not pay back in time. The lender can freely transfer
//         and trade this ERC721 promissory note as they wish, with the
//         knowledge that transferring the ERC721 promissory note tranfsers the
//         rights to principal-plus-interest and/or collateral, and that they
//         will no longer have a claim on the loan. The ERC721 promissory note
//         itself represents that claim.
// @notice A loan may end in one of two ways. First, a borrower may call
//         NFTfi.payBackLoan() and pay back the loan plus interest at any time,
//         in which case they receive their NFT back in the same transaction.
//         Second, if the loan's duration has passed and the loan has not been
//         paid back yet, a lender can call NFTfi.liquidateOverdueLoan(), in
//         which case they receive the underlying NFT collateral and forfeit
//         the rights to the principal-plus-interest, which the borrower now
//         keeps.


    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

*/


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



/*interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}
*/
/*
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract IERC721 is IERC165  {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    function approve(address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;

}
*/
contract NFTRaffle is Ownable, IERC721Receiver, ReentrancyGuard {

    event Received(address, uint);
    
    function transferFrom(address from, address to, uint256 tokenId, address nftTokenContract) internal {
        // transfer can be called by the Owner or Approved Addresses
        IERC721(nftTokenContract).safeTransferFrom(from, to, tokenId);
    }

    function approveAll(address to, address nftTokenContract) internal {
        // approve can only be called by the owner of the NFT
        IERC721(nftTokenContract).setApprovalForAll(to, true);

    }

    function checkApproval(uint tokenId, address nftTokenContract) internal view returns(bool) {
        address approvedAddress = IERC721(nftTokenContract).getApproved(tokenId);
        return approvedAddress == address(this);
    } 

    function onERC721Received(address , address , uint256 , bytes memory) external pure override returns (bytes4){
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }



    /*
    function approve(address to, uint256 tokenId) public override {
        emit Approval(owner, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        emit Transfer(from, to, tokenId);
    }
    */
    // keep track of how many raffles are done.
    uint raffleCount = 0;

    // status : 1 = created; 2 = Finished successfully; 3 = Failed, not enough tokens sold; 4 = cancelled by owner.
    
    enum RaffleStatus {
        None,
        Created, 
        Live, 
        Finished,
        Failed,
        Cancelled
    }


    struct Raffle {
        uint raffleId;
        uint creationDate;
        address host;
        address nftTokenContract; 
        uint nftTokenId;
        uint raffleStartDate;
        uint raffleDuration; // in ms 
        uint minimumNumberOfTickets; 
        uint ticketPrice; // in ETH or wei
        uint numberOfTicketsSold;
        uint status;
        address[] players; 
        mapping(address => uint) numOfTicketsBought;
        int raffleWinnerTicket;
    }


    /*
    function claimNFTCancelled (uint raffleId) public {
        require(msg.sender == raffles[raffleId].host);
    
    }
    */
    

    // duplicate lotteryId? use an array instead of a mapping?
    mapping(uint256 => Raffle) public raffles;


    event Transfer(address to, uint tokenId);

    // remove
    function approveNFT(address nftTokenContract) external {
        approveAll(address(this), nftTokenContract);
    }

    function createRaffle( 
        address nftTokenContract, 
        uint nftTokenId, 
        uint ticketPrice, 
        uint raffleStartDate,
        uint raffleDuration,
        uint minimumNumberOfTickets
    ) external {
        // first we need to transfer the NFT.
        require(raffleStartDate >= block.timestamp);
        require(minimumNumberOfTickets > 0);
        // max raffle Duration?
        require(ticketPrice > 0);
        require(IERC721(nftTokenContract).ownerOf(nftTokenId) == msg.sender);

        // transfering the NFT to contract
            // 1. The holder has to approve the contract. (calling the approve or approveAll on the NFT contract itself)
            // 2. wehave to check that the raffle creator has done so. 
            // 3. they sign a "written text contract" where the terms & conditions of the raffle are specified. line 572
            // 2. The holder has to transfer the NFT.
        

        // first the raffle creator must have approved the nft to the contract.
        // require(checkApproval(nftTokenId, nftTokenContract));
        // Transfer NFT to the contract, until raffle is cancelled / unsuccessful or finished then it is able to be claimed.
        transferFrom(msg.sender, address(this), nftTokenId, nftTokenContract);
        // Will fail if it has not been approved. (done from the frontend).
        // nftTokenContract.transferFrom(msg.sender, address(this), nftTokenId);

        // Save loan details to a struct in memory first, to save on gas if any
        // of the below checks fail, and to avoid the "Stack Too Deep" error by
        // clumping the parameters together into one struct held in memory.
       

        ++raffleCount;
        raffles[raffleCount] = Raffle({
            raffleId: raffleCount,
            creationDate: block.timestamp,
            host: msg.sender,
            nftTokenContract: nftTokenContract,
            nftTokenId: nftTokenId,
            raffleStartDate: raffleStartDate,
            raffleDuration: raffleDuration,
            minimumNumberOfTickets: minimumNumberOfTickets,
            ticketPrice: ticketPrice,
            numberOfTicketsSold: 0,
            status: uint(RaffleStatus.Created),
            players: new address[](0),
            raffleWinnerTicket: -1
        });


    }

    function getRaffleDetails (uint raffleId) public view returns(Raffle memory) {
        return raffles[raffleId];
    }



    function updateStartDate (uint raffleId, uint newStartDate) external {
        require(msg.sender == raffles[raffleId].host);
        require(block.timestamp < raffles[raffleId].raffleStartDate);
        require(newStartDate > block.timestamp);
        raffles[raffleId].raffleStartDate = newStartDate;
        
        // if raffle is not live you can change the start date.

        // 1. you set the status to live.
        // 2. you set the startDate to certainDate 
    }

     modifier isActiveRaffle(uint raffleId) {
        require(raffles[raffleId].status == uint(RaffleStatus.Created), "Raffle is not active.");
        _;
    }

    function purchaseTicket(uint amount, uint raffleId) payable external isActiveRaffle(raffleId) {
        // 5. Check out this link for how to transfer ether, https://ethereum.stackexchange.com/questions/69381/using-address-call-value-to-send-ether-from-contract-to-contract-in-0-5-0-and-ab
        Raffle storage raffle = raffles[raffleId];
        require(
            msg.sender != raffle.host, 
            "The raffle host may not purchase from tickets for a token they are raffling."
        );
        require(raffle.raffleStartDate + raffle.raffleDuration >= block.timestamp, "Raffle has ended.");
        require(msg.value == raffle.ticketPrice * amount);
        require(amount > 0);
        uint totalPrice = raffle.ticketPrice * amount;
        raffle.numberOfTicketsSold = raffle.numberOfTicketsSold + amount;
        (bool success, ) = payable(address(this)).call{value: totalPrice}("");
        // receive() external payable {
        //     emit Received(msg.sender, msg.value);
        // } // not sure if this is required
        require(success, "Failed to send Ether");
        for (uint i = 0; i < amount; i++) {
            raffle.players.push(msg.sender);
        }
        raffle.numOfTicketsBought[msg.sender] = raffle.numOfTicketsBought[msg.sender] + amount;
    }

    function pickWinner(uint raffleId) external onlyOwner {
        // does each need their own ID?
        Raffle storage raffle = raffles[raffleId];
        require(block.timestamp >= raffle.raffleStartDate + raffle.raffleDuration, "Raffle is ongoing.");

        if (raffle.minimumNumberOfTickets <= raffle.numberOfTicketsSold) {
            uint index = random(raffleId) % raffle.players.length;
            address winner = raffle.players[index];
            transferFrom(address(this), winner, raffle.nftTokenId, raffle.nftTokenContract);
            raffle.status = uint(RaffleStatus.Finished);
            raffle.players = new address[](0);
        } else { // not enough tickets sold. Not sure where else this logic can live
            raffle.status = uint(RaffleStatus.Failed);
            transferFrom(address(this), raffle.host, raffle.nftTokenId, raffle.nftTokenContract);  
        }

        raffle.players = new address[](0); // do we want to delete all the players of a raffle when it is completed?
    }

    function claimMoney(uint raffleId) payable, external, nonReentrant {
        Raffle failedRaffle = raffles[raffleId]
        require(failedRaffle.status == RaffleStatus.Failed, "Cannot claim refund on active or successfully completed raffles.");
        require(failedRaffle.numOfTicketsBought[msg.sender] > 0, "No tickets left for refund");
        // approval required by claimer
        uint amountToClaim = failedRaffle.numOfTicketsBought[claimer] * failedRaffle.ticketPrice;
        (bool success, ) = payable(msg.sender).call{value: totalPrice}("");
        // receiver?
        // receive() external payable {
        //     emit Received(msg.sender, msg.value);
        // } // not sure if this is required
        require(success, "Failed to send Ether");
        failedRaffle.numOfTicketsBought[claimer] = 0;
    }

    // 2 options:
    // 1. user performs the transfer themselves.
    // 2. owner does the transfer to the winner.
    /*
    function transfer(address to, uint tokenId) external {
        transferFrom(address(this), to, tokenId);
        emit Transfer(to, tokenId);
    }
    */

    // creates a random hash that will become our winner
    function random(uint raffleId) private view returns(uint){
        return  uint (keccak256(abi.encode(block.timestamp, raffles[raffleId].players)));
    }

    function cancelRaffle(uint raffleId) external {
        Raffle storage raffle = raffles[raffleId];
        require(msg.sender == raffle.host);
        // we need to tranfer the NFT back to the host
        raffle.status = uint(RaffleStatus.Cancelled);
    }
}
