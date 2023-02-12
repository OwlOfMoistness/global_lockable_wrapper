import pytest

@pytest.fixture(scope="module")
def minter_(accounts):
    return accounts[0]

@pytest.fixture(scope="module")
def nft(Test, minter_):
    return Test.deploy({'from':minter_})

@pytest.fixture(scope="module")
def wrapper(GlobalERC721xWrapper, minter_):
    return GlobalERC721xWrapper.deploy({'from':minter_})