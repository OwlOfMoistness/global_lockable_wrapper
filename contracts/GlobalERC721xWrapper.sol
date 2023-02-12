// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
 *     ,_,
 *    (',')
 *    {/"\}
 *    -"-"-
 */

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@owl/contracts/ERC721x.sol";

contract GlobalERC721xWrapper is ERC721x("Global Lockable NFTs", unicode"🔒LOCK"){

	struct NFTData {
		address nftAddress;
		uint256 tokenId;
	}

	mapping(uint256 => NFTData) public nftData;

	event Wrapped(address indexed nftAddress, uint256 indexed tokenId, address indexed user, uint256 hashedId);
	event Unwrapped(uint256 indexed hashedId, address indexed user);

	function underlyingTokenAddress(uint256 _tokenId) public view returns(address) {
		return nftData[_tokenId].nftAddress;
	}

	function underlyingTokenId(uint256 _tokenId) public view returns(uint256) {
		return nftData[_tokenId].tokenId;
	}

	function tokenURI(uint256 _tokenId) public override view returns(string memory) {
		return IERC721Metadata(underlyingTokenAddress(_tokenId)).tokenURI(underlyingTokenId(_tokenId));
	}

	function wrap(address _nftAddress, uint256[] calldata _tokenIds) external {
		for (uint256 i; i < _tokenIds.length; i++) {
			uint256 hashedId = uint256(keccak256(abi.encodePacked(_nftAddress, _tokenIds[i])));

			nftData[hashedId] = NFTData(_nftAddress, _tokenIds[i]);
			_mint(msg.sender, hashedId);
			IERC721(_nftAddress).transferFrom(msg.sender, address(this), _tokenIds[i]);
			emit Wrapped(_nftAddress, _tokenIds[i], msg.sender, hashedId);
		}
	}

	function wrap(address[] calldata _nftAddresses, uint256[] calldata _tokenIds) external {
		for (uint256 i; i < _tokenIds.length; i++) {
			uint256 hashedId = uint256(keccak256(abi.encodePacked(_nftAddresses[i], _tokenIds[i])));

			nftData[hashedId] = NFTData(_nftAddresses[i], _tokenIds[i]);
			_mint(msg.sender, hashedId);
			IERC721(_nftAddresses[i]).transferFrom(msg.sender, address(this), _tokenIds[i]);
			emit Wrapped(_nftAddresses[i], _tokenIds[i], msg.sender, hashedId);
		}
	}

	function unwrap(uint256[] calldata _tokenIds) external {
		for (uint256 i; i < _tokenIds.length; i++) {
			require(ownerOf(_tokenIds[i]) == msg.sender);
			require(isUnlocked(_tokenIds[i]), "Token is locked");
			address nftContract = nftData[_tokenIds[i]].nftAddress;
			uint256 tokenId = nftData[_tokenIds[i]].tokenId;

			_burn(_tokenIds[i]);
			delete nftData[_tokenIds[i]];
			IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
			emit Unwrapped(_tokenIds[i], msg.sender);
		}
	}
}