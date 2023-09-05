// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './ERC20.sol';
import './Math.sol';
import './SafeMath.sol';

contract Curve{
    using SafeMath for uint;
    using Math for uint;
    uint256 constant N=2;
    uint256 RATES=10000;
    uint256 amp;
    uint256 PRECISION=10**4;
    uint256 constant A_PRECISION=100;

    ERC20 tokenA;
    ERC20 tokenB;
    ERC20 tokenLP;

    uint256 private reserve0;
    uint256 private reserve1;
    uint256 public constant MINIMUM_LIQUIDITY=10**3;

    constructor(address _tokenA,address _tokenB,address _tokenLP,uint256 _A){
        tokenA=ERC20(_tokenA);
        tokenB=ERC20(_tokenB);
        tokenLP=ERC20(_tokenLP);
        amp=_A;
    }
    event AddLiquidity(address indexed sender,uint256 amount0,uint256 amount1);
    event RemoveLiquidity(address indexed sender,uint256 amount0,uint256 amount1,address indexed recipient);
    event TokenExchange(address indexed sender,uint256 sold_id,uint256 amountIn,uint256 bought_id,uint256 amountOut,address recipient);
    event Sync(uint256 reserve0, uint256 reserve1);


    function _xp_mem(uint256 _reserve0, uint256 _reserve1) public view returns(uint256[] memory result) {
        result = new uint256[](2);
        result[0] = RATES * _reserve0 / PRECISION;
        result[1] = RATES * _reserve1 / PRECISION;
        return result;
    }

    function _get_D(uint256[] memory _xp, uint256 _amp) internal pure returns (uint256) {
        uint256 S = 0;
        uint256 Dprev = 0;

        for (uint256 i = 0; i < _xp.length; i++) {
            S = S.add(_xp[i]);
        }
        if (S == 0) {
            return 0;
        }

        uint256 D = S;
        uint256 Ann = _amp.mul(N);
        for (uint256 i = 0; i < 255; i++) {
            uint256 D_P = D;
            for (uint256 j = 0; j < _xp.length; j++) {
                D_P = D_P.mul(D).div(_xp[j].mul(N));
                // If division by 0, this will be borked: only withdrawal will work. And that is good
            }
            Dprev = D;
            D = Ann.mul(S).div(A_PRECISION).add(D_P.mul(N)).mul(D).div((Ann.sub(A_PRECISION)).mul(D).div(A_PRECISION).add((N.add(1)).mul(D_P)));
            // Equality with the precision of 1
            if (D > Dprev) {
                if (D.sub(Dprev) <= 1) {
                    return D;
                }
            } else {
                if (Dprev.sub(D) <= 1) {
                    return D;
                }
            }
        }
        // convergence typically occurs in 4 rounds or less, this should be unreachable!
        // if it does happen the pool is borked and LPs can withdraw via `remove_liquidity`
        revert("D diverged");
    }


    function _get_D_mem(uint256 _reserve0,uint256 _reserve1,uint _amp)internal view returns(uint256 ){
        return _get_D(_xp_mem(_reserve0,_reserve1),_amp);
    }

    function getReserves()public view returns(uint _reserve0, uint _reserve1){
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }
    function _update(uint balance0, uint balance1) private {
        // Update the reserve
        reserve0 = balance0;
        reserve1 = balance1;
        emit Sync(reserve0, reserve1);
    }

    function addLiquidity(address to)external returns(uint256 mint_amount){
        (uint _reserve0, uint _reserve1) = getReserves(); // gas savings
        // Approved balance
        uint balance0 = tokenA.allowance(msg.sender,address(this));
        uint balance1 = tokenB.allowance(msg.sender,address(this));

        require(balance0 > 0 && balance1 >0,"You have not approve both tokens");

        //Approved balance + existing balance
        uint balanceAll0 = balance0 + tokenA.balanceOf(address(this));
        uint balanceAll1 = balance1 + tokenB.balanceOf(address(this));
        // Get the difference between the current balance and the last cached balance, you can get the newly injected liquidity
        uint amount0 = balanceAll0.sub(_reserve0);
        uint amount1 = balanceAll1.sub(_reserve1);
        require(amount0 > 0 && amount1 >0,"You need to put both tokens in the pool.");
        tokenA.transferFrom(msg.sender,address(this),balance0);
        tokenB.transferFrom(msg.sender,address(this),balance1);


        //(_reserve0,_reserve1) = getReserves();
        //Initialize invariant
        uint256 D0=_get_D_mem(_reserve0,_reserve1,amp);
        uint256 D1=_get_D_mem(balanceAll0,balanceAll1,amp);
        uint256 _totalSupply=tokenLP.totalSupply();
        if(_totalSupply==0){
            mint_amount=D1;
        }else{
            mint_amount=_totalSupply*(D1-D0)/D0;
        }
        require(mint_amount>=MINIMUM_LIQUIDITY,"Slippage screwed you");
        //Mint LP tokens
        tokenLP._mint(to,mint_amount);
        balance0=tokenA.balanceOf(address(this));
        balance1=tokenB.balanceOf(address(this));
        _update(balance0,balance1);

        emit AddLiquidity(msg.sender,amount0,amount1);
    }

    function removeLiquidity(address to)external returns (uint amount0, uint amount1){
        uint balance0 = tokenA.balanceOf(address(this));
        uint balance1 = tokenB.balanceOf(address(this));
        uint256 balanceLP=tokenLP.balanceOf(msg.sender);
        uint256 _totalSupply=tokenLP.totalSupply();

        amount0=balanceLP.mul(balance0)/_totalSupply;
        amount1=balanceLP.mul(balance1)/_totalSupply;
        require(amount0 > 0 && amount1 > 0, 'Curve Swap: INSUFFICIENT_LIQUIDITY_BURNED');
        tokenLP._burn(msg.sender,balanceLP);

        tokenA.transfer(msg.sender,amount0);
        tokenB.transfer(msg.sender,amount1);
        // Get the balance after the transfer
        balance0=tokenA.balanceOf(address(this));
        balance1=tokenB.balanceOf(address(this));
        _update(balance0,balance1);
        emit RemoveLiquidity(msg.sender,amount0,amount1,to);
    }


    function _get_y(uint256 i, uint256 j, uint256 x, uint256[] memory _xp) public view returns (uint256) {

        uint256 A = amp;
        uint256 D = _get_D(_xp, A);
        uint256 Ann = A.mul(N);
        uint256 c = D;
        uint256 S = 0;
        uint256 _x = 0;
        uint256 y_prev = 0;

        for (uint256 _i = 0; _i < N; _i++) {
            if (_i == i) {
                _x = x;
            } else if (_i != j) {
                _x = _xp[_i];
            } else {
                continue;
            }
            S = S.add(_x);
            c = c.mul(D).div(_x.mul(N));
        }
        c = c.mul(D).mul(A_PRECISION).div(Ann.mul(N));
        uint256 b = S.add(D.mul(A_PRECISION).div(Ann));
        uint256 y = D;

        for (uint256 _i = 0; _i < 255; _i++) {
            y_prev = y;
            y = y.mul(y).add(c).div(y.mul(2).add(b).sub(D));
            if (y > y_prev) {
                if (y.sub(y_prev) <= 1) {
                    return y;
                }
            } else {
                if (y_prev.sub(y) <= 1) {
                    return y;
                }
            }
        }
        revert("Failed to converge");
    }

    /*
      i Index value for the coin to send
      j Index valie of the coin to recieve
      _dx Amount of `i` being exchanged
      _min_dy Minimum amount of `j` to receive
    */
    function exchange(uint256 i,uint256 j,uint256 _dx,uint256 _min_dy,address to)external returns (uint256){
        require(_dx>0,"You need to pay tokens");
        require(i!=j&&(j>=0&&j<N)&&(i>=0&&i<N));
        require(tokenA.allowance(msg.sender,address(this))>=_dx||tokenB.allowance(msg.sender,address(this))>=_dx,"You have not allow enough tokens to transfer");
        (uint _reserve0, uint _reserve1)=getReserves();
        require(_reserve0>_min_dy||_reserve1>_min_dy,"Don't have enough tokens");

        uint256[] memory xp=_xp_mem(_reserve0,_reserve1);
        uint256 x=xp[i]+_dx;
        uint256 y=_get_y(i,j,x,xp);
        uint256 amountOut=(xp[j]-y)*PRECISION/RATES;
        require(amountOut>_min_dy,"Can not withdraw enough tokens");

        if(i==0&&j==1){
            tokenA.transferFrom(msg.sender,address(this),_dx);
            tokenB.transfer(to,amountOut);
        }else if(i==1&&j==0){
            tokenB.transferFrom(msg.sender,address(this),_dx);
            tokenA.transfer(to,amountOut);
        }

        uint256 balance0=tokenA.balanceOf(address(this));
        uint256 balance1=tokenB.balanceOf(address(this));
        _update(balance0,balance1);
        return amountOut;
        //emit TokenExchange(msg.sender,i,_dx,j,amountOut,to);
    }

}