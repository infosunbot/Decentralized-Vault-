# Decentralized-Vault-

implementation can be found at Contracts/Vault.sol
some test cases can be found at test/vault.js 

This contract’s constructor takes a WETH address a a parameter, that is why to be able to deploy this contract it will expect a WETH address on deployment. I searched and found a random WETH contract on sepholia network. And use it or similar on its constructor if you deploy.
WETH address: 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa

I deployed this contract to sepholia test network. 
Deployed New Contract address is: 0xC899758F7143A423fE8098c0B48941c1cE933AaA
Access details: https://sepolia.etherscan.io/address/0xC899758F7143A423fE8098c0B48941c1cE933AaA


depositETH and wrapToWETH are separate functions:
The depositETH function strictly handles the deposit of ETH without converting it to WETH.
The wrapToWETH function allows users to convert their deposited ETH to WETH within the Vault.


depositToken and withdrawToken functions tested with my pre-deployed an ERC-20 token before. 
My ERC20 token address: 0xd2B2a85EA14276a62cc3ec8C2695647207109DF1

The contract's fallback receive function now restricts direct ETH transfers, ensuring that ETH can only be sent to it via the WETH contract during unwrapping operations. This adds a safety check against unintended direct deposits.
