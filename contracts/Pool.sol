// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './ERC20.sol';
import './Math.sol';
import './SafeMath.sol';

contract Pool{
    using SafeMath  for uint;
    address token1;
    address token2;
    address tokenLP;
    ERC20 TokenA;
    ERC20 TokenB;
    ERC20 TokenLP;
    //k = x * y
    uint public x;
    uint public y;
    constructor(address _token1,address _token2,address _TokenLP){
        TokenA = ERC20(_token1);
        TokenB = ERC20(_token2);
        TokenLP = ERC20(_TokenLP);
    }

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    uint private reserve0;
    uint private reserve1;
    function getReserves() public view returns (uint _reserve0, uint _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        // 时间戳
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender,uint amountIn,bool tokenType,uint minimumOut,uint amountOut,address indexed to);
    event Sync(uint reserve0, uint reserve1);

    function _update(uint balance0, uint balance1) private {
        // 更新reserve值
        reserve0 = balance0;
        reserve1 = balance1;
        emit Sync(reserve0, reserve1);
    }

    function mint(address to) external returns (uint liquidity) {
        (uint _reserve0, uint _reserve1) = getReserves(); // gas savings
        // 池中有多少币通过池子地址在token合约中有多少余额表示
        uint balance0 = TokenA.allowance(msg.sender,address(this));
        uint balance1 = TokenB.allowance(msg.sender,address(this));
        require(balance0 > 0 && balance1 >0,"You have not approve both tokens");
        //许可的和已有的
        uint balanceAll0 = balance0 + TokenA.balanceOf(address(this));
        uint balanceAll1 = balance1 + TokenB.balanceOf(address(this));
        // 获得当前balance和上一次缓存的余额的差值，也就是新注入的流动性
        uint amount0 = balanceAll0.sub(_reserve0);
        uint amount1 = balanceAll1.sub(_reserve1);
        require(amount0 > 0 && amount1 >0,"You need to put both tokens in the pool.");
        TokenA.transferFrom(msg.sender,address(this),balance0);
        TokenB.transferFrom(msg.sender,address(this),balance1);
        // 计算手续费
        // gas 节省，必须在此处定义，因为 totalSupply 可以在 _mintFee 中更新
        // totalSupply 是 pair 的凭证
        uint _totalSupply = TokenLP.totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            // 第一次铸币，也就是第一次注入流动性，值为根号k减去MINIMUM_LIQUIDITY，根号应该是为了防止乘积过大，sub应该是为了防止乘积过小，导致后序计算偏差较大，因为liquidity是uint类型，后面计算要有除法
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            //记录x，y  k用时计算，减少误差
            x = amount0;
            y = amount1;
        } else {
            // 计算增量的token占总池子的比例，作为新铸币的数量
            // 木桶法则，按最少的来，按当前投入的占池子总的比例增发
            //_totalSupply是LP token的,根据  注入币占总币的比值*已铸LP token的总量 的最小值 铸新的LP token。 之后burn函数中，注入者取走token，取走A币数量是  持有LP token占总LP token的比值 * 当前A币  B币也一样
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
            x = TokenA.balanceOf(address(this));
            y = TokenB.balanceOf(address(this));
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        // 铸币，修改to的token数量及totalsupply
        // 给to地址发凭证，同时pair合约的totalSupply增发同等的凭证
        TokenLP._mint(to, liquidity);
        // 更新时间加权平均价格
        balance0 = TokenA.balanceOf(address(this));
        balance1 = TokenB.balanceOf(address(this));
        _update(balance0, balance1);
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external returns (uint amount0, uint amount1) {
        uint balance0 = TokenA.balanceOf(address(this));
        uint balance1 = TokenB.balanceOf(address(this));
        uint liquidity = TokenLP.balanceOf(msg.sender);

        uint _totalSupply = TokenLP.totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        // 计算返回的 amount0/1
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        TokenLP._burn(msg.sender, liquidity);
        // _token0/1 给 to 转 amount0/1

        TokenA.transfer(msg.sender,amount0);
        TokenB.transfer(msg.sender,amount1);
        // 获取转账后的balance
        balance0 = TokenA.balanceOf(address(this));
        balance1 = TokenB.balanceOf(address(this));
        // 更新 reserve0, reserve1 和 时间戳
        _update(balance0, balance1);
        x = TokenA.balanceOf(address(this));
        y = TokenB.balanceOf(address(this));
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint amountIn,bool tokenType,uint minimumOut,address to) external returns(uint){   //0 is TokenA,1 is Token B
        require(amountIn > 0 , "You need to pay tokens.");
        require(tokenType == false && TokenA.allowance(msg.sender,address(this)) >= amountIn || tokenType == true && TokenB.allowance(msg.sender,address(this)) >= amountIn,"You have not allow enough tokens to transfer.");
        (uint _reserve0, uint _reserve1) = getReserves(); // gas savings
        require(tokenType == false && _reserve0 > minimumOut || tokenType == true && _reserve1 > minimumOut,"Do not have enough tokens.");
        uint amountOut;
        uint balance0 = _reserve0;
        uint balance1 = _reserve1;

        if(tokenType == false){
            amountOut = _reserve1 - x*y/(_reserve0 + amountIn);
            require(amountOut>minimumOut,"Can not withdraw enough tokens.");
            TokenA.transferFrom(msg.sender,address(this),amountIn);
            TokenB.transfer(to,amountOut);
        }else{
            amountOut = _reserve0 - x*y/(_reserve1 + amountIn);
            require(amountOut>minimumOut,"Can not withdraw enough tokens.");
            TokenB.transferFrom(msg.sender,address(this),amountIn);
            TokenA.transfer(to,amountOut);
        }

        // 更新
        balance0 = TokenA.balanceOf(address(this));
        balance1 = TokenB.balanceOf(address(this));
        _update(balance0, balance1);

        emit Swap(msg.sender, amountIn, tokenType, minimumOut, amountOut, to);
        return amountOut;
    }

    function trySwap(uint amountIn,bool tokenType) view external returns(uint){ //0 is TokenA,1 is Token B
        (uint _reserve0, uint _reserve1) = getReserves(); // gas savings
        uint amountOut;
        if(tokenType == false){
            amountOut = _reserve1 - x*y/(_reserve0 + amountIn);
        }else{
            amountOut = _reserve0 - x*y/(_reserve1 + amountIn);
        }
        return amountOut;
    }
}
