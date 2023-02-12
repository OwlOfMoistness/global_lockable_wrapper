from brownie import reverts, web3

def get_hash(nft, token_id):
	return web3.soliditySha3(
        ['address', 'uint256'], [nft.address, token_id])

def test_wrap(nft, wrapper, accounts):
	u = {'from':accounts[1]}
	nft.mint(10, u)
	nft.setApprovalForAll(wrapper, True, u)
	wrapper.wrap['address[],uint[]']([nft] * 5, [1,2,3,4,5], u)
	assert nft.balanceOf(wrapper) == 5
	assert wrapper.balanceOf(accounts[1]) == 5
	with reverts(''):
		wrapper.wrap['address[],uint[]']([nft] * 5, [1,2,3,4,5], u)

def test_unwrap(nft, wrapper, accounts):
	u = {'from':accounts[1]}
	hashes = [get_hash(nft, i) for i in [1,2,3,4,5]]
	wrapper.unwrap(hashes, u)
	assert nft.balanceOf(wrapper) == 0
	assert nft.balanceOf(accounts[1]) == 10
	assert wrapper.balanceOf(accounts[1]) == 0