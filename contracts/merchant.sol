 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
 
 contract merchent {
    address payable immutable public admin;

    struct item{
        uint item_no;
        uint quantity;
        address payable item_owner;
        uint price;
        bool exists;
        uint received_amount;
    }
    mapping (uint => item ) public items;

    event item_logs(uint item_no,uint quantity,uint price,address item_owner);

    constructor(){
        admin = payable(msg.sender);
    }
    
    modifier onlyowner{
        require(msg.sender==admin,"Only owner can call this function");
        _;
    }

    modifier item_exists(uint _item_no){
        require(items[_item_no].exists == true , "Item does not exists");
        require(items[_item_no].quantity>0,"Their is not enough quantity");
        _;
    }

    function item_listing(uint _item_no,uint _quantity,uint _price, address payable owner) public onlyowner{
        
        require(items[_item_no].exists== false,"The item is listed already");
        require(_quantity>0,"Their must be atleast one item to list");
        require(_price>0,"Their must be a minimum price of the item");

        items[_item_no].exists=true;
        items[_item_no]= item(_item_no, _quantity,owner,_price,items[_item_no].exists,0);

        emit item_logs(_item_no,_quantity,_price,owner);  
    }


    function item_buy(uint _item_no , uint _quantity ) payable public item_exists(_item_no){
         
        uint total_amount = items[_item_no].price * _quantity ;

        require(msg.sender!= address(0),"The address of buyer is invalid");
        require(msg.value >= total_amount,"The amount is insufficient ");

        items[_item_no].item_owner.transfer(msg.value);

        items[_item_no].quantity -= _quantity;

        emit item_logs(_item_no , _quantity,  total_amount, msg.sender);   

        if(items[_item_no].quantity==0){
            items[_item_no].exists=false;
        }
    } 

    function bid_winners(uint _item_no , address payable winner) public {

        require(items[_item_no].received_amount>=items[_item_no].price,"Enough contribution was not made");

        items[_item_no].item_owner.transfer(items[_item_no].price);
        
        emit item_logs(_item_no,1,items[_item_no].price,winner);
        
        if(items[_item_no].quantity==0){
            items[_item_no].exists=false;
        }
    }

    function bid_start(uint _item_no ) payable public item_exists(_item_no){
        uint req = (items[_item_no].price*51)/100;
        
        require(msg.sender!=address(0),"user doesn't exists");
        require(msg.value>=req,"Amount insufficient");
        items[_item_no].received_amount += msg.value;
    
    //used if item is only 1 and 2 pairs try to start the game at the same time .  
        if(items[_item_no].received_amount>=items[_item_no].price){
            items[_item_no].quantity -= 1;
        }
    } 

    function withdraw_funds() public onlyowner{
        admin.transfer(address(this).balance);
    }

}
