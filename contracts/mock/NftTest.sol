// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
 *     ,_,
 *    (',')
 *    {/"\}
 *    -"-"-
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Test is ERC721("", "") {

	uint256 counter;

	function _baseURI() internal view override returns (string memory) {
        return "hoothoot";
    }

	function mint(uint256 _amount) external {
		uint256 _counter = counter + 1;

		for (uint256 i; i < _amount; i++)
			_mint(msg.sender, _counter++);
		counter = _counter;
	}
}