pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface RouteProcessor {
    function processRoute(
    address tokenIn,
    uint256 amountIn,
    address tokenOut,
    uint256 amountOutMin,
    address to,
    bytes memory route
  ) external payable returns (uint256 amountOut) ;
}

contract ACT{
    IUniswapV2Pair _usdc_bct;
    RouteProcessor _router;

    address _USDC;
    address _BCT;

    constructor(address usdc_bct, address router, address usdc, address bct){
        _usdc_bct = IUniswapV2Pair(usdc_bct);
        _router = RouteProcessor(router);
        _USDC = usdc;
        _BCT = bct;
    }

    function swapUSDC_BCT(uint256 amountUSDC) public {
        uint reserveUSDC;
        uint reserveBCT;
        (reserveUSDC, reserveBCT,) = _usdc_bct.getReserves();
        uint minAmountOutBCT = amountUSDC * reserveBCT * 95 / (reserveUSDC * 100);
        bytes memory route = abi.encodePacked(_USDC, _BCT);
        _router.processRoute(_USDC, amountUSDC, _BCT, minAmountOutBCT, address(this), route);
    }

    function redeemAndOffset(uint256 amount) public {

    }
}