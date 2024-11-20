-include .env
# =========================
# === SCRIPT DEPLOYMENT ===
# =========================

# NOTE: if you are *re-deploying* the contracts make sure to change the 'salt' in the DeployToBase and DeployToArbitrum scripts

deploy-contracts-to-base:
	forge script script/DeployToBase.s.sol:DeployToBase --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

deploy-contracts-to-arbitrum:
	forge script script/DeployToArb.s.sol:DeployToArbitrum --broadcast --verify --etherscan-api-key $(ARBITRUM_ETHERSCAN_API_KEY) --rpc-url $(ARBITRUM_SEPOLIA_RPC) --account deployer -vvvvv

# =================
# === SET PEERS ===
# =================

set-peers:
	forge script script/SetPeers.s.sol:SetPeers --broadcast --account deployer -vvvvv --via-ir

manually-set-send-lib:
	cast send $(BASE_SEPOLIA_LZ_ENDPOINT) "setSendLibrary(address,uint32,address)" $(OAPP_ADDRESS) $(BASE_TO_ARB_CHANNEL_ID) 0x29270F0CFC54432181C853Cd25E2Fb60A68E03f2 --rpc-url $(BASE_SEPOLIA_RPC) --account deployer

manually-set-receive-lib:
	cast send $(BASE_SEPOLIA_LZ_ENDPOINT) "setReceiveLibrary(address,uint32,address,uint256)" $(OAPP_ADDRESS) $(BASE_TO_ARB_CHANNEL_ID) 0x29270F0CFC54432181C853Cd25E2Fb60A68E03f2 --rpc-url $(BASE_SEPOLIA_RPC) 0 --account deployer

manually-set-read-channel:

# ==========================================================
# === GET OUR ACCOUNTS SOME NFTs AND VAULT SHARES ON ARB ===
# ==========================================================

bob---mint-nft-on-arb:
	cast send $(OAPP_ADDRESS) --rpc-url $(ARBITRUM_SEPOLIA_RPC) "mint()" --account bob

bob---mint-5000-tokens-on-arb:
	cast send $(OAPP_ADDRESS) --rpc-url $(ARBITRUM_SEPOLIA_RPC) "mint(address,uint256)" $(BOB_PUBLIC_ADDRESS) 5000 --account bob

bob---deposit-tokens-to-vault-on-arb:
	cast send $(OAPP_ADDRESS) --rpc-url $(ARBITRUM_SEPOLIA_RPC) "_deposit(uint256)" 5000 --account bob

# for demo purposes Jane posesses no NFT on Arb

jane---mint-10000-tokens-on-arb:
	cast send $(OAPP_ADDRESS) --rpc-url $(ARBITRUM_SEPOLIA_RPC) "mint(address,uint256)" $(JANE_PUBLIC_ADDRESS) 10000 --account jane

jane---deposit-tokens-to-vault-on-arb:
	cast send $(OAPP_ADDRESS) --rpc-url $(ARBITRUM_SEPOLIA_RPC) "_deposit(uint256)" 10000 --account jane

# =====================================
# === SEND TO ARB for COMPOSED CALL ===
# =====================================

# send() function...
# > uint32 = dstEid
# > uint = amount
# > address = recipient
# > uint8 = choice (unused)
# > bytes = composed message options bytes

send-composed-call:
	cast send $(OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "send(uint32, uint, address, uint8, bytes)" $(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID) 123000000000000000000 $(DEPLOYER_PUBLIC_ADDRESS) 1 $(COMPOSED_OPTIONS_BYTES) --value 0.1ether --account deployer

# =====================================
# === CHECK THAT WE HAVE OUR TOKENS ===
# =====================================

check-token-count-on-arb:
	cast call $(OFT_ADDRESS) "balanceOf(address)(uint256)" $(DEPLOYER_PUBLIC_ADDRESS) --rpc-url $(ARBITRUM_SEPOLIA_RPC)

# === TESTING envBytes32 CHEATCODE ===
check-oapp-bytes32-address:
	forge script script/envBytes32.s.sol:envBytes32