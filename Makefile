-include .env
# =========================
# === SCRIPT DEPLOYMENT ===
# =========================

# NOTE: if you are *re-deploying* the contracts make sure to change the 'salt' in the DeployToBase and DeployToArbitrum scripts

deploy-contracts-to-base:
	forge script script/DeployToBase.s.sol:DeployToBase --broadcast --verify --etherscan-api-key $(BASE_ETHERSCAN_API_KEY) --rpc-url $(BASE_SEPOLIA_RPC) --account deployer -vvvvv

deploy-contracts-to-arbitrum:
	forge script script/DeployToArbitrum.s.sol:DeployToArbitrum --broadcast --verify --etherscan-api-key $(ARBITRUM_ETHERSCAN_API_KEY) --rpc-url $(ARBITRUM_SEPOLIA_RPC) --account deployer -vvvvv

# =================
# === SET PEERS ===
# =================

# NOTE: before running set-peers make sure you have changed the *hardcoded* OAPP_BYTES32 and OFT_BYTES32 in the SetPeers.s.sol file

set-peers:
	forge script script/SetPeers.s.sol:SetPeers --broadcast --account deployer -vvvvv

# ===================
# === DEPOSIT ETH ===
# ===================

deposit-eth-on-base:
	cast send $(OAPP_ADDRESS) --rpc-url $(BASE_SEPOLIA_RPC) "supply()" --value 0.01ether --account deployer

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