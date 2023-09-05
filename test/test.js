const assert = require('assert');
const Pool = artifacts.require('Pool');
const TokenA = artifacts.require('TokenA');
const TokenB = artifacts.require('TokenB');
const TokenLP = artifacts.require('TokenLP');
const Curve = artifacts.require('Curve');
const Web3 = require('web3');
const web3 = new Web3('http://localhost:8545');

contract('TEST',async function(accounts){
    beforeEach(async () => {
        A = await TokenA.new({ from: accounts[0] });
        B = await TokenB.new({ from: accounts[0] });
        LP = await TokenLP.new({from:accounts[0]});
        //P = await Pool.new(A.address,B.address,LP.address,{from:accounts[0]});
        P2 = await Curve.new(A.address,B.address,LP.address,100,{from:accounts[0]});
        accounts = await web3.eth.getAccounts();
    });

    describe("Campaigns", () => {
        // it('deployes a contract',async () => {
        //     assert.ok(A.address);
        //     assert.ok(B.address);
        //     assert.ok(LP.address);
        //     assert.ok(P.address);
        // });
        //
        // it('can mint LP token', async () => {
        //     await A.approve(P.address,20000,{from:accounts[0]});
        //     await B.approve(P.address,10000,{from:accounts[0]});
        //     let amount0 = await A.allowance.call(accounts[0],P.address);
        //     let amount1 = await B.allowance.call(accounts[0],P.address);
        //     assert.equal(amount0.words[0],20000);
        //     assert.equal(amount1.words[0],10000);
        //     const LPToken = await P.mint.call(accounts[0],{from:accounts[0]});
        //     await P.mint(accounts[0],{from:accounts[0]});
        //     console.log(LPToken.words[0]);
        //     amount0 = await A.balanceOf.call(P.address);
        //     amount1 = await B.balanceOf.call(P.address);
        //     assert.equal(amount0.words[0],20000);
        //     assert.equal(amount1.words[0],10000);
        // });

        // it('can burn LP token', async () => {
        //     await A.approve(P.address,20000,{from:accounts[0]});
        //     await B.approve(P.address,10000,{from:accounts[0]});
        //     const LPToken = await P.mint.call(accounts[0],{from:accounts[0]});
        //     await P.mint(accounts[0],{from:accounts[0]});
        //     console.log(LPToken.words[0]);
        //     let amount0;
        //     let amount1;
        //     amount0,amount1 = await P.burn.call(accounts[0],{from:accounts[0]});
        //     console.log(amount0);
        //     console.log(amount1);
        // });

        // it('can swap tokens', async () => {
        //     await A.approve(P.address,20000,{from:accounts[0]});
        //     await B.approve(P.address,10000,{from:accounts[0]});
        //     const LPToken = await P.mint.call(accounts[0],{from:accounts[0]});
        //     await P.mint(accounts[0],{from:accounts[0]});
        //     await A.transfer(accounts[1],5000);
        //     const balance1 = await A.balanceOf.call(accounts[1]);
        //     assert.equal(balance1.words[0],5000);
        //     await A.approve(P.address,5000,{from:accounts[1]});
        //     await P.swap(5000,false,1000,accounts[1],{from:accounts[1]});
        //     let amount = await B.balanceOf(accounts[1]);
        //     console.log(amount);
        // });

        it('两人铸币 ', async () => {
            //账户0铸币
            await A.approve(P2.address,2000,{from:accounts[0]});
            await B.approve(P2.address,1000,{from:accounts[0]});
            const LPToken0 = await P2.addLiquidity.call(accounts[0],{from:accounts[0]});
            await P2.addLiquidity(accounts[0],{from:accounts[0]});
            console.log(LPToken0);
            // //账号1铸币
            // await A.transfer(accounts[1],5000,{from:accounts[0]});
            // await B.transfer(accounts[1],3000,{from:accounts[0]});
            // await A.approve(P.address,5000,{from:accounts[1]});
            // await B.approve(P.address,3000,{from:accounts[1]});
            // const LPToken1 = await P.mint.call(accounts[1],{from:accounts[1]});
            // await P.mint(accounts[1],{from:accounts[1]});
            //
            // console.log(LPToken0);
            // console.log(LPToken1);
            //
            // //账号0烧币
            // let amount0;
            // let amount1;
            // amount0,amount1 = await P.burn.call(accounts[0],{from:accounts[0]});
            // await P.burn(accounts[0],{from:accounts[0]});
            // console.log(amount0);
            // console.log(amount1);
            //
            // //账号0、1的LP余额
            // amount0 = await LP.balanceOf(accounts[0]);
            // amount1 = await LP.balanceOf(accounts[1]);
            // console.log(amount0);
            // console.log(amount1);
            //
            // //看看是否完成转账
            // amount0 = await A.balanceOf(accounts[0]);
            // amount1 = await B.balanceOf(accounts[0]);
            // console.log(amount0);
            // console.log(amount1);
            //
            // //账号2换钱
            // await A.transfer(accounts[2],5000,{from:accounts[0]});
            // await A.approve(P.address,5000,{from:accounts[2]});
            // await P.swap(5000,false,1000,accounts[2],{from:accounts[2]});
            // let amount = await B.balanceOf(accounts[2]);
            // console.log(amount);
        });
    });
});