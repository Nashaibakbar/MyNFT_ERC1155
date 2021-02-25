pragma solidity  0.7.4;

import "../Interfaces/IERC1155.sol";
import "../Interfaces/IERC165.sol";
import "../utils/Address.sol";
import "../utils/SafeMath.sol";

contract NFT is IERC1155{

    using Address for address;
    using SafeMath for uint256;


//   bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
//   bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    mapping(address => mapping(uint256 => uint256)) balances;
    mapping(uint256 => mapping(address => uint256))  balances_nft;
    mapping(address => mapping(address => bool)) operators;
    mapping(address => mapping(address => bool)) operator;
    mapping(uint256 => address) creaters; 
    uint256 private nonce;
    uint256 private nftids=1;


    function safeTransferFrom(
    address _from,
    address _to,
    uint256 _id,
    uint256 _value, 
    bytes calldata _data) 
    external override 
    {
        require(msg.sender == _from || isApprovedForAll(msg.sender,_from)== true,"NFT#safeTransferFrom: Not A Owner Nor Operator");
        require(_to!=address(0),"NFT#safeTransferFrom: Not A valid receiver address");
        require(_value<= balanceOf(_from, _id),"NFT#safeTransferFrom: Not have proper funds");

        balances[_from][_id]= balances[_from][_id].sub(_value);
        balances[_to][_id]=balances[_to][_id].add(_value);

        emit TransferSingle(msg.sender,_from,_to,_id,_value);

        if(_to.isContract())
        {
         revert();//_doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
    }

    function safeTransferFromNft(
    address _from,
    address _to,
    uint256 _id,
    uint256 _value, 
    bytes calldata _data) 
    external  
    {
        require(msg.sender == _from || isApprovedForNft(msg.sender,_from)== true,"NFT#safeTransferFrom: Not A Owner Nor Operator");
        require(_to!=address(0),"NFT#safeTransferFrom: Not A valid receiver address");
        require(_value<= balanceOfNft(_from, _id),"NFT#safeTransferFrom: Not have proper funds");

        balances_nft[_id][_from]= balances_nft[_id][_from].sub(_value);
        balances_nft[_id][_to]=balances_nft[_id][_to].add(_value);

        emit TransferSingle(msg.sender,_from,_to,_id,_value);


        if(_to.isContract())
        {
         revert();//_doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids,
    uint[] calldata _values, bytes calldata _data) external override {
        require(msg.sender==_from || isApprovedForAll(msg.sender,_from),"NFT#safeBatchTransferFrom: Not A Owner Nor Operator");
        require(_to!=address(0),"NFT#safeBatchTransferFrom: in valid receiver address.");
        require(_ids.length==_values.length,"NFT#safeBatchTransferFrom: id & value is not in same length ! ");
        
        for(uint256 i=0; i< _ids.length;i++){
            balances[_from][_ids[i]]= balances[_from][_ids[i]].sub(_values[i]);
            balances[_to][_ids[i]]= balances[_to][_ids[i]].add(_values[i]);
        }

        emit TransferBatch(msg.sender,_from,_to,_ids,_values);

        if(_to.isContract()){
           revert(); // __doSafeBatchTransferAcceptanceCheck(msg.sender,_from,_to,_ids,_values,_data);
        }
    }

    // function _doSafeBatchTransferAcceptanceCheck(address _operator,address _from, address _to,uint256[] _ids,uint256[] _values, bytes calldata _data) internal {
    
    //     require(ERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _values, _data) == ERC1155_BATCH_ACCEPTED, "contract returned an unknown value from onERC1155BatchReceived");

    // }
    // function _doSafeTransferAcceptanceCheck(address _operator, address _from, address _to,
    // uint256 _id, uint256 _value, bytes memory _data) internal{
    //     require(ERC1155TokenReceiver(_to).onERC1155Received(_from,_to,_id,_value,_data)==ERC1155_RECEIVED_VALUE,"NFT#_doSafeTransferAcceptanceCheck: Interface not found.");
    // }

    function balanceOf(address _owner, uint256 _id) public override view returns(uint256){
        require(_owner!=address(0),"NFT#BalanceOf: Not a Valid Address");
        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external override view returns(uint[] memory)
    {
        require(_owners.length==_ids.length,"NFT#balanceOfBatch");
        uint256[] memory temp=new uint256[](_owners.length);

        for(uint256 i=0;i <_owners.length;i++){
            temp[i]=balances[_owners[i]][_ids[i]];
        }
        return temp;
    }


    function setApprovalForAll(
    address _operator, 
    bool _approved)
    external override
    {
        require(_operator!=address(0),"NFT#setApprovalForAll: Invalid Address.!");
        operators[msg.sender][_operator]=_approved;
        emit ApprovalForAll(msg.sender,_operator, _approved);
    }

    function isApprovedForAll(
    address _owner, 
    address _operator) 
    public override view returns(bool)
    {
        require(_owner!=address(0),"NFT#isApprovedForAll: Invalid Address.!");
        return operators[_owner][_operator];
    }
    
    function setApprovalForNft(
    address _operator, 
    bool _approved)
    external 
    {
        require(_operator!=address(0),"NFT#setApprovalForAll: Invalid Address.!");
        operator[msg.sender][_operator]=_approved;
        //emit ApprovalForAll(msg.sender,_operator, _approved);
    }
    

    function isApprovedForNft(
    address _owner, 
    address _operator) 
    public  view returns(bool)
    {
        require(_owner!=address(0),"NFT#isApprovedForAll: Invalid Address.!");
        return operator[_owner][_operator];
    }

function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) external  {
        require(_to!=address(0),"ERC1155_Mint#_mint: minting address is invalid.");
        balances[_to][_id]= balances[_to][_id].add(_amount);

        emit TransferSingle(msg.sender,address(0x0), _to, _id, _amount);

        if(_to.isContract())
        {
            revert();
            // use data variable here to check out interface is implemented or not.
        }
}

function _mintNFT(address _to,uint256 _id, bytes memory _data) external {
        
        require(_to!=address(0),"ERC1155#_mintNFT Invlid address");
        require(nftids<=_id,"ERC1155#_mintNFT  id already exist");
        balances_nft[_id][_to]=balances_nft[_id][_to].add(1);
        ++nftids;
        emit TransferSingle(_to, address(0), _to , _id, 1);

}

function balanceOfNft(address _owner, uint256 _id) public view returns(uint256) {
        return balances_nft[_id][_owner];
}
function create(uint256 _initialSupply, string memory _uri) external returns(uint256){

uint256 _id=++nonce;
creaters[_id]=msg.sender;
balances[msg.sender][_id]= balances[msg.sender][_id].add(_initialSupply);

emit TransferSingle(msg.sender, address(0), msg.sender , _id, _initialSupply);

if(bytes(_uri).length > 0 ){
    emit URI(_uri, _id);
}
return _id;
}

}