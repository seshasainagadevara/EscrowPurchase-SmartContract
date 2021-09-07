//SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.7;

contract EscrowPurchase{
        
        uint public amount;
        address payable public buyer;
        address payable public seller;
        enum EscrowState{Created, Locked, Released, Inactive}
        
        EscrowState public state;
        
        
        error OnlySeller();
        error OnlyBuyer();
        error InvalidState();
        error ValueNotEven();
        

        event Aborted();
        event SellerRefunded();
        event PaymentConfirmed();
        event ItemReceived();
        
        modifier onlySeller(){
        if(msg.sender != seller) revert OnlySeller();
            _;
        }
        
        modifier inState(EscrowState state_){
            if(state!=state_) revert InvalidState();
            _;
        }
        modifier onlyBuyer(){
            if(msg.sender != buyer) revert OnlyBuyer();
            _;
        }
        modifier condition(bool condition_){
                require(condition_, "Invalid amount not even");
            _;
        }
            
        
        
        constructor() payable{
            seller = payable(msg.sender);
            amount = msg.value/2;
            if((2*amount)!=msg.value) revert ValueNotEven();
        }
        
        
        function abort() external onlySeller inState(EscrowState.Created){
            emit Aborted();
            state = EscrowState.Inactive;
            seller.transfer(address(this).balance);
        }
        
        function confirmPurchase() external  
        inState(EscrowState.Created) 
        condition(msg.value == (2*amount)) payable{
            emit PaymentConfirmed();
            buyer = payable(msg.sender);
            state = EscrowState.Locked;
        }
        
        function confirmReceived() external onlyBuyer inState(EscrowState.Locked){
            emit ItemReceived();
            state = EscrowState.Released;
            buyer.transfer(amount);
        }
        function refundSeller() external onlySeller inState(EscrowState.Released){
            emit SellerRefunded();
            seller.transfer(3*amount);
        }
        
}
