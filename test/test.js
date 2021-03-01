const { accounts, contract } = require('@openzeppelin/test-environment');
const [ owner ] = accounts;

const { expect } = require('chai');
const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');
const { assertion } = require('@openzeppelin/test-helpers/src/expectRevert');
  
const MyContract = contract.fromArtifact('NFT'); 

describe('My NFT Contract', function() {

    
    describe('_Mint Testing', function(){
    let ins=null;
    const [account1,account2]=accounts;    

    beforeEach(async function()
    {
     ins =await MyContract.new();})

    it("Shoud Mint NFT's...!", async function(){

        await ins._mint(account1,1,10,"0xffff");
        expect(Number(await ins.balanceOf(account1,1))).to.equal(10);
    })

    it("Should revert when invalid address for mint.", async function(){
        await expectRevert( ins._mint(constants.ZERO_ADDRESS,1,10,"0xffff"),"ERC1155_Mint#_mint: minting address is invalid.");
    }   )

    it("_mint should emit events.", async function(){
        const receipt= await ins._mint(account1,1,10,"0xffff",{ from: account1});
        
        expectEvent(receipt, 'TransferSingle', { _operator:account1,_from:constants.ZERO_ADDRESS,_to:account1,_id: new BN(1),_value:new BN(10)});
    })
});    
    
    describe("SetApprovalForAll & isApprovedForAll Testing", function(){
        let ins=null;
        const [account1,account2]=accounts;
        beforeEach(async function(){
             ins = await MyContract.new();
        })

        it("SetApprovalForAll Revert when invlid _operator address receive.", async function(){
            expectRevert(ins.setApprovalForAll(constants.ZERO_ADDRESS,true,{from:account1}),"NFT#setApprovalForAll: Invalid Address.!");
        })

        it("Should approve properly.", async function(){
            await ins.setApprovalForAll(account2,true,{from:account1});
            expect(await ins.isApprovedForAll(account1,account2)==true);
        })
    })

    describe("balanceOf Testing", function(){
        let ins =null;
        const [account1,account2]=accounts;

        beforeEach(async function(){
            ins=await MyContract.new();
        })

        it("Revert if found zero address", async function(){
            await expectRevert( ins.balanceOf(constants.ZERO_ADDRESS,1),"NFT#BalanceOf: Not a Valid Address");
        })
        it("Should check Balance",async function(){
            await ins._mint(account1,1,10,"0xfff");
            await expect(ins.balanceOf(account1,1)== 0);
        })
    })

    describe("SafeTransferFrom Testing", function(){
        let ins=null;
        const[account1,account2,account3]=accounts;
         beforeEach(async function(){
             ins =await MyContract.new();
         })
         it("NFT#safeTransferFrom: should be owner or operator", async function(){
             let isapproved=await ins.isApprovedForAll(account1,account2);
             await expectRevert(ins.safeTransferFrom(account3,account2,1,1,"0xffff"),"NFT#safeTransferFrom: Not A Owner Nor Operator");
            })
        it("Should transfer safely", async function(){
            await ins._mint(account1,1,10,"0xffff",{from:account1});
            await ins.setApprovalForAll(account1,account2,{from:account1});
            await ins.safeTransferFrom(account1,account2,1,1,"0xfffff",{from:account1});
            let balance1=Number(await ins.balanceOf(account1,1));
            let balance2=Number(await ins.balanceOf(account2,1));
            expect(balance1==9&&balance2==1);
        })
        it("Should be transfer by operator.", async function(){
            await ins._mint(account1,1,10,"0xffff",{from:account1});
            await ins.setApprovalForAll(account2,true,{from:account1});
            await ins.safeTransferFrom(account1,account3,1,1,"0xfffff",{from:account2});
        })
    })

    describe("safeBatchTransferFrom Testing", function(){
        let ins=null;
        const[account1,account2,account3,account4]=accounts;
        beforeEach(async function(){
            ins=await MyContract.new();
        })
        it("NFT#safeBatchTransferFrom: transfer properly from owner",async function(){
            await ins._mint(account1,1,10,"0xffff",{from:account1});
            await ins._mint(account1,2,10,"0xffff",{from:account1});
            await ins._mint(account1,3,10,"0xffff",{from:account1});
            await ins.safeBatchTransferFrom(account1,account2,[1,2,3],[1,1,1],"0xffff",{from:account1});
        })
    })

    describe("balanceOfBatch Testing", async function(){
        await ins._mint(account1,1,10,"0xffff",{from:account1});
        await ins._mint(account1,2,10,"0xffff",{from:account1});
        await ins._mint(account1,3,10,"0xffff",{from:account1});
        await expect(Number(ins.balanceOfBatch([account1,account1,account1],[1,2,3]))==[10,10,10]);
    })
});